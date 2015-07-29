//
//  PSPsyScopeXRunner.swift
//  PsyScopeEditor
//
//  Created by James on 29/06/2015.
//  Copyright © 2015 James. All rights reserved.
//
import CoreServices.LaunchServices
import CoreServices
import Foundation

//controls running psyscope from unix commands

class PSPsyScopeXRunner : NSObject {
    static let sharedInstance : PSPsyScopeXRunner = PSPsyScopeXRunner()

    let openFlag = "-o"
    let quitOnEndFlag = "-q"
    let runningFlag = "-f"
    let foregroundFlag = "-fg"
    let runOnOpen = "-r"
    let printHelp = "-h"
    let saveOnExit = "-s"
    
    var currentlyRunningPsyScopeTask : NSTask?
    var currentlyRunningDocument : Document?
    var currentlyRunningScriptFileName : String?
    
    var executablePath : String? {
        get {
            let appBundlePath = PSPreferences.psyScopeXPath.value as! String
            kUTTypeContent
            let appBundleName = appBundlePath.lastPathComponent.stringByDeletingPathExtension
            
            let executablePathFinal = appBundlePath.stringByAppendingPathComponent("Contents").stringByAppendingPathComponent("MacOS").stringByAppendingPathComponent(appBundleName)
            
            guard NSFileManager.defaultManager().fileExistsAtPath(executablePathFinal) else {
                print("App at \(executablePathFinal) doesnt exist")
                return nil
            }
            
            return executablePathFinal
        }
    }
    
    func runThisScript(document : Document) {
        
        //check for running task and close it
        terminate()
        
        //check for existence of psyscope x
        guard let launchPath = executablePath where launchPath != "" else {
            PSModalAlert("You need to set the path for PsyScopeX in the Preferences before continuing")
            return
        }
        
        //if file exists create a file with the script in sub directory 'running'
        guard let documentPath = document.scriptData.documentDirectory() else {
            document.scriptData.alertIfNoValidDocumentDirectory()
            return
        }
        
        
        guard let scriptFileURL = document.fileURL, scriptFileName = scriptFileURL.path else  {
            PSModalAlert("Error getting document's name - try resaving the document elsewhere.")
            return
        }
        
        let scriptName = scriptFileName.lastPathComponent.stringByDeletingPathExtension
        let psyXScriptFileName = documentPath.stringByAppendingPathComponent(scriptName)
        let script = PSScriptWriter(scriptData: document.scriptData).generatePsyScopeXScript()
        
        do {
            try script.writeToFile(psyXScriptFileName, atomically: true, encoding: NSMacOSRomanStringEncoding)
            HFSFileTypeHelper.setTextFileAttribs(psyXScriptFileName)
        }
        catch {
            PSModalAlert("Couldn't write the PsyScopeX file (or set it's attributes)")
            return
        }
        
        
        
        //construct running command with NSTask
        let task = NSTask()
        task.launchPath = launchPath
        task.arguments = [openFlag,psyXScriptFileName,runOnOpen,foregroundFlag,quitOnEndFlag,saveOnExit,"y"]
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "terminated:", name: NSTaskDidTerminateNotification, object: task)
        
        //launch the task
        task.launch()
        
        //save task
        currentlyRunningScriptFileName = psyXScriptFileName
        currentlyRunningDocument = document
        currentlyRunningPsyScopeTask = task
    }
    
    func terminated(_: AnyObject) {
        print("TERMINATED")
        
        //try to load
        guard let currentlyRunningScriptFileName = currentlyRunningScriptFileName,
            currentlyRunningDocument = currentlyRunningDocument else {
                return
        }
        
        defer {
            //convert old log and script file to text format
            if let documentPath = currentlyRunningDocument.scriptData.documentDirectory() {
            
                let dataFileName = documentPath.stringByAppendingPathComponent(PSGetDataFileName(currentlyRunningDocument.scriptData))
                let logFileName = documentPath.stringByAppendingPathComponent(PSGetLogFileName(currentlyRunningDocument.scriptData))
                
                HFSFileTypeHelper.setTextFileAttribs(dataFileName)
                HFSFileTypeHelper.setTextFileAttribs(logFileName)
            }
        }
        
        do {
            let changedScript = try String(contentsOfFile: currentlyRunningScriptFileName, encoding: NSUTF8StringEncoding)
            
            //check for changes
            let scriptReader = PSScriptReader(script: changedScript)
            let baseEntries = currentlyRunningDocument.scriptData.getBaseEntries()
            var foundDifferences = false
            
            for ghostEntry in scriptReader.ghostScript.entries {
                for realEntry in baseEntries {
                    if ghostEntry.name == realEntry.name {
                        //found entry
                        if ghostEntry.currentValue != realEntry.currentValue {
                            foundDifferences = true
                            break
                        }
                        
                        //do sub entries
                        if areThereDifferencesBetween(realEntry, ghostEntry: ghostEntry) {
                            foundDifferences = true
                            break
                        }
                    }
                }
            }
            
            if foundDifferences && userWantsToChangeDifferences() {
                currentlyRunningDocument.scriptData.beginUndoGrouping("Update Script From Run")
                for ghostEntry in scriptReader.ghostScript.entries {
                    for realEntry in baseEntries {
                        if ghostEntry.name == realEntry.name {
                            //found entry
                            if ghostEntry.currentValue != realEntry.currentValue {
                                realEntry.currentValue = ghostEntry.currentValue
                            }
                            
                            //do sub entries
                            updateGhostScriptSubEntries(realEntry, ghostEntry: ghostEntry)
                        }
                    }
                }
                currentlyRunningDocument.scriptData.endUndoGrouping()
            }
            
        } catch {
            return
        }
    }
    
    func updateGhostScriptSubEntries(realEntry : Entry, ghostEntry : PSGhostEntry) {
        for subGhostEntry in ghostEntry.subEntries {
            for subRealEntry in realEntry.subEntries.array as! [Entry] {
                if subGhostEntry.name == subRealEntry.name {
                    //found entry
                    if subGhostEntry.currentValue != subRealEntry.currentValue {
                        subRealEntry.currentValue = subGhostEntry.currentValue
                    }
                    
                    //do sub entries
                    updateGhostScriptSubEntries(subRealEntry, ghostEntry: subGhostEntry)
                }
            }
        }
    }
    
    func areThereDifferencesBetween(realEntry : Entry, ghostEntry : PSGhostEntry) -> Bool {
        for subGhostEntry in ghostEntry.subEntries {
            for subRealEntry in realEntry.subEntries.array as! [Entry] {
                if subGhostEntry.name == subRealEntry.name {
                    //found entry
                    if subGhostEntry.currentValue != subRealEntry.currentValue {
                        return true
                    }
                    
                    //do sub entries
                    if areThereDifferencesBetween(subRealEntry, ghostEntry: subGhostEntry) {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    func userWantsToChangeDifferences() -> Bool {
        let question = "Perform PsyScopeX Script changes?"
        let info = "PsyScopeX has caused some changes to the script, do you want to update the values in your current script to these new values?  (Note: This will only affect entry values, if PsyScopeX deleted or added entries, these changes will not be propogated)"
        let overrideButton = "Accept Changes"
        let cancelButton = "Discard Changes"
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = info
        alert.addButtonWithTitle(overrideButton)
        alert.addButtonWithTitle(cancelButton)
        
        let answer = alert.runModal()
        if answer == NSAlertFirstButtonReturn {
            return true
        } else {
            return false
        }
    }
    
    func terminate() {
        if let currentlyRunningPsyScopeTask = currentlyRunningPsyScopeTask {
            currentlyRunningPsyScopeTask.terminate()
            self.currentlyRunningPsyScopeTask = nil
        }
        
        
    }
    func kill() {
        /*
        // define command
        NSString* appName = @"Finder";
        NSString* killCommand = [@"/usr/bin/killall " stringByAppendingString:appName];
        
        // execute shell command
        NSTask *task = [[NSTask alloc] init];
        [task setLaunchPath:@"/bin/bash"];
        [task setArguments:@[ @"-c", killCommand]];
        [task launch];*/
    }
}

/*

This is easy and potentially very powerful. The only thing you must remember is that PsyScope, is a package, so you have to address the program inside the package. Thus, assuming that you are in Terminal, and that PsyScope X is in your Home directory,

Me:~ luca$ /Users/luca/PsyScope\ X\ B57.app

won't work. Instead,

Me:~ luca$ PsyScope\ X\ B57.app/Contents/MacOS/PsyScope\ X\ B57

will start PsyScope X. Now, the nice things are the parameters you can pass. The options are:

-o: Open script. (Requires a file name)
-f: Create a flag file when running a script.
-q: Quit on experiment end
-s: Save script on exit. Arg: [a|y|n] (a)sk (y)es (n)o
-fg: Execute in foreground
-r: Run script on open
-h: Print this help

Most options are self-explanatory. Let us look at an example. If you write

Me:~ luca$ PsyScope\ X\ B57.app/Contents/MacOS/PsyScope\ X\ B57	-o MyScript

the terminal will open the script after opening the program (remember that you can simply drag and drop on the terminal the file to get the path pasted in it. If you add an option '-r' and the script will automatically run.If you add the option -fg, the script will run in the foreground, so that you will just see the script running without even seeing the startup graphical interface or the PsyScope startup window. And if you add a -q....

Me:~ luca$ PsyScope\ X\ B57.app/Contents/MacOS/PsyScope\ X\ B57 -o /Users/luca/Desktop/Archive/onlymovie\ Script\ copy -r -fg -q

the script will run and the program will quit after finishing the execution of the script.

Perhaps you can now see the interest of this possibility. You can write shell files that chain several experiments together, potentially using the result of one experiment to modify the execution of the next one.

This is where the only strange option, -f, comes in. The option serves to create an empty file, which exists only while PsyScope X is running. You can then write your shell scripts by checking whether this file exists (instead of looking for the process number, which turns out to be more complex) in order to know that the program is running.

Thus you can know how to run your sequence of experiments. This shell script shows how you could run two experiments by dragging and dropping the icon of the program (without looking inside the program's package) and the two scripts onto the terminal. You can check the script to see how it uses the existence of the flag file to close and restart the program without your intervention. Be aware that



*/