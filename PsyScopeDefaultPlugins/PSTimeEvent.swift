//
//  PSTimeEvent.swift
//  PsyScopeEditor
//
//  Created by James on 17/12/2014.
//

import Foundation

class PSTimeEvent : PSEventTool {
    
    override init() {
        super.init()
        stimulusAttributeName = ""
        toolType = PSType.NullEvent
        helpfulDescriptionString = "does nothing, but allows the passing of time."
        iconName = "Timer-icon-128" //icon changed by Luca
        iconColor = NSColor.redColor()
        classNameString = "PSTimeEvent"
        properties = [Properties.StartRef, Properties.Duration, Properties.EventType]
    }
    
    struct Properties {
        static let StartRef = PSProperty(name: "StartRef", defaultValue: PSDefaultConstants.DefaultAttributeValues.PSDefaultEventStartRef, essential: false);
        static let Duration = PSProperty(name: "Duration", defaultValue: PSDefaultConstants.DefaultAttributeValues.PSTimeEventDuration, essential: true);
        static let EventType = PSProperty(name: "EventType", defaultValue: "Null", essential: true)
    }
}