//
//  PSVariableTool.swift
//  PsyScopeEditor
//
//  Created by James on 30/01/2015.
//

import Foundation

class PSVariableTool: PSTool, PSToolInterface {
    
    override init() {
        super.init()
        toolType = PSType.Variable
        helpfulDescriptionString = "Named run-time variables that can be used to vary an event based on user inputs and/or previous trials in the experiment."
        iconName = "Variable-icon-small"
        iconColor = NSColor.blue
        classNameString = "PSVariableTool"
        section = PSSection.VariableDefinitions
        properties = [Properties.VariableType]
        identityProperty = Properties.ExpVariables
    }
    
    struct Properties {
        static let DataVariables = PSProperty(name: "DataVariables", defaultValue: "")
        static let ExpVariables = PSProperty(name: "ExpVariables", defaultValue: "")
        static let VariableType = PSProperty(name: "Type", defaultValue: "Integer", essential: true)
    }
    
    override func updateEntry(_ realEntry: Entry, withGhostEntry ghostEntry: PSGhostEntry, scriptData: PSScriptData) {
        super.updateEntry(realEntry, withGhostEntry: ghostEntry, scriptData: scriptData)
    }
    
    override func appearsInToolMenu() -> Bool {
        return true
    }
    
    override func canAddAttributes() -> Bool {
        return false
    }
    
    override func createObjectWithGhostEntries(_ entries: [PSGhostEntry], withScript scriptData: PSScriptData) -> [LayoutObject]? {
        var return_array : [LayoutObject] = []
        for ent in entries {

                let new_blank_obj = createMainVariableEntry(scriptData)
                updateEntry(new_blank_obj, withGhostEntry: ent, scriptData: scriptData)
                
                if new_blank_obj.layoutObject != nil {
                    return_array.append(new_blank_obj.layoutObject)
                }
            
        }
        return return_array
    }
    
    func createMainVariableEntry(_ scriptData : PSScriptData) -> Entry {
        let sect = scriptData.getOrCreateSection(section)
        
        //create main block entry
        let new_name = scriptData.getNextFreeBaseEntryName(toolType.name)
        let new_entry = scriptData.insertNewBaseEntry(new_name, type: toolType)
        
        sect.addObjectsObject(new_entry)
        new_entry.currentValue = "0"
        
        //now do properties
        for property in properties {
            scriptData.addDefaultProperty(property, entry: new_entry)
        }
        return new_entry
    }
    
    //variables dont have a layout object any more
    override func createObject(_ scriptData: PSScriptData) -> Entry? {
        let new_entry = createMainVariableEntry(scriptData)
        
        //now have to update ExpVariables entry on main Experiment entry (if experiment entry is not there
        //failing gracefully
        if let experimentEntry = scriptData.getMainExperimentEntryIfItExists() {
            scriptData.addItemToAttributeList("ExpVariables", entry: experimentEntry, item: new_entry.name)
        }
        
        return new_entry
    }
    
    override func identifyEntries(_ ghostScript: PSGhostScript) -> [PSScriptError]{
        var errors : [PSScriptError] = []
        errors += PSTool.identifyEntriesByPropertyInOtherEntry(ghostScript, property: Properties.ExpVariables, type: toolType) as [PSScriptError]
        
        
        //also check that only allowed types are in DataVariables
        for ge in ghostScript.entries as [PSGhostEntry] {
            for a in ge.subEntries as [PSGhostEntry] {
                if (a.name == "DataVariables") {
                    //found a sub entry with name of key attribute
                    let entry_content = PSStringListCachedContainer()
                    entry_content.stringValue = a.currentValue
                    let dataFileEntryNames : [String] = entry_content.stringListRawStripped
                    
                    //need to check that these entries (if variables are of the allowed type)
                    for dataFileEntryName in dataFileEntryNames {
                        for ghostEntry in ghostScript.entries {
                            if ghostEntry.name == dataFileEntryName && ghostEntry.type == toolType.name {
                                //found a variable now check its type sub entry
                                
                                for variableSubEntry in ghostEntry.subEntries {
                                    if variableSubEntry.name.lowercased() == "type" && !PSVariableTypesAllowedInDataFile.contains(variableSubEntry.currentValue) {
                                        //error
                                        errors.append(PSErrorVariableDataFile(ghostEntry.name, type: variableSubEntry.currentValue))
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return errors
    }    
    
    
    override func getPropertiesViewController(_ entry: Entry, withScript scriptData: PSScriptData) -> PSPluginViewController? {
        return PSVariablePropertiesController(entry: entry, scriptData: scriptData)
    }
    
}

public func PSErrorVariableDataFile(_ nameOfVariable: String, type : String) -> PSScriptError {
    let description = "The variable: " + nameOfVariable + " has a type " + type + " which is not allowed in the DataFile"
    let solution = "Remove the variable's name from the DataVariables entry"
    return PSScriptError(errorDescription: "DataVariables Error", detailedDescription: description, solution: solution, entryName: nameOfVariable)
}
