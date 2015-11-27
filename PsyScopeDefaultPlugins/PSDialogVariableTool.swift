//
//  PSDialogTool.swift
//  PsyScopeEditor
//
//  Created by James on 28/04/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation


//These are variables that have a dialog property, that can be launched either as subject variables, or by menus
class PSDialogVariableTool: PSTool, PSToolInterface {
    
    let dialogEntryNames : [String]
    let executionEntryNames : [String]
    
    override init() {
        
        
        executionEntryNames = ["RunStart", "RunEnd"]
        dialogEntryNames = ["SubjectNumAndGroup", "AutoDataFile", "SubjectNumber", "SubjectName", ]

        
        super.init()
        toolType = PSType.SubjectInfo
        helpfulDescriptionString = "Named run-time variables that can open an input dialog at various points during the experiment lifecycle."
        iconName = "Variable-icon-small"
        iconColor = NSColor.blueColor()
        classNameString = "PSDialogVariableTool"
        section = PSSection.SubjectInfo // changing from SubjectVariables as this is not recognised by psyscope
        properties = [Properties.VariableType, Properties.Dialog]
        identityProperty = Properties.Dialog
        
        var illegalEntries : [String] = ["StartUp", "ExperimentStartUp", "PracticeStart", "PracticeEnd", "RunBreak", "PracticeBreak", "ExperimentClose", "Shutdown"]
        illegalEntries += illegalEntries.map({ "Log" + $0 })
        illegalEntryNames = illegalEntries
        
        reservedEntryNames = executionEntryNames
    }
    
    struct Properties {
        static let Dialog = PSProperty(name: "Dialog", defaultValue: "Standard", essential: true)
        static let VariableType = PSProperty(name: "Type", defaultValue: "Int", essential: false)
    }
    
    override func appearsInToolMenu() -> Bool {
        return false
    }
    
    override func canAddAttributes() -> Bool {
        return false
    }
    
    override func createObjectWithGhostEntries(entries: [PSGhostEntry], withScript scriptData: PSScriptData) -> [LayoutObject]? {
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
    
    func createMainVariableEntry(scriptData : PSScriptData) -> Entry {
     let sect = scriptData.getOrCreateSection(section)
        
        //create main block entry
     let new_name = scriptData.getNextFreeBaseEntryName(toolType.name)
     let new_entry = scriptData.insertNewBaseEntry(new_name, type: toolType)
        
        sect.addObjectsObject(new_entry)
        new_entry.currentValue = "0"
        
        //now do properties
        for property in properties {
            scriptData.assertPropertyIsPresent(property, entry: new_entry)
        }
        return new_entry
    }
    
    //variables dont have a layout object any more
    override func createObject(scriptData: PSScriptData) -> Entry? {
        return createMainVariableEntry(scriptData)
    }
    
    override func identifyEntries(ghostScript: PSGhostScript) -> [PSScriptError] {
        var errors : [PSScriptError] = []
        errors += (PSTool.identifyEntriesByKeyAttribute(ghostScript, keyAttribute: "Dialog", type: toolType) as [PSScriptError])
        
        //now to identify all entries that are related to subject variables - and raise errors for illegal ones
        for entry in ghostScript.entries {
            if illegalEntryNames.contains(entry.name) {
                entry.type = toolType.name
                errors.append(PSIllegalScheduleEntry(entry.name,range: entry.range))
            }
        }
        
        errors += PSTool.identifyEntriesByName(ghostScript, names: dialogEntryNames, type: toolType)
        errors += PSTool.identifyEntriesByName(ghostScript, names: executionEntryNames, type: PSType.ExecutionEntry)
        return errors
    }
    
    func PSIllegalScheduleEntry(nameOfIllegalEntry: NSString, range : NSRange) -> PSScriptError {
        let description = "The name for base entry: \(nameOfIllegalEntry):: is illegal."
        let solution = "Delete the entry named: \(nameOfIllegalEntry): and move the functionality elsewhere - you can schedule dialogs before running the experiment and after - but not other times."
        return PSScriptError(errorDescription: "Illegal Schedule Entry", detailedDescription: description, solution: solution, range: range)
    }
    
    
    override func getPropertiesViewController(entry: Entry, withScript scriptData: PSScriptData) -> PSPluginViewController? {
        return PSDialogVariablePropertiesController(entry: entry, scriptData: scriptData)
    }
    
}