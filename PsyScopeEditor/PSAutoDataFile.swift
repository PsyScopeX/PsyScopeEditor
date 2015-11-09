//
//  PSAutoDataFile.swift
//  PsyScopeEditor
//
//  Created by James on 09/11/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

class PSAutoDataFile {
    
    let scriptData : PSScriptData
    var subjectVariableNames : [String]
    
    init(scriptData : PSScriptData, subjectVariableNames : [String]) {
        self.scriptData = scriptData
        self.subjectVariableNames = subjectVariableNames
    }
    
    var auto : Bool {
        get {
            //get current value
            if let dataFileEntry = self.dataFileSubEntry where dataFileEntry.currentValue.lowercaseString == "@autodatafile" {
                return true
            }
            return false
        }
        
        set {
            let experimentEntry = scriptData.getMainExperimentEntry()
            let dataFile = scriptData.getOrCreateSubEntry("DataFile", entry: experimentEntry, isProperty: true)
            
            
            if newValue {
                //set datafile to the autoDataFile
                dataFile.currentValue = "@AutoDataFile"
                
                //Make AutoDataFile the run label
                let runLabel = scriptData.getOrCreateSubEntry("RunLabel", entry: experimentEntry, isProperty: true)
                if runLabel.currentValue != "AutoDataFile" { runLabel.currentValue = "AutoDataFile" }
                
                
                //Ensure that auto data file default setup is present
                let autoDatafile = scriptData.getOrCreateBaseEntry("AutoDataFile", type: "DialogVariable", user_friendly_name: "AutoDatafile", section_name: "SubjectInfo", zOrder: 78)
                let dialog = scriptData.getOrCreateSubEntry("Dialog", entry: autoDatafile, isProperty: true)
                scriptData.getOrCreateSubEntry("Strings", entry: autoDatafile, isProperty: true)
                let folder = scriptData.getOrCreateSubEntry("Folder", entry: autoDatafile, isProperty: true)
                let useDir = scriptData.getOrCreateSubEntry("UseDir", entry: autoDatafile, isProperty: true)
                
                if folder.currentValue != "" { folder.currentValue = "" }
                if useDir.currentValue != "FALSE" { useDir.currentValue = "FALSE" }
                if dialog.currentValue != "MakeFileName" { dialog.currentValue = "MakeFileName" }
                
                //Add to second last runStart (if logrunstart is there)
                let runStart = scriptData.getOrCreateBaseEntry("RunStart", type: "Logging", user_friendly_name: "RunStart", section_name: "LogFile", zOrder: 77)
                let runStartList = PSStringList(entry: runStart, scriptData: scriptData)
                runStartList.remove("AutoDataFile")
                if runStartList.contains("LogRunStart") {
                    let indexToInsert = max(runStartList.count - 1,0)
                    runStartList.insert("AutoDataFile", index: indexToInsert)
                } else {
                    runStartList.appendAsString("AutoDataFile")
                }

            } else {
                //Set datafile to default name
                dataFile.currentValue = "ExperimentData"
                
                //Remove runLabel attribute
                if let runLabel = scriptData.getSubEntry("RunLabel", entry: experimentEntry) {
                    scriptData.deleteSubEntryFromBaseEntry(experimentEntry, subEntry: runLabel)
                }
                
                //Delete AutoDataFile entry, replace with default
                if let autoDataFile = scriptData.getBaseEntry("AutoDataFile") {
                    scriptData.deleteBaseEntry(autoDataFile)
                    
                }
                
                //Remove from runStart
                if let runStartList = PSStringList(baseEntryName: "RunStart", scriptData: scriptData) {
                    runStartList.remove("AutoDataFile")
                }
            }
        }
    }
    
    var dataFileSubEntry : Entry? {
        get {
            guard let experimentsEntry = scriptData.getMainExperimentEntryIfItExists() else {
                return nil
            }
            return scriptData.getSubEntry("DataFile", entry: experimentsEntry)
        }
    }
    
    
    //the components that make the auto data file
    var autoDataFileElements : [String] {
        get {
            if !self.auto { //handle when data file is not auto generated
                guard let experimentEntry = scriptData.getMainExperimentEntryIfItExists() else { return [] }
                let dataFileEntry = scriptData.getOrCreateSubEntry("DataFile", entry: experimentEntry, isProperty: true)
                
                return [PSUnquotedString(dataFileEntry.currentValue)]
            }
            guard let autoDatafile = scriptData.getBaseEntry("AutoDataFile"),
                stringSubEntry = scriptData.getSubEntry("Strings", entry: autoDatafile) else { return [] }
            
            let strings = PSStringList(entry: stringSubEntry, scriptData: scriptData)
            var elementsToAdd : [String] = []
            
            for value in strings.values {
                switch(value) {
                case let .Function(functionElement):
                    if functionElement.values.count == 2 && functionElement.bracketType == .Expression {
                        let secondValue = functionElement.values[1]
                        if case .StringToken(let value) = secondValue {
                            elementsToAdd.append(value.value)
                        }
                    }
                    break
                case let .StringToken(stringValue):
                    elementsToAdd.append(stringValue.value)
                    break
                default:
                    break
                }
            }
  
            return elementsToAdd
        }
        
        set {
            if !self.auto { //handle when data file is not auto generated
                let dataFileName = newValue.joinWithSeparator(" ")
                let experimentsEntry = scriptData.getMainExperimentEntry()
                let dataFileEntry = scriptData.getOrCreateSubEntry("DataFile", entry: experimentsEntry, isProperty: true)
                dataFileEntry.currentValue = "\"\(dataFileName)\""
                return
            }
            
            guard let autoDatafile = scriptData.getBaseEntry("AutoDataFile"),
                stringSubEntry = scriptData.getSubEntry("Strings", entry: autoDatafile) else { return }
            
            
            //construct autodatafile->strings entry
            var previewString : [String] = []
            for token in newValue {
                //got a string object - need to check if its a variable - if so use it's current value
                if subjectVariableNames.contains(token) {
                    previewString.append("@\"\(token)\"")
                } else {
                    previewString.append("\"\(token)\"")
                }
            }
            
            let newStringsValue = previewString.joinWithSeparator(" ")
            print("Strings: " + newStringsValue)
            
            
            stringSubEntry.currentValue = newStringsValue

            //update current value
            autoDatafile.currentValue = generateCurrentDataFileName()
        }
    }

    
    func generateCurrentDataFileName() -> String {

        var previewString : String = ""
        for value in autoDataFileElements {
            //got a string object - need to check if its a variable - if so use it's current value
            if subjectVariableNames.contains(value) {
                //search for variable entry
                if let entry = scriptData.getBaseEntry(value) {
                    previewString += entry.currentValue
                } else {
                    previewString += "\(value)"
                }
                //insert current value of entry
            } else {
                previewString += value
            }
        }
        return previewString
    }
}