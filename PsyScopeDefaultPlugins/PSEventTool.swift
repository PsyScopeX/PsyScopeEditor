//
//  PSEventTool.swift
//  PsyScopeEditor
//
//  Created by James on 19/08/2014.
//

import Cocoa


class PSEventTool: PSTool, PSToolInterface, PSEventInterface {
    
    
    override init() {
        stimulusAttributeName = ""
        super.init()
        typeString = "Event"
        helpfulDescriptionString = "Node for defining an event"
        iconName = "Timer-icon-128"//luca changed the icon
        iconColor = NSColor.redColor()
        classNameString = "PSEventTool"
        section = (name: "EventDefinitions", zorder: 6)
        identityProperty = Properties.Events
    }
    
    var stimulusAttributeName : String
    var mainStimulusAttributeName : String { get { return stimulusAttributeName } }

    
    struct Properties {
        static let Events = PSProperty(name: "Events", defaultValue: "")
    }
    
    override func identifyEntries(ghostScript: PSGhostScript!) -> [AnyObject]! {
        
        
        //1. identify events by eventType attribute
        var errors : [PSScriptError] = []
        
        for ge in ghostScript.entries {
            for a in ge.subEntries as [PSGhostEntry] {
                if ((a.name == "EventType" || a.name == "StimType") && a.currentValue == self.type()) {
                    //found an event of this type
                    if (ge.type.isEmpty || ge.type == self.type()) {
                        ge.type = self.type()
                    } else {
                        errors.append(PSErrorAmbiguousType(ge.name,type1: ge.type,type2: self.type(),range: ge.range))
                    }
                }
            }
        }
        
        //2. identify links by Events: attribute
        for ge in ghostScript.entries {
            for a in ge.subEntries {
                if (a.name == "Events") {
                    //found an events sub entry
                    let current_blocks = PSStringListCachedContainer()
                    current_blocks.stringValue = a.currentValue
                    for block_name in current_blocks.stringListLiteralsOnly {
                        if block_name != "" {
                            var found_block_name = false
                            for ge2 in ghostScript.entries {
                                if ge2.name == block_name {
                                    //found the block name, label it
                                    found_block_name = true
                                    ge.links.append(ge2)
                                }
                            }
                            
                            if (!found_block_name) {
                                errors.append(PSErrorEntryNotFound(block_name, parentEntry: ge.name, subEntry: a.name, range: ge.range))
                            }
                        }
                    }
                }
            }
        }
        
        return errors
    }
    
    override func getPropertiesViewController(entry: Entry!, withScript scriptData: PSScriptData!) -> PSPluginViewController? {
        //default show nil
        return PSEventPropertiesController(entry: entry, scriptData: scriptData)
        
    }

}
