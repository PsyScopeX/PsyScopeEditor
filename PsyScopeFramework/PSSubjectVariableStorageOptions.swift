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
            self.schedule = .runStart
        } else {
            self.schedule = .never
        }
    }
    
    init(inDataFileColumns : Bool, inDataFile : Bool, inLogFile : Bool, schedule : PSSubjectVariableSchedule) {
        self.inDataFile = inDataFile
        self.inLogFile = inLogFile
        self.schedule = schedule
    }
    
    
    
    func saveToScript(_ entry : Entry, scriptData : PSScriptData) {
        let experimentEntry = scriptData.getMainExperimentEntry()
        
        
        
        //save to datafile by creating proxy entry
        var proxyEntryName = entry.name + "_Variable"
        if self.inDataFile {
            let expVariables = scriptData.getOrCreateSubEntry("ExpVariables", entry: experimentEntry, isProperty: true)
            let expVariablesList = PSStringList(entry: expVariables, scriptData: scriptData)
            var proxyEntry : Entry!  = scriptData.getBaseEntry(proxyEntryName)
            
                
            if proxyEntry == nil {
                //need to create one
                proxyEntry = scriptData.createNewObjectFromTool(PSType.Variable)
                scriptData.renameEntry(proxyEntry, nameSuggestion: proxyEntryName)
                    
            }
                
            proxyEntryName = proxyEntry.name
            
                
            
            if !expVariablesList.contains(proxyEntryName) {
                expVariablesList.appendAsString(proxyEntryName)
            }
            let typeSubEntry = scriptData.getOrCreateSubEntry("Type", entry: proxyEntry, isProperty: true)
            typeSubEntry.currentValue = "String" //hopefully strings will work for everything?
            proxyEntry.currentValue = "@\(entry.name ?? "nil")"
            
            
            //also add to dataheader
            let dataHeader = scriptData.getOrCreateSubEntry("DataHeader", entry: experimentEntry, isProperty: true)
            let dataHeaderList = PSStringList(entry: dataHeader, scriptData: scriptData)
            if !dataHeaderList.contains(entry.name) {
                dataHeaderList.appendAsString(entry.name)
            }
        } else {
            
            if let expVariables = scriptData.getSubEntry("ExpVariables", entry: experimentEntry) {
                let expVariablesList = PSStringList(entry: expVariables, scriptData: scriptData)
                expVariablesList.remove(proxyEntryName)
                scriptData.deleteBaseEntryByName(proxyEntryName)
                if expVariablesList.count == 0 {
                    scriptData.deleteSubEntryFromBaseEntry(experimentEntry, subEntry: expVariables)
                }
            }
            
            //also remove from dataheader
            if let dataHeader = scriptData.getSubEntry("DataHeader", entry: experimentEntry) {
                let dataHeaderList = PSStringList(entry: dataHeader, scriptData: scriptData)
                dataHeaderList.remove(entry.name)
                if dataHeaderList.count == 0 {
                    scriptData.deleteSubEntryFromBaseEntry(experimentEntry, subEntry: dataHeader)
                }
            }
        }
        
        
        var promptEntryName : String?
        var logEntryName : String
        
        switch(schedule) {
        case .runStart:
            promptEntryName = "RunStart"
            logEntryName = "LogRunStart"
            
            //remove all references in runend and logrunend
            scriptData.removeItemFromBaseList("LogRunEnd", item: entry.name)
            scriptData.removeItemFromBaseList("RunEnd", item: entry.name)
            
        case .runEnd:
            promptEntryName = "RunEnd"
            logEntryName = "LogRunEnd"
            
            //remove all references in runstart and logrunstart
            scriptData.removeItemFromBaseList("LogRunStart", item: entry.name)
            scriptData.removeItemFromBaseList("RunStart", item: entry.name)
        case .never:
            logEntryName = "LogRunEnd" //if logging is activated, always log at end
            
            //remove all references
            scriptData.removeItemFromBaseList("RunEnd", item: entry.name)
            scriptData.removeItemFromBaseList("LogRunStart", item: entry.name)
            scriptData.removeItemFromBaseList("RunStart", item: entry.name)
        }
        
        //add to schedule
        if let promptEntryName = promptEntryName {
            let promptEntry = scriptData.getOrCreateBaseEntry(promptEntryName, type: PSType.ExecutionEntry)
            let promptEntryList = PSStringList(entry: promptEntry, scriptData: scriptData)
            if !promptEntryList.contains(entry.name){
                promptEntryList.appendAsString(entry.name) //shouldnt be at end but we sort that out afterwards
            }
        }
        
        //add to logging entry
        if inLogFile {
            let logEntry = scriptData.getOrCreateBaseEntry(logEntryName, type: PSType.SubjectInfo)
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
    }

    
    //parse storage options from various entries in the script
    static func fromEntry(_ entry : Entry, scriptData : PSScriptData) -> PSSubjectVariableStorageOptions {
        var storageOptions = PSSubjectVariableStorageOptions(all: false)
        
        let experimentEntry = scriptData.getMainExperimentEntry()
        let proxyEntryName = entry.name + "_Variable"
        if let proxyEntry = scriptData.getBaseEntry(proxyEntryName),
            let expVariables = scriptData.getSubEntry("ExpVariables", entry: experimentEntry) {
                let expVariablesList = PSStringList(entry: expVariables, scriptData: scriptData)
                
                let inList = expVariablesList.contains(proxyEntryName)
                let correctValue = proxyEntry.currentValue == "@\(entry.name ?? "nil")"
                storageOptions.inDataFile = inList && correctValue
        }

        
        if let runStart = scriptData.getBaseEntry("RunStart") {
            let runStartList = PSStringList(entry: runStart, scriptData: scriptData)
            if runStartList.contains(entry.name) {
                storageOptions.schedule = .runStart
                
                if let logRunStart = scriptData.getBaseEntry("LogRunStart") {
                    let logRunStartList = PSStringList(entry: logRunStart, scriptData: scriptData)
                    storageOptions.inLogFile = logRunStartList.contains(entry.name)
                }
            }
        }
        
        
        
        if let runEnd = scriptData.getBaseEntry("RunEnd") {
            let runEndList = PSStringList(entry: runEnd, scriptData: scriptData)
            if runEndList.contains(entry.name) {
                storageOptions.schedule = .runEnd
                
                if let logRunEnd = scriptData.getBaseEntry("LogRunEnd") {
                    let logRunEndList = PSStringList(entry: logRunEnd, scriptData: scriptData)
                    storageOptions.inLogFile = logRunEndList.contains(entry.name)
                }
            }
        }
        
        //also allow never variables to be in logRunEnd
        if let logRunEnd = scriptData.getBaseEntry("LogRunEnd"), storageOptions.schedule == .never {
            let logRunEndList = PSStringList(entry: logRunEnd, scriptData: scriptData)
            storageOptions.inLogFile = logRunEndList.contains(entry.name)
        }
        
        return storageOptions
    }
}
