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
        toolType = PSType.Movie
        helpfulDescriptionString = "plays a movie loaded from a file."
        iconName = "MovieIcon"
        iconColor = NSColor.red
        classNameString = "PSMovieEvent"
        properties = [Properties.StartRef, Properties.Duration, Properties.EventType]
    }
    
    struct Properties {
        static let StartRef = PSProperty(name: "StartRef", defaultValue: PSDefaultConstants.DefaultAttributeValues.PSDefaultEventStartRef, essential: false);
        static let Duration = PSProperty(name: "Duration", defaultValue: PSDefaultConstants.DefaultAttributeValues.PSMovieEventDuration, essential: true);
        static let EventType = PSProperty(name: "EventType", defaultValue: "Movie", essential: true)
    }
    
    override func createObject(_ scriptData: PSScriptData) -> Entry? {
        guard let mainEntry = super.createObject(scriptData) else { return nil }
        if scriptData.getSubEntry("Stimulus", entry: mainEntry) == nil {
            let entry = scriptData.getOrCreateSubEntry("Stimulus", entry: mainEntry, isProperty: false, type: PSAttributeType(name: "Stimulus", parentType: toolType))
            entry.currentValue = PSDefaultConstants.DefaultAttributeValues.PSAttribute_TextStimulus
        }
        
        if scriptData.getSubEntry("Port", entry: mainEntry) == nil {
            let entry = scriptData.getOrCreateSubEntry("Port", entry: mainEntry, isProperty: false, type: PSAttributeType(name: "Port", parentType: toolType))
            entry.currentValue = ""
        }
        if scriptData.getSubEntry("MovieTag", entry: mainEntry) == nil {
            let entry = scriptData.getOrCreateSubEntry("Port", entry: mainEntry, isProperty: false, type: PSAttributeType(name: "Port", parentType: toolType))
            entry.currentValue = ""
        }

        return mainEntry
    }
}
