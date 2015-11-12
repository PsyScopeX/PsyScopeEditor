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
    
    override init() {
        
        
        var legalEntries : [String] = ["RunStart", "RunEnd","LogRunStart", "LogRunEnd"]
        legalEntries += legalEntries.map({ "Log" + $0 })
        legalEntries += ["SubjectNumAndGroup", "AutoDataFile"]
        dialogEntryNames = legalEntries
        
        super.init()
        typeString = "DialogVariable"
        helpfulDescriptionString = "Named run-time variables that can open an input dialog at various points during the experiment lifecycle."
        iconName = "Variable-icon-small"
        iconColor = NSColor.blueColor()
        classNameString = "PSDialogVariableTool"
        section = PSSections.SubjectInfo // changing from SubjectVariables as this is not recognised by psyscope
        properties = [Properties.VariableType, Properties.Dialog]
        identityProperty = Properties.Dialog
        
        var illegalEntries : [String] = ["StartUp", "ExperimentStartUp", "PracticeStart", "PracticeEnd", "RunBreak", "PracticeBreak", "ExperimentClose", "Shutdown"]
        illegalEntries += illegalEntries.map({ "Log" + $0 })
        illegalEntryNames = illegalEntries
        
        reservedEntryNames = dialogEntryNames
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
    
    override func createObjectWithGhostEntries(entries: [AnyObject]!, withScript scriptData: PSScriptData!) -> [AnyObject]? {
        var return_array : [LayoutObject] = []
        for ent in entries {
            if let e = ent as? PSGhostEntry {
                let new_blank_obj = createMainVariableEntry(scriptData)
                updateEntry(new_blank_obj, withGhostEntry: e, scriptData: scriptData)
                
                if new_blank_obj.layoutObject != nil {
                    return_array.append(new_blank_obj.layoutObject)
                }
            }
        }
        return return_array
    }
    
    func createMainVariableEntry(scriptData : PSScriptData) -> Entry {
     let sect = scriptData.getOrCreateSection(section)
        
        //create main block entry
     let new_name = scriptData.getNextFreeBaseEntryName(typeString)
     let new_entry = scriptData.insertNewBaseEntry(new_name, type: typeString)
        
        sect.addObjectsObject(new_entry)
        new_entry.currentValue = "0"
        
        //now do properties
        for property in properties {
            scriptData.assertPropertyIsPresent(property, entry: new_entry)
        }
        return new_entry
    }
    
    //variables dont have a layout object any more
    override func createObject(scriptData: PSScriptData!) -> Entry! {
        let new_entry = createMainVariableEntry(scriptData)
        return new_entry
    }
    
    override func identifyEntries(ghostScript: PSGhostScript!) -> [AnyObject]!{
        var errors : [PSScriptError] = []
        errors += (PSTool.identifyEntriesByKeyAttribute(ghostScript, keyAttribute: "Dialog", type: typeString) as [PSScriptError])
        
        //now to identify all entries that are related to subject variables - and raise errors for illegal ones
        for entry in ghostScript.entries {
            if illegalEntryNames.contains(entry.name) {
                entry.type = typeString
                errors.append(PSIllegalScheduleEntry(entry.name,range: entry.range))
            } else if dialogEntryNames.contains(entry.name) {
                entry.type = typeString
            }
        }

        return errors
    }
    
    func PSIllegalScheduleEntry(nameOfIllegalEntry: NSString, range : NSRange) -> PSScriptError {
        let description = "The name for base entry: \(nameOfIllegalEntry):: is illegal."
        let solution = "Delete the entry named: \(nameOfIllegalEntry): and move the functionality elsewhere - you can schedule dialogs before running the experiment and after - but not other times."
        return PSScriptError(errorDescription: "Illegal Schedule Entry", detailedDescription: description, solution: solution, range: range)
    }
    
    
    override func getPropertiesViewController(entry: Entry!, withScript scriptData: PSScriptData!) -> PSPluginViewController? {
        return PSDialogVariablePropertiesController(entry: entry, scriptData: scriptData)
    }
    
}