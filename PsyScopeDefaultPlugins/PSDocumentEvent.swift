//
//  PSDocumentEvent.swift
//  PsyScopeEditor
//
//  Created by James on 17/12/2014.
//

import Foundation

class PSDocumentEvent : PSEventTool {
    
    override init() {
        super.init()
        stimulusAttributeName = "Stimulus"
        typeString = "Document"
        helpfulDescriptionString = "displays text loaded from a file in a port.  You can change the colour, font and size of the text"
        iconName = "DocumentIcon"
        iconColor = NSColor.redColor()
        classNameString = "PSDocumentEvent"
        properties = [Properties.StartRef, Properties.Duration, Properties.EventType]
    }
    
    struct Properties {
        static let StartRef = PSProperty(name: "StartRef", defaultValue: PSDefaultConstants.DefaultAttributeValues.PSDefaultEventStartRef, essential: true);
        static let Duration = PSProperty(name: "Duration", defaultValue: PSDefaultConstants.DefaultAttributeValues.PSDocumentEventDuration, essential: true);
        static let EventType = PSProperty(name: "EventType", defaultValue: "Document", essential: true)
    }
    
    override func createObject(scriptData: PSScriptData!) -> Entry! {
        let mainEntry = super.createObject(scriptData)
        if scriptData.getSubEntry("Stimulus", entry: mainEntry) == nil {
            let entry = scriptData.getOrCreateSubEntry("Stimulus", entry: mainEntry, isProperty: false, type: PSAttributeType(name: "Stimulus", type: typeString))
            entry.currentValue = ""
        }
        
        if scriptData.getSubEntry("Port", entry: mainEntry) == nil {
            let entry = scriptData.getOrCreateSubEntry("Port", entry: mainEntry, isProperty: false, type: PSAttributeType(name: "Port", type: typeString))
            entry.currentValue = ""
        }
        
        return mainEntry
    }
}