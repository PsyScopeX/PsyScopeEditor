//
//  PSTextEvent.swift
//  PsyScopeEditor
//
//  Created by James on 05/09/2014.
//

import Foundation

class PSTextEvent : PSEventTool {
    
    override init() {
        super.init()
        stimulusAttributeName = "Stimulus"
        typeString = "Text"
        helpfulDescriptionString = "displays text in a port.  You can change the colour, font, size and position of the text"
        iconName = "TextEvent-icon-128" //icon changed by Luca
        iconColor = NSColor.redColor()
        classNameString = "PSTextEvent"
        properties = [Properties.StartRef, Properties.Duration, Properties.EventType]
        
    }
    
    
    
    struct Properties {
        static let StartRef = PSProperty(name: "StartRef", defaultValue: PSDefaultConstants.DefaultAttributeValues.PSDefaultEventStartRef, essential: true);
        static let Duration = PSProperty(name: "Duration", defaultValue: PSDefaultConstants.DefaultAttributeValues.PSTextEventDuration, essential: true);
        static let EventType = PSProperty(name: "EventType", defaultValue: "Text", essential: true)
    }
    
    override func createObject(scriptData: PSScriptData!) -> Entry! {
        let mainEntry = super.createObject(scriptData)
        if scriptData.getSubEntry("Stimulus", entry: mainEntry) == nil {
            let entry = scriptData.getOrCreateSubEntry("Stimulus", entry: mainEntry, isProperty: false, type: PSAttributeType(name: "Stimulus", type: typeString))
            entry.currentValue = PSDefaultConstants.DefaultAttributeValues.PSAttribute_TextStimulus
        }
        
        if scriptData.getSubEntry("Port", entry: mainEntry) == nil {
            let entry = scriptData.getOrCreateSubEntry("Port", entry: mainEntry, isProperty: false, type: PSAttributeType(name: "Port", type: typeString))
            entry.currentValue = ""
        }
        return mainEntry
    }
}