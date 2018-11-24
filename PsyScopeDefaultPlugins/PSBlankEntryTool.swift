//
//  PSBlankEntryTool.swift
//  PsyScopeEditor
//
//  Created by James on 13/08/2014.
//

import Cocoa

class PSBlankEntryTool: PSTool, PSToolInterface {
    
    override init() {
        super.init()
        toolType = PSType.UndefinedEntry
        helpfulDescriptionString = "Node for defining a blank Entry"
        iconName = "Question-icon"
        iconColor = NSColor.blue
        classNameString = "PSBlankEntryTool"
        section = PSSection.UndefinedEntries
    }
    
    override func appearsInToolMenu() -> Bool {
        return false
    }
    
    //dont create layout object for blank entry
    override func createObject(_ scriptData: PSScriptData) -> Entry? {
        let sect = scriptData.getOrCreateSection(section)
        
        //create main block entry
        let new_name = scriptData.getNextFreeBaseEntryName(toolType.name)
        let new_entry = scriptData.insertNewBaseEntry(new_name, type: toolType)
        
        sect.addObjectsObject(new_entry)
        return new_entry

    }
    
}
