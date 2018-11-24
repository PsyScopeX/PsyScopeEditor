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

/**
 * PSPsyScopeXRunner: Deals with running scripts in the old PsyscopeX.
 * Called by PSMainWindowController.runExperiment(_)
 */
class PSPsyScopeXRunner : NSObject {
    
    //MARK: Singleton Instance
    
    static let sharedInstance : PSPsyScopeXRunner = PSPsyScopeXRunner()
    
    //MARK: Flags for PsyscopeX
    
    let openFlag = "-o"
    let quitOnEndFlag = "-q"
    let runningFlag = "-f"
    let foregroundFlag = "-fg"
    let runOnOpen = "-r"
    let printHelp = "-h"
    let saveOnExit = "-s"
    
    //MARK: Variables
    
    var currentlyRunningPsyScopeTask : Process?
    var currentlyRunningDocument : Document?
    var currentlyRunningScriptFileName : String?
    
    //MARK: Path to PsyscopeX' executable
    
    var executablePath : String? {
        get {
            let appBundlePath = PSPreferences.psyScopeXPath.stringValue

            let appBundleName = appBundlePath.lastPathComponent.stringByDeletingPathExtension
            
            let executablePathFinal = appBundlePath.stringByAppendingPathComponent("Contents").stringByAppendingPathComponent("MacOS").stringByAppendingPathComponent(appBundleName)
            
            guard FileManager.default.fileExists(atPath: executablePathFinal) else {
                print("App at \(executablePathFinal) doesnt exist")
                return nil
            }
            
            return executablePathFinal
        }
    }
    
    //MARK: Running / terminating a script
    
    func runThisScript(_ document : Document) {
        
        //check for running task and close it
        terminate()
        
        //get the path to psyscopeX
        guard let launchPath = executablePath, launchPath != "" else {
            PSModalAlert("You need to set the path for PsyScopeX in the Preferences before continuing.  It may need to be refreshed if you have moved the application.  To do this, go to Preferences, then click the button to reset it to the default internal copy of PsyScopeX")
            return
        }
        
        //get the location of where the document is saved
        guard let documentPath = document.scriptData.documentDirectory() else {
            document.scriptData.alertIfNoValidDocumentDirectory()
            return
        }
        
        //get the path to the document
        guard let scriptFileURL = document.fileURL else  {
            PSModalAlert("Error getting document's name - try resaving the document elsewhere.")
            return
        }
        
        //create the name for the PsyScopeX script
        let scriptName = scriptFileURL.path.lastPathComponent.stringByDeletingPathExtension
        let psyXScriptFileName = documentPath.stringByAppendingPathComponent(scriptName)
        
        //get a psyscopeX copy of the script from the document.
        let script = PSScriptWriter(scriptData: document.scriptData).generatePsyScopeXScript()
        
        //write the script file
        do {
            try script.write(toFile: psyXScriptFileName, atomically: true, encoding: String.Encoding.macOSRoman)
            HFSFileTypeHelper.setTextFileAttribs(psyXScriptFileName)
        }
        catch {
            PSModalAlert("Couldn't write the PsyScopeX file (or set it's attributes)")
            return
        }
        
        //check for existance of and create log file
        var logFilePath : String = "PsyScope.psylog"
        let scriptLogFilePath = PSGetLogFileName(document.scriptData)
        if let customLogFilePath = PSStandardPath(scriptLogFilePath, basePath: documentPath) {
            logFilePath = customLogFilePath
        } else {
            PSModalAlert("Error in Log File entry value: \(scriptLogFilePath) - the log file must be a path (without any functions etc)")
            return
        }
        
        if !FileManager.default.fileExists(atPath: logFilePath) {
            //need to create
            do {
                try "#LogFile".write(toFile: logFilePath, atomically: true, encoding: String.Encoding.macOSRoman)
                HFSFileTypeHelper.setTextFileAttribs(logFilePath)
            }
            catch {
                PSModalAlert("Couldn't write the PsyScopeX Log file: \(logFilePath)")
                return
            }
            
        }
        
        
        
        //construct running command with NSTask
        let task = Process()
        task.launchPath = launchPath
        task.arguments = [openFlag,psyXScriptFileName,runOnOpen,foregroundFlag,quitOnEndFlag,saveOnExit,"y"]
        NotificationCenter.default.addObserver(self, selector: "terminated:", name: Process.didTerminateNotification, object: task)
        
        //launch the task
        task.launch()
        
        //save task
        currentlyRunningScriptFileName = psyXScriptFileName
        currentlyRunningDocument = document
        currentlyRunningPsyScopeTask = task
    }
    
    func terminate() {
        if let currentlyRunningPsyScopeTask = currentlyRunningPsyScopeTask {
            currentlyRunningPsyScopeTask.terminate()
            self.currentlyRunningPsyScopeTask = nil
        }
    }
    
    //MARK: NSTaskDidTerminateNotification
    
    // When PsyscopeX task has finished, make sure data and log file are text files, and check if user wants to update document from any changes made by psyscopeX
    func terminated(_: AnyObject) {
        
        //try to load
        guard let currentlyRunningScriptFileName = currentlyRunningScriptFileName,
            let currentlyRunningDocument = currentlyRunningDocument else {
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
            let changedScript = try String(contentsOfFile: currentlyRunningScriptFileName, encoding: String.Encoding.utf8)
            
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
            
            //only update changes if user wants to
            let shouldAutomaticallyUpdate = PSPreferences.automaticallyUpdateScript.boolValue
            
            if foundDifferences && (shouldAutomaticallyUpdate || askIfUserWantsToChangeDifferences()) {
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
            PSModalAlert("Error loading script, expected at \(currentlyRunningScriptFileName).  This document's current script will remain unchanged.")
            return
        }
    }
    
    //updates real entries with ghost entries
    func updateGhostScriptSubEntries(_ realEntry : Entry, ghostEntry : PSGhostEntry) {
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
    
    //checks for differences between real entries and ghost entries
    func areThereDifferencesBetween(_ realEntry : Entry, ghostEntry : PSGhostEntry) -> Bool {
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
    
    func askIfUserWantsToChangeDifferences() -> Bool {
        let question = "Perform PsyScopeX Script changes?"
        let info = "PsyScopeX has caused some changes to the script, do you want to update the values in your current script to these new values?  (Note: This will only affect entry values, if PsyScopeX deleted or added entries, these changes will not be propogated)"
        let overrideButton = "Accept Changes"
        let cancelButton = "Discard Changes"
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = info
        alert.addButton(withTitle: overrideButton)
        alert.addButton(withTitle: cancelButton)
        
        let answer = alert.runModal()
        if answer == NSAlertFirstButtonReturn {
            return true
        } else {
            return false
        }
    }
    
    

}

