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

class PSPsyScopeXRunner {
    static let sharedInstance = PSPsyScopeXRunner()
    let openFlag = "-o"
    let quitOnEndFlag = "-q"
    let runningFlag = "-f"
    let foregroundFlag = "-fg"
    let runOnOpen = "-r"
    let printHelp = "-h"
    
    var currentlyRunningPsyScopeTask : NSTask?
    
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
        //check for existence of file
        guard let launchPath = executablePath where launchPath != "" else {
            print("Could not get launch path")
            return
        }
        
        //if file exists create a file with the script in sub directory 'running'
        guard let documentPath = document.scriptData.documentDirectory() else {
            document.scriptData.alertIfNoValidDocumentDirectory()
            return
        }
        
        
        
        let scriptFileName = documentPath.stringByAppendingPathComponent("psyScopeXScript.txt")

        let script = PSScriptWriter(scriptData: document.scriptData).generatePsyScopeXScript()
        do {
            try script.writeToFile(scriptFileName, atomically: true, encoding: NSMacOSRomanStringEncoding) }
        catch {
            print("Couldnt write file")
            return
        }

        
        //construct running command with NSTask
        let task = NSTask()
        task.launchPath = launchPath
        
        let arguments = " ".join([openFlag,scriptFileName,foregroundFlag,runOnOpen,quitOnEndFlag ])
        
        print(launchPath + " " + arguments)
        task.arguments = [openFlag,scriptFileName]
        //set notification listening for NSTaskDidTerminateNotification
        
        //launch the task
        task.launch()
    }
    
    func terminate() {
        if let currentlyRunningPsyScopeTask = currentlyRunningPsyScopeTask {
            currentlyRunningPsyScopeTask.terminate()
        }
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