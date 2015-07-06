//
//  PSKeySequenceEvent.swift
//  PsyScopeEditor
//
//  Created by James on 17/12/2014.
//

import Foundation

/*
A Key Sequence event is like a Paragraph event, except that the subject can type during the event (using the keyboard) and the typed characters are displayed after the prompt para- graph. You will usually set the duration of a key sequence to be Key[Return]; this way, the subject can type a response and terminate it by hitting the Return key.
The characters typed by a subject during a Key Sequence event are stored in a key se- quence buffer. The contents of this buffer can be recorded on every line of the data file by turning on Key sequence in the Data Info experiment attribute (see “ Data Info”, p161). The buffer is erased each time a Key Sequence event starts, and a character is added after every key press by the subject.
￼￼178
5.8.7 Event Attributes
The best way to record a Key Sequence response is to add an RT[] action to the event with the End condition. This way, the key sequence buffer contains the subject’s entire response when the RT is recorded.

*/

class PSKeySequenceEvent : PSEventTool {
    
    override init() {
        super.init()
        stimulusAttributeName = "Stimulus"
        typeString = "KeySequence"
        helpfulDescriptionString = "allows the participant to enter a series of keys, e.g. a word."
        iconName = "KeySequenceIcon"
        iconColor = NSColor.redColor()
        classNameString = "PSKeySequenceEvent"
        properties = [Properties.StartRef, Properties.Duration, Properties.EventType]
    }
    
    struct Properties {
        static let StartRef = PSProperty(name: "StartRef", defaultValue: PSDefaultConstants.DefaultAttributeValues.PSDefaultEventStartRef, essential: true);
        static let Duration = PSProperty(name: "Duration", defaultValue: PSDefaultConstants.DefaultAttributeValues.PSKeySequenceEventDuration, essential: true);
        static let EventType = PSProperty(name: "EventType", defaultValue: "KeySequence", essential: true)
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