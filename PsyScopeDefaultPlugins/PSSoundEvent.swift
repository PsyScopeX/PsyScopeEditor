//
//  PSSoundEvent.swift
//  PsyScopeEditor
//
//  Created by James on 17/12/2014.
//

import Foundation

class PSSoundEvent : PSEventTool {
    
    override init() {
        super.init()
        stimulusAttributeName = "SoundFile"
        toolType = PSType.SoundLabel
        helpfulDescriptionString = "plays a sound loaded from a file."
        iconName = "SoundIcon"
        iconColor = NSColor.redColor()
        classNameString = "PSSoundEvent"
        properties = [Properties.StartRef, Properties.Duration, Properties.EventType]
    }
    
    struct Properties {
        static let StartRef = PSProperty(name: "StartRef", defaultValue: PSDefaultConstants.DefaultAttributeValues.PSDefaultEventStartRef, essential: true);
        static let Duration = PSProperty(name: "Duration", defaultValue: PSDefaultConstants.DefaultAttributeValues.PSSoundEventDuration, essential: true);
        static let EventType = PSProperty(name: "EventType", defaultValue: "SoundLabel", essential: true)
    }
    
    override func createObject(scriptData: PSScriptData!) -> Entry! {
        let mainEntry = super.createObject(scriptData)
        if scriptData.getSubEntry("SoundFile", entry: mainEntry) == nil {
            let entry = scriptData.getOrCreateSubEntry("SoundFile", entry: mainEntry, isProperty: false, type: PSAttributeType(name: "SoundFile", parentType: toolType))
            entry.currentValue = ""
        }
        return mainEntry
    }
}