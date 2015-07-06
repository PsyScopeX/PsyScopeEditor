//
//  PSMovieEvent.swift
//  PsyScopeEditor
//
//  Created by James on 17/12/2014.
//

import Foundation

class PSMovieEvent : PSEventTool {
    
    override init() {
        super.init()
        stimulusAttributeName = "Stimulus"
        typeString = "Movie"
        helpfulDescriptionString = "plays a movie loaded from a file."
        iconName = "MovieIcon"
        iconColor = NSColor.redColor()
        classNameString = "PSMovieEvent"
        properties = [Properties.StartRef, Properties.Duration, Properties.EventType]
    }
    
    struct Properties {
        static let StartRef = PSProperty(name: "StartRef", defaultValue: PSDefaultConstants.DefaultAttributeValues.PSDefaultEventStartRef, essential: true);
        static let Duration = PSProperty(name: "Duration", defaultValue: PSDefaultConstants.DefaultAttributeValues.PSMovieEventDuration, essential: true);
        static let EventType = PSProperty(name: "EventType", defaultValue: "Movie", essential: true)
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
        if scriptData.getSubEntry("MovieTag", entry: mainEntry) == nil {
            let entry = scriptData.getOrCreateSubEntry("Port", entry: mainEntry, isProperty: false, type: PSAttributeType(name: "Port", type: typeString))
            entry.currentValue = ""
        }

        return mainEntry
    }
}