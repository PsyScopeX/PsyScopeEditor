//
//  PSPasteBoardEvent.swift
//  PsyScopeEditor
//
//  Created by James on 17/12/2014.
//

import Foundation

class PSPasteBoardEvent : PSEventTool {
    
    override init() {
        super.init()
        stimulusAttributeName = "Stimuli"
        toolType = PSType.PasteBoard
        helpfulDescriptionString = "presents a combination of screen sub-stimuli with many event types — Text, PICT, Document, and/or Paragraph — as a single event."
        iconName = "PasteBoardIcon"
        iconColor = NSColor.redColor()
        classNameString = "PSPasteBoardEvent"
        properties = [Properties.StartRef, Properties.Duration, Properties.EventType]
    }
    
    struct Properties {
        static let StartRef = PSProperty(name: "StartRef", defaultValue: PSDefaultConstants.DefaultAttributeValues.PSDefaultEventStartRef, essential: true);
        static let Duration = PSProperty(name: "Duration", defaultValue: PSDefaultConstants.DefaultAttributeValues.PSPasteBoardEventDuration, essential: true);
        static let EventType = PSProperty(name: "EventType", defaultValue: "PasteBoard", essential: true)
    }

    var allowedChildTypes : [String] = [PSTextEvent().type(), PSDocumentEvent().type(), PSParagraphEvent().type(), PSPictureEvent().type()]
    
    
    override func createObject(scriptData: PSScriptData) -> Entry? {
        guard let mainEntry = super.createObject(scriptData) else { return nil }
        if scriptData.getSubEntry("Stimuli", entry: mainEntry) == nil {
            let entry = scriptData.getOrCreateSubEntry("Stimuli", entry: mainEntry, isProperty: true)
            entry.currentValue = ""
        }
        
        if scriptData.getSubEntry("Port", entry: mainEntry) == nil {
            let entry = scriptData.getOrCreateSubEntry("Port", entry: mainEntry, isProperty: false, type: PSAttributeType(name: "Port", parentType: toolType))
            entry.currentValue = ""
        }

        
        return mainEntry
    }
    
    override func createLinkFrom(parent: Entry, to child: Entry, withScript scriptData: PSScriptData) -> Bool {
        
        //can link to text, document, paragraph and picture events, but attribute changes
        //from eventtype to stimtype
        if parent.type == self.type() {
            for allowedChild in allowedChildTypes {
                if child.type == allowedChild {
                    //create link return true
                    scriptData.createLinkFrom(parent, to: child, withAttribute: "Stimuli")
                    //change eventtype 
                    if let  eventType = scriptData.getSubEntry("EventType", entry: child) {
                        eventType.name = "StimType"
                    } else {
                        let stimType = scriptData.getOrCreateSubEntry("StimType", entry: child, isProperty: true)
                        if stimType.currentValue == "" {
                            stimType.currentValue = child.type
                        }
                    }
                    return true
                }
            }
        }
        
        return false
    }
    
    override func deleteLinkFrom(parent: Entry, to child: Entry, withScript scriptData: PSScriptData) -> Bool {
        
        scriptData.removeLinkFrom(parent, to: child, withAttribute: "Stimuli")
        if let  eventType = scriptData.getSubEntry("StimType", entry: child) {
            eventType.name = "EventType"
        } else {
            let stimType = scriptData.getOrCreateSubEntry("EventType", entry: child, isProperty: true)
            if stimType.currentValue == "" {
                stimType.currentValue = child.type
            }
        }
        return true
    }
    
    override func identifyEntries(ghostScript: PSGhostScript) -> [PSScriptError] {
        
        var errors : [PSScriptError] = super.identifyEntries(ghostScript)
        
        //we should aready here have identified which objects are pasteboards (from the above)
        
        //Identify links by Stimuli: attribute
        for ge in ghostScript.entries as [PSGhostEntry] {
            if ge.type == self.type() {
                for a in ge.subEntries as [PSGhostEntry] {
                    if (a.name == "Stimuli") {
                        //found an stimuli sub entry
                        let current_blocks = PSStringListCachedContainer()
                        current_blocks.stringValue = a.currentValue
                        for block_name in current_blocks.stringListLiteralsOnly {
                            if block_name != "" {
                                var found_block_name = false
                                for ge2 in ghostScript.entries as [PSGhostEntry] {
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
        }
        
        return errors
    }

}