//
//  PSInputEvent.swift
//  PsyScopeEditor
//
//  Created by James on 17/12/2014.
//

import Foundation

class PSInputEvent : PSEventTool {
    
    override init() {
        super.init()
        stimulusAttributeName = ""
        typeString = "Input"
        helpfulDescriptionString = "used to demark a period of time to wait for input."
        iconName = "InputIcon"
        iconColor = NSColor.redColor()
        classNameString = "PSInputEvent"
        properties = [Properties.StartRef, Properties.Duration, Properties.EventType]
    }
    
    struct Properties {
        static let StartRef = PSProperty(name: "StartRef", defaultValue: PSDefaultConstants.DefaultAttributeValues.PSDefaultEventStartRef, essential: true);
        static let Duration = PSProperty(name: "Duration", defaultValue: PSDefaultConstants.DefaultAttributeValues.PSInputEventDuration, essential: true);
        static let EventType = PSProperty(name: "EventType", defaultValue: "Input", essential: true)
    }
}