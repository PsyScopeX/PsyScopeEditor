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
    public var inLogFile : Bool
    public var inDataFile : Bool
    public var schedule : PSSubjectVariableSchedule
    
    init(all : Bool) {
        self.inDataFile = all
        self.inLogFile = all
        if all {
            self.schedule = .RunStart
        } else {
            self.schedule = .Never
        }
    }
    
    init(inDataFileColumns : Bool, inDataFile : Bool, inLogFile : Bool, schedule : PSSubjectVariableSchedule) {
        self.inDataFile = inDataFile
        self.inLogFile = inLogFile
        self.schedule = schedule
    }
    
    
    
    func saveToScript(entry : Entry, scriptData : PSScriptData) {
        scriptData.beginUndoGrouping("Edit Subject Variable")
        let experimentEntry = scriptData.getMainExperimentEntry()
        
        
        
        //save to datafile by creating proxy entry
        var proxyEntryName = entry.name + "_Variable"
        if self.inDataFile {
            let expVariables = scriptData.getOrCreateSubEntry("ExpVariables", entry: experimentEntry, isProperty: true)
            let expVariablesList = PSStringList(entry: expVariables, scriptData: scriptData)
            
            if let proxyEntry = scriptData.createNewObjectFromTool("Variable") {
                scriptData.renameEntry(proxyEntry, nameSuggestion: proxyEntryName)
                proxyEntryName = proxyEntry.name
                if !expVariablesList.contains(proxyEntryName) {
                    expVariablesList.appendAsString(proxyEntryName)
                }
                let typeSubEntry = scriptData.getOrCreateSubEntry("Type", entry: proxyEntry, isProperty: true)
                typeSubEntry.currentValue = "String" //hopefully strings will work for everything?
                proxyEntry.currentValue = "@\(entry.name)"
            }
        } else if let expVariables = scriptData.getSubEntry("ExpVariables", entry: experimentEntry) {
            let expVariablesList = PSStringList(entry: expVariables, scriptData: scriptData)
            expVariablesList.remove(proxyEntryName)
            scriptData.deleteBaseEntryByName(proxyEntryName)
            if expVariablesList.count == 0 {
                scriptData.deleteSubEntryFromBaseEntry(experimentEntry, subEntry: expVariables)
            }
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
            let promptEntry = scriptData.getOrCreateBaseEntry(promptEntryName, type: "Logging", section: PSSections.LogFile)
            let promptEntryList = PSStringList(entry: promptEntry, scriptData: scriptData)
            if !promptEntryList.contains(entry.name){
                promptEntryList.appendAsString(entry.name) //shouldnt be at end but we sort that out afterwards
            }
        }
        
        //add to logging entry
        if inLogFile {
            let logEntry = scriptData.getOrCreateBaseEntry(logEntryName, type: "Logging", section: PSSections.LogFile)
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
        
        PSTidyUpExecutionEntries(scriptData)
        scriptData.endUndoGrouping()
        
    }

    
    //parse storage options from various entries in the script
    static func fromEntry(entry : Entry, scriptData : PSScriptData) -> PSSubjectVariableStorageOptions {
        var storageOptions = PSSubjectVariableStorageOptions(all: false)
        
        let experimentEntry = scriptData.getMainExperimentEntry()
        let proxyEntryName = entry.name + "_Variable"
        if let proxyEntry = scriptData.getBaseEntry(proxyEntryName),
            expVariables = scriptData.getSubEntry("ExpVariables", entry: experimentEntry) {
                let expVariablesList = PSStringList(entry: expVariables, scriptData: scriptData)
                
                let inList = expVariablesList.contains(proxyEntryName)
                let correctValue = proxyEntry.currentValue == "@\(entry.name)"
                storageOptions.inDataFile = inList && correctValue
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