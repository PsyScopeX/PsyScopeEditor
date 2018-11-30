//
//  PSAutoDataFile.swift
//  PsyScopeEditor
//
//  Created by James on 09/11/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

/*
 * PSAutoDataFile: Controls updating the script to use the AutoDataFile entry (which allows the datafile name to be generated automatically)
 * Called from PSDataFileNameController.
 */
class PSAutoDataFile {
    
    //MARK: Dependencies
    
    let scriptData : PSScriptData
    
    //MARK: Variables
    
    var subjectVariableNames : [String]
    
    //MARK: Setup
    
    init(scriptData : PSScriptData, subjectVariableNames : [String]) {
        self.scriptData = scriptData
        self.subjectVariableNames = subjectVariableNames
    }
    
    //MARK: Auto
    
    //set whether the script is using autodatafile entry or not
    var auto : Bool {
        get {
            //get current value
            if let dataFileEntry = self.dataFileSubEntry, dataFileEntry.currentValue.lowercased() == "@autodatafile" {
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
                let autoDatafile = scriptData.getOrCreateBaseEntry("AutoDataFile", type: PSType.SubjectInfo)
                let dialog = scriptData.getOrCreateSubEntry("Dialog", entry: autoDatafile, isProperty: true)
                _ = scriptData.getOrCreateSubEntry("Strings", entry: autoDatafile, isProperty: true)
                let folder = scriptData.getOrCreateSubEntry("Folder", entry: autoDatafile, isProperty: true)
                let useDir = scriptData.getOrCreateSubEntry("UseDir", entry: autoDatafile, isProperty: true)
                
                if folder.currentValue != "" { folder.currentValue = "" }
                if useDir.currentValue != "FALSE" { useDir.currentValue = "FALSE" }
                if dialog.currentValue != "MakeFileName" { dialog.currentValue = "MakeFileName" }
                
                //Add to second last runStart (if logrunstart is there)
                let runStart = scriptData.getOrCreateBaseEntry("RunStart", type: PSType.ExecutionEntry)
                let runStartList = PSStringList(entry: runStart, scriptData: scriptData)
                runStartList.remove("AutoDataFile")
                runStartList.appendAsString("AutoDataFile")
                PSTidyUpExecutionEntries(scriptData)

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
                    if runStartList.count == 0 {
                        scriptData.deleteBaseEntryByName("RunStart")
                    }
                }
                
                PSTidyUpExecutionEntries(scriptData)
            }
        }
    }
    
    //MARK: DataFile sub entry
    
    var dataFileSubEntry : Entry? {
        get {
            guard let experimentsEntry = scriptData.getMainExperimentEntryIfItExists() else {
                return nil
            }
            return scriptData.getSubEntry("DataFile", entry: experimentsEntry)
        }
    }
    
    //MARK: AutoDataFile Elements
    
    //the components that make the content of the autodatafile
    var autoDataFileElements : [String] {
        get {
            if !self.auto { //handle when data file is not auto generated
                guard let experimentEntry = scriptData.getMainExperimentEntryIfItExists() else { return [] }
                let dataFileEntry = scriptData.getOrCreateSubEntry("DataFile", entry: experimentEntry, isProperty: true)
                
                return [PSUnquotedString(dataFileEntry.currentValue)]
            }
            guard let autoDatafile = scriptData.getBaseEntry("AutoDataFile"),
                let stringSubEntry = scriptData.getSubEntry("Strings", entry: autoDatafile) else { return [] }
            
            let strings = PSStringList(entry: stringSubEntry, scriptData: scriptData)
            var elementsToAdd : [String] = []
            
            for value in strings.values {
                switch(value) {
                case let .function(functionElement):
                    if functionElement.values.count == 2 && functionElement.bracketType == .expression {
                        let secondValue = functionElement.values[1]
                        if case .stringToken(let value) = secondValue {
                            elementsToAdd.append(value.value)
                        }
                    }
                    break
                case let .stringToken(stringValue):
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
                let dataFileName = newValue.joined(separator: " ")
                let experimentsEntry = scriptData.getMainExperimentEntry()
                let dataFileEntry = scriptData.getOrCreateSubEntry("DataFile", entry: experimentsEntry, isProperty: true)
                dataFileEntry.currentValue = "\"\(dataFileName)\""
                return
            }
            
            guard let autoDatafile = scriptData.getBaseEntry("AutoDataFile"),
                let stringSubEntry = scriptData.getSubEntry("Strings", entry: autoDatafile) else { return }
            
            
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
            
            let newStringsValue = previewString.joined(separator: " ")
            print("Strings: " + newStringsValue)
            
            
            stringSubEntry.currentValue = newStringsValue

            //update current value
            autoDatafile.currentValue = generateCurrentDataFileName()
        }
    }

    //MARK: Name Generation
    
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
