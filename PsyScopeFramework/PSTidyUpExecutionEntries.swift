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
        
        let promptEntry = logEntryPresent ? scriptData.getOrCreateBaseEntry(promptEntryName, type: "Logging", user_friendly_name: promptEntryName, section_name: "LogFile", zOrder: 77) : scriptData.getBaseEntry(promptEntryName)
        
        if let promptEntry = promptEntry {
            let promptEntryList = PSStringList(entry: promptEntry, scriptData: scriptData)
            if promptEntryList.count == 0 {
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
}