//
//  PSUpdateEntryWithGhostEntry.swift
//  PsyScopeEditor
//
//  Created by James on 12/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

public func PSUpdateEntryWithGhostEntry(realEntry: Entry!, ghostEntry: PSGhostEntry!, scriptData: PSScriptData!) {
    //use ghost entry to populate real entry stuff
    realEntry.name = ghostEntry.name
    realEntry.userFriendlyName = ghostEntry.name
    realEntry.currentValue = ghostEntry.currentValue
    realEntry.comments = ghostEntry.comments
    
    if (ghostEntry.type == "Property") {
        realEntry.type = ""
        realEntry.isProperty = true
    } else if (ghostEntry.type != "") {
        realEntry.type = ghostEntry.type
    }
    
    //only update attribute values + delete and reshuffle to ghost entry order
    //println("Updating attributes for \(ghostEntry.name)")
    //store list of subEntries
    let initial_sub_entries = realEntry.subEntries.array
    for ga in ghostEntry.subEntries {
        
        //for existing attributes, use existing type and property status
        if let existing_attribute = scriptData.getSubEntry(ga.name, entry: realEntry) {
            //exists
            //copy type
            ga.type = existing_attribute.type
            PSUpdateEntryWithGhostEntry(existing_attribute, ghostEntry: ga, scriptData: scriptData)
        } else {
            //is new
            let type = PSAttributeType(name: "", type: "")
            let new_attribute = scriptData.insertNewSubEntryForEntry(ga.name, entry: realEntry, type : type)
            new_attribute.isProperty = false //TODO
            PSUpdateEntryWithGhostEntry(new_attribute, ghostEntry: ga, scriptData: scriptData)
        }
        //for new attributes
        //need to determine type and if is a property
        //1. get list of properties for object
        //2. mark property attributes as so - properties are always known.  If not property, check if is a reserved base entry name. Three levels of known entry name:
        /*          a) property (an attribute specific to object)
        b) attribute (anything else - can be property name of other object)
        c) reserved name (cannot be an attribute name)
        */
        //3. get valid attributes for tool, mark them as type
        //4. for non valid attributes, get possibilities and offer dialog with suggestions
        
        //alternatively, types are a guess, and when confusion arises, then present dialog
    }
    
    //now delete all entries which are not there in new ghost entry
    for initial_entry in initial_sub_entries as! [Entry] {
        var entry_present = false
        for ga in ghostEntry.subEntries {
            if ga.name == initial_entry.name {
                entry_present = true
                break
            }
        }
        if !entry_present {
            scriptData.deleteSubEntryFromBaseEntry(realEntry, subEntry: initial_entry)
        }
        
    }
    
    ghostEntry.instantiated = true
}