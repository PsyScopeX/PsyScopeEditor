//
//  PSParagraphEvent.swift
//  PsyScopeEditor
//
//  Created by James on 17/12/2014.
//

import Foundation

class PSParagraphEvent : PSEventTool {
    
    override init() {
        super.init()
        stimulusAttributeName = "Stimulus"
        toolType = PSType.Paragraph
        helpfulDescriptionString = "displays a paragraph of text in a port.  You can change the colour, font, size and position of the text"
        iconName = "ParagraphIcon" 
        iconColor = NSColor.redColor()
        classNameString = "PSParagraphEvent"
        properties = [Properties.StartRef, Properties.Duration, Properties.EventType]
    }
    
    struct Properties {
        static let StartRef = PSProperty(name: "StartRef", defaultValue: PSDefaultConstants.DefaultAttributeValues.PSDefaultEventStartRef, essential: false);
        static let Duration = PSProperty(name: "Duration", defaultValue: PSDefaultConstants.DefaultAttributeValues.PSParagraphEventDuration, essential: true);
        static let EventType = PSProperty(name: "EventType", defaultValue: "Paragraph", essential: true)
    }
    
    override func createObject(scriptData: PSScriptData) -> Entry? {
        guard let mainEntry = super.createObject(scriptData) else { return nil }
        if scriptData.getSubEntry("Stimulus", entry: mainEntry) == nil {
            let entry = scriptData.getOrCreateSubEntry("Stimulus", entry: mainEntry, isProperty: false, type: PSAttributeType(name: "Stimulus", parentType: toolType))
            entry.currentValue = PSDefaultConstants.DefaultAttributeValues.PSAttribute_ParagraphEventStimulus
        }
        
        if scriptData.getSubEntry("Port", entry: mainEntry) == nil {
            let entry = scriptData.getOrCreateSubEntry("Port", entry: mainEntry, isProperty: false, type: PSAttributeType(name: "Port", parentType: toolType))
            entry.currentValue = ""
        }
        
        return mainEntry
    }
}