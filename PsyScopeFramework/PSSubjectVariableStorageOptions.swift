//
//  PSSubjectVariableStorageOptions.swift
//  PsyScopeEditor
//
//  Created by James on 13/05/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

//Subject variables differ from regular variables, in that they are often linked to dialogs.  They often cannot be included in the datafile as columns, as PsyScopeX is fussy.  There is an option to create another variable which links to allow adding them though.
public struct PSSubjectVariableStorageOptions {
    public var inDataHeader : Bool
    public var inLogFile : Bool
    public var schedule : PSSubjectVariableSchedule
    
    init(all : Bool) {
        self.inDataHeader = all
        self.inLogFile = all
        if all {
            self.schedule = .RunStart
        } else {
            self.schedule = .Never
        }
    }
    
    init(inDataFileColumns : Bool, inDataHeader : Bool, inLogFile : Bool, schedule : PSSubjectVariableSchedule) {
        self.inDataHeader = inDataHeader
        self.inLogFile = inLogFile
        self.schedule = schedule
    }
    
    
    
    func saveToScript(entry : Entry, scriptData : PSScriptData) {
        scriptData.beginUndoGrouping("Edit Subject Variable")
        let experimentEntry = scriptData.getMainExperimentEntry()
            
        if inDataHeader {
            scriptData.addItemToAttributeList("DataHeader", entry: experimentEntry, item: entry.name)
        } else {
            scriptData.removeItemFromAttributeList("DataHeader", entry: experimentEntry, item: entry.name)
        }
        
        
        var promptEntryName : String?
        var logEntryName : String
        
        switch(schedule) {
        case .RunStart:
            promptEntryName = "RunStart"
            logEntryName = "LogRunStart"
            
            //remove all references in runend and logrunend
            scriptData.removeItemFromBaseList("LogRunEnd", item: entry.name)
            scriptData.removeItemFromBaseList("RunEnd", item: entry.name)
            
        case .RunEnd:
            promptEntryName = "RunEnd"
            logEntryName = "LogRunEnd"
            
            //remove all references in runstart and logrunstart
            scriptData.removeItemFromBaseList("LogRunStart", item: entry.name)
            scriptData.removeItemFromBaseList("RunStart", item: entry.name)
        case .Never:
            logEntryName = "LogRunEnd" //if logging is activated, always log at end
            
            //remove all references
            scriptData.removeItemFromBaseList("LogRunEnd", item: entry.name)
            scriptData.removeItemFromBaseList("RunEnd", item: entry.name)
            scriptData.removeItemFromBaseList("LogRunStart", item: entry.name)
            scriptData.removeItemFromBaseList("RunStart", item: entry.name)
        }
        
        //add to schedule
        if let promptEntryName = promptEntryName {
            let promptEntry = scriptData.getOrCreateBaseEntry(promptEntryName, type: "Logging", user_friendly_name: promptEntryName, section_name: "LogFile", zOrder: 77)
            let promptEntryList = PSStringList(entry: promptEntry, scriptData: scriptData)
            if !promptEntryList.contains(entry.name){
                promptEntryList.appendAsString(entry.name) //shouldnt be at end but we sort that out afterwards
            }
        }
        
        //add to logging entry
        if inLogFile {
            let logEntry = scriptData.getOrCreateBaseEntry(logEntryName, type: "Logging", user_friendly_name: logEntryName, section_name: "LogFile", zOrder: 77)
            let logRunList = PSStringList(entry: logEntry, scriptData: scriptData)
            var logRunArray = logRunList.stringListRawUnstripped
            if let stringName = PSStringElement(strippedValue: entry.name) {
                if !logRunArray.contains(stringName.quotedValue) {
                    logRunArray.append(stringName.quotedValue)
                    logRunList.stringListRawUnstripped = logRunArray
                }
            }
        } else {
            if let logEntry = scriptData.getBaseEntry(logEntryName) {
                let logRunStartList = PSStringList(entry: logEntry, scriptData: scriptData)
                logRunStartList.remove(entry.name)
            }
        }
        
        tidySubjectVariableEntries(scriptData)
        scriptData.endUndoGrouping()
        
    }
    
    func tidySubjectVariableEntries(scriptData : PSScriptData) {
        
        for (promptEntryName,logEntryName) in [("RunStart","LogRunStart"),("RunEnd","LogRunEnd")] {
            if let logEntry = scriptData.getBaseEntry(logEntryName) {
                let logEntryList = PSStringList(entry: logEntry, scriptData: scriptData)
                if logEntryList.count == 0 {
                    //if there is no logging, remove from script
                    scriptData.deleteBaseEntry(logEntry)
                    scriptData.removeItemFromBaseList(promptEntryName, item: logEntryName)
                } else {
                    //ensure that logging command is at end of prompt (and autoDatafile, one before that)
                    let promptEntry = scriptData.getOrCreateBaseEntry(promptEntryName, type: "Logging", user_friendly_name: promptEntryName, section_name: "LogFile", zOrder: 77)
                    let promptEntryList = PSStringList(entry: promptEntry, scriptData:  scriptData)
                    
                    
                    promptEntryList.remove(logEntryName)
                    promptEntryList.appendAsString(logEntryName)
                }
            }
            
            if let promptEntry = scriptData.getBaseEntry(promptEntryName) {
                let promptEntryList = PSStringList(entry: promptEntry, scriptData: scriptData)
                if promptEntryList.count == 0 {
                    //if there is no prompts or logging delete the prompt entry
                    scriptData.deleteBaseEntry(promptEntry)
                }
                
                //move autodatafile to end
                if promptEntryList.contains("AutoDataFile") {
                    promptEntryList.remove("AutoDataFile")
                    promptEntryList.appendAsString("AutoDataFile")
                }
            }
        }
    }
    
    //parse storage options from various entries in the script
    static func fromEntry(entry : Entry, scriptData : PSScriptData) -> PSSubjectVariableStorageOptions {
        var storageOptions = PSSubjectVariableStorageOptions(all: false)
        
        let experimentEntry = scriptData.getMainExperimentEntry()
        if let dataHeader = scriptData.getSubEntry("DataHeader", entry: experimentEntry) {
            let dataHeaderList = PSStringList(entry: dataHeader, scriptData: scriptData)
            storageOptions.inDataHeader = dataHeaderList.contains(entry.name)
        }
        
        if let runStart = scriptData.getBaseEntry("RunStart") {
            let runStartList = PSStringList(entry: runStart, scriptData: scriptData)
            if runStartList.contains(entry.name) {
                storageOptions.schedule = .RunStart
            }
        }
        
        if let logRunStart = scriptData.getBaseEntry("LogRunStart") {
            let logRunStartList = PSStringList(entry: logRunStart, scriptData: scriptData)
            storageOptions.inLogFile = logRunStartList.contains(entry.name)
        }
        
        if let runEnd = scriptData.getBaseEntry("RunEnd") {
            let runEndList = PSStringList(entry: runEnd, scriptData: scriptData)
            if runEndList.contains(entry.name) {
                storageOptions.schedule = .RunEnd
            }
        }
        
        if let logRunEnd = scriptData.getBaseEntry("LogRunEnd") {
            let logRunEndList = PSStringList(entry: logRunEnd, scriptData: scriptData)
            storageOptions.inLogFile = logRunEndList.contains(entry.name)
        }
        return storageOptions
    }
}