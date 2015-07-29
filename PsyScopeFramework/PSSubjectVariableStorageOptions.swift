//
//  PSSubjectVariableStorageOptions.swift
//  PsyScopeEditor
//
//  Created by James on 13/05/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

public struct PSSubjectVariableStorageOptions {
    public var inDataFileColumns : Bool
    public var inDataHeader : Bool
    public var inLogFile : Bool
    public var schedule : PSSubjectVariableSchedule
    
    init(all : Bool) {
        self.inDataFileColumns = all
        self.inDataHeader = all
        self.inLogFile = all
        if all {
            self.schedule = .RunStart
        } else {
            self.schedule = .Never
        }
    }
    
    init(inDataFileColumns : Bool, inDataHeader : Bool, inLogFile : Bool, schedule : PSSubjectVariableSchedule) {
        self.inDataFileColumns = inDataFileColumns
        self.inDataHeader = inDataHeader
        self.inLogFile = inLogFile
        self.schedule = schedule
    }
    
    func saveToScript(entry : Entry, scriptData : PSScriptData) {
        let eee = scriptData.getMainExperimentEntry()
            
        if inDataHeader {
            scriptData.addItemToAttributeList("DataHeader", entry: eee, item: entry.name)
        } else {
            scriptData.removeItemFromAttributeList("DataHeader", entry: eee, item: entry.name)
        }
        
        if inDataFileColumns {
            scriptData.addItemToAttributeList("DataVariables", entry: eee, item: entry.name)
        } else {
            scriptData.removeItemFromAttributeList("DataVariables", entry: eee, item: entry.name)
        }
        
        var promptEntryName : String?
        var logEntryName : String
        
        switch(schedule) {
        case .RunStart:
            promptEntryName = "RunStart"
            logEntryName = "LogRunStart"
            
            //remove all references in runend and logrunend
            if let logRunStart = scriptData.getBaseEntry("LogRunEnd") {
                let logRunStartList = PSStringList(entry: logRunStart, scriptData: scriptData)
                logRunStartList.remove(entry.name)
            }
            
            if let runStart = scriptData.getBaseEntry("RunEnd") {
                let runStartList = PSStringList(entry: runStart, scriptData: scriptData)
                runStartList.remove(entry.name)
            }
            
        case .RunEnd:
            promptEntryName = "RunEnd"
            logEntryName = "LogRunEnd"
            
            //remove all references in runstart and logrunstart
            if let logRunStart = scriptData.getBaseEntry("LogRunStart") {
                let logRunStartList = PSStringList(entry: logRunStart, scriptData: scriptData)
                logRunStartList.remove(entry.name)
            }
            
            if let runStart = scriptData.getBaseEntry("RunStart") {
                let runStartList = PSStringList(entry: runStart, scriptData: scriptData)
                runStartList.remove(entry.name)
            }
        case .Never:
            logEntryName = "LogRunStart" //if logging is activated, always log at start
            
            //remove all references in runend and logrunend
            if let logRunStart = scriptData.getBaseEntry("LogRunEnd") {
                let logRunStartList = PSStringList(entry: logRunStart, scriptData: scriptData)
                logRunStartList.remove(entry.name)
            }
            
            if let runStart = scriptData.getBaseEntry("RunEnd") {
                let runStartList = PSStringList(entry: runStart, scriptData: scriptData)
                runStartList.remove(entry.name)
            }
            //remove all references in runstart and logrunstart
            if let logRunStart = scriptData.getBaseEntry("LogRunStart") {
                let logRunStartList = PSStringList(entry: logRunStart, scriptData: scriptData)
                logRunStartList.remove(entry.name)
            }
            
            if let runStart = scriptData.getBaseEntry("RunStart") {
                let runStartList = PSStringList(entry: runStart, scriptData: scriptData)
                runStartList.remove(entry.name)
            }
        }
        
        //add to schedule
        if let promptEntryName = promptEntryName {
            
            let promptEntry = scriptData.getOrCreateBaseEntry(promptEntryName, type: "Logging", user_friendly_name: promptEntryName, section_name: "Log File", zOrder: 77)
            let scheduleList = PSStringList(entry: promptEntry, scriptData: scriptData)
            //need to ensure logging command as it at the end.
            scheduleList.remove(logEntryName)
            if !scheduleList.contains(entry.name) {
                scheduleList.appendAsString(entry.name)
            }
            scheduleList.appendAsString(logEntryName)
        }
        
        //add to logging entry
        if inLogFile {
            let logEntry = scriptData.getOrCreateBaseEntry(logEntryName, type: "Logging", user_friendly_name: logEntryName, section_name: "Log File", zOrder: 77)
            let logRunStartList = PSStringList(entry: logEntry, scriptData: scriptData)
            var logRunStartArray = logRunStartList.stringListRawUnstripped
            if let stringName = PSStringElement(strippedValue: entry.name) {
                if !logRunStartArray.contains(stringName.quotedValue) {
                    logRunStartArray.append(stringName.quotedValue)
                    logRunStartList.stringListRawUnstripped = logRunStartArray
                }
            }
        } else {
            if let logEntry = scriptData.getBaseEntry(logEntryName) {
                let logRunStartList = PSStringList(entry: logEntry, scriptData: scriptData)
                logRunStartList.remove(entry.name)
            }
        }
    }
    
    static func fromEntry(entry : Entry, scriptData : PSScriptData) -> PSSubjectVariableStorageOptions {
        var storageOptions = PSSubjectVariableStorageOptions(all: false)
        
        let eee = scriptData.getMainExperimentEntry()
        if let dataHeader = scriptData.getSubEntry("DataHeader", entry: eee) {
            let dataHeaderList = PSStringList(entry: dataHeader, scriptData: scriptData)
            storageOptions.inDataHeader = dataHeaderList.contains(entry.name)
        }
        
        if let dataVariables = scriptData.getSubEntry("DataVariables", entry: eee) {
            let dataVariablesList = PSStringList(entry: dataVariables, scriptData: scriptData)
            storageOptions.inDataFileColumns = dataVariablesList.contains(entry.name)
        }
        
        
        if let logRunStart = scriptData.getBaseEntry("LogRunStart") {
            let logRunStartList = PSStringList(entry: logRunStart, scriptData: scriptData)
            storageOptions.inLogFile = logRunStartList.contains(entry.name)
        }
        return storageOptions
    }
}