//
//  PSTidyUpExecutionEntries.swift
//  PsyScopeEditor
//
//  Created by James on 09/11/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

//ensure the exectuion entries are ordered correctly
public func PSTidyUpExecutionEntries(scriptData : PSScriptData) {
    for (promptEntryName,logEntryName) in [("RunStart","LogRunStart"),("RunEnd","LogRunEnd")] {
        
        //for the log entry, determine if it is present
        var logEntryPresent = false
        if let logEntry = scriptData.getBaseEntry(logEntryName) {
            let logEntryList = PSStringList(entry: logEntry, scriptData: scriptData)
            if logEntryList.count == 0 {
                //if there is no logging, remove from script
                scriptData.deleteBaseEntry(logEntry)
                scriptData.removeItemFromBaseList(promptEntryName, item: logEntryName)
            } else {
                logEntryPresent = true
            }
        }
        
        //if the log entry is present get the prompt entry (if not only get if the prompt entry exists)
        let promptEntry = logEntryPresent ? scriptData.getOrCreateBaseEntry(promptEntryName, type: PSType.ExecutionEntry) : scriptData.getBaseEntry(promptEntryName)
        
        if let promptEntry = promptEntry {
            
            //remove the prompt entry (if there is also no log entry)
            let promptEntryList = PSStringList(entry: promptEntry, scriptData: scriptData)
            if promptEntryList.count == 0 && !logEntryPresent {
                //if there is no prompts or logging delete the prompt entry
                scriptData.deleteBaseEntry(promptEntry)
            }
            
            //move SubjectNumAndGroup to end
            if promptEntryList.contains("SubjectNumAndGroup") {
                promptEntryList.remove("SubjectNumAndGroup")
                promptEntryList.appendAsString("SubjectNumAndGroup")
            }
            
            //move autodatafile to end
            if promptEntryList.contains("AutoDataFile") {
                promptEntryList.remove("AutoDataFile")
                promptEntryList.appendAsString("AutoDataFile")
            }
            
            //move log file entry to end (or just remove if no logging
            promptEntryList.remove(logEntryName)
            if logEntryPresent {
                promptEntryList.appendAsString(logEntryName)
            }
        }
    }
    
    //if Menus entry is empty delete it
    if let menusEntry = scriptData.getBaseEntry("Menus") {
        let menusEntryList = PSStringList(entry: menusEntry, scriptData: scriptData)
        if menusEntryList.count == 0 {
            //if there is no logging, remove from script
            scriptData.deleteBaseEntry(menusEntry)
        }
    }
}