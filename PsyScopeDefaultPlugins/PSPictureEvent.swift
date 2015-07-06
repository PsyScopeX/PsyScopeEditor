//
//  PSPictureEvent.swift
//  PsyScopeEditor
//
//  Created by James on 04/11/2014.
//

import Foundation

class PSPictureEvent : PSEventTool {
    
    override init() {
        super.init()
        stimulusAttributeName = "Stimulus"
        typeString = "Pict"
        helpfulDescriptionString = "displays an image in a port.  You can change the way the orientation of the picture and other attributes."
        iconName = "PictureEvent-icon-128" // Modified by Luca on Nov 24 014
        iconColor = NSColor.redColor()
        classNameString = "PSPictureEvent"
        properties = [Properties.StartRef, Properties.Duration, Properties.EventType]
    }
    
    struct Properties {
        static let StartRef = PSProperty(name: "StartRef", defaultValue: PSDefaultConstants.DefaultAttributeValues.PSDefaultEventStartRef, essential: true);
        static let Duration = PSProperty(name: "Duration", defaultValue: PSDefaultConstants.DefaultAttributeValues.PSPictureEventDuration, essential: true);
        static let EventType = PSProperty(name: "EventType", defaultValue: "Picture", essential: true)
    }

    
    override func validDraggedFileExtensions() -> [AnyObject]! {
        return ["png","bmp","jpg","jpeg","tif","tiff"]
    }
    
    override func createFromDraggedFile(fileName : String!, scriptData: PSScriptData!) -> Entry! {
        let mainEntry = self.createObject(scriptData)
        var new_name = fileName.lastPathComponent.stringByDeletingPathExtension
        
        //delete non alphanumerics
        let deleteCharacters = NSCharacterSet.alphanumericCharacterSet().invertedSet
        new_name = (new_name.componentsSeparatedByCharactersInSet(deleteCharacters) as NSArray).componentsJoinedByString("")
        
        new_name = scriptData.getNextFreeBaseEntryName(new_name)
        mainEntry.name = new_name
        let att = scriptData.getOrCreateSubEntry("Stimulus", entry: mainEntry, isProperty: false, type: PSAttributeType(name: "Stimulus", type: typeString))
        att.currentValue = "\"\(PSPath(fileName, basePath: scriptData.documentDirectory()!))\""
        return mainEntry
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