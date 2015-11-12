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
        typeString = "Variable"
        helpfulDescriptionString = "Named run-time variables that can be used to vary an event based on user inputs and/or previous trials in the experiment."
        iconName = "Variable-icon-small"
        iconColor = NSColor.blueColor()
        classNameString = "PSVariableTool"
        section = PSSections.VariableDefinitions
        properties = [Properties.VariableType]
        identityProperty = Properties.ExpVariables
    }
    
    struct Properties {
        static let ExpVariables = PSProperty(name: "ExpVariables", defaultValue: "")
        static let VariableType = PSProperty(name: "Type", defaultValue: "Integer", essential: true)
    }
    
    override func updateEntry(realEntry: Entry!, withGhostEntry ghostEntry: PSGhostEntry!, scriptData: PSScriptData!) {
        super.updateEntry(realEntry, withGhostEntry: ghostEntry, scriptData: scriptData)
    }
    
    override func appearsInToolMenu() -> Bool {
        return true
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
            scriptData.addDefaultProperty(property, entry: new_entry)
        }
        return new_entry
    }
    
    //variables dont have a layout object any more
    override func createObject(scriptData: PSScriptData!) -> Entry! {
        let new_entry = createMainVariableEntry(scriptData)
        
        //now have to update ExpVariables entry on main Experiment entry (if experiment entry is not there
        //failing gracefully
        if let experimentEntry = scriptData.getMainExperimentEntryIfItExists() {
            scriptData.addItemToAttributeList("ExpVariables", entry: experimentEntry, item: new_entry.name)
        }
        
        return new_entry
    }
    
    override func identifyEntries(ghostScript: PSGhostScript!) -> [AnyObject]!{
        var errors : [PSScriptError] = []
        errors += PSTool.identifyEntriesByPropertyInOtherEntry(ghostScript, property: Properties.ExpVariables, type: typeString) as [PSScriptError]
        
        return errors
    }    
    
    
    override func getPropertiesViewController(entry: Entry!, withScript scriptData: PSScriptData!) -> PSPluginViewController? {
        return PSVariablePropertiesController(entry: entry, scriptData: scriptData)
    }
    
}