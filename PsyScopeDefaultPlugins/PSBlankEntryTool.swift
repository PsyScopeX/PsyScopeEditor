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
        typeString = "BlankEntry"
        helpfulDescriptionString = "Node for defining a blank Entry"
        iconName = "Question-icon"
        iconColor = NSColor.blueColor()
        classNameString = "PSBlankEntryTool"
        section = (name: "UndefinedEntries", zorder: 100)
    }
    
    override func appearsInToolMenu() -> Bool {
        return false
    }
    
    //dont create layout object for blank entry
    override func createObject(scriptData: PSScriptData!) -> Entry! {
        var sect = scriptData.getOrCreateSection(section.name, zOrder: section.zorder)
        
        //create main block entry
        var new_name = scriptData.getNextFreeBaseEntryName(typeString)
        var new_entry = scriptData.insertNewBaseEntry(new_name, type: typeString)
        
        sect.addObjectsObject(new_entry)
        return new_entry

    }
    
}