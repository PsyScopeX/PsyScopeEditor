//
//  PSConvertEvents.swift
//  PsyScopeEditor
//
//  Created by James on 04/12/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation


/**
 * PSConvertEvents: Sheet-style dialog for converting events from one type to another.  Activated in Layout editor, after right clicking on a selection of events.
 */
class PSConvertEvents : NSObject, NSTableViewDataSource, NSTableViewDelegate {
    

    //MARK: Outlets
    @IBOutlet var attributeSheet : NSWindow!
    @IBOutlet var eventsTableView : NSTableView!
    @IBOutlet var convertEventFromLabel : NSTextField!
    @IBOutlet var convertEventToLabel : NSTextField!
    @IBOutlet var convertAttributesController : PSConvertAttributesController!
    @IBOutlet var okButton : NSButton!
    
    //MARK: Variables
    
    let scriptData : PSScriptData
    let events : [Entry]
    var topLevelObjects : NSArray?
    var parentWindow : NSWindow!
    let eventTypes : [String]
    var selectedType : String
    
    //MARK: Setup
    
    init(scriptData : PSScriptData, events : [Entry]) {
        self.events = events
        self.scriptData = scriptData
        self.eventTypes = scriptData.pluginProvider.eventExtensions.map({ $0.type })
        self.selectedType = ""
        super.init()
    }
    
    
    override func awakeFromNib() {
        okButton.enabled = false
        if let type = events.first?.type {
            convertEventFromLabel.stringValue = "Convert event(s) of type: \(type)"
        } else {
            parentWindow.endSheet(attributeSheet)
        }
        
    }
    
    //MARK: Window Control
    
    func showAttributeModalForWindow(window : NSWindow) {
        if (attributeSheet == nil) {
            NSBundle(forClass: self.dynamicType).loadNibNamed("ConvertEvents", owner: self, topLevelObjects: &topLevelObjects)
        }
        
        parentWindow = window
        
        parentWindow.beginSheet(attributeSheet, completionHandler: {
            (response : NSModalResponse) -> () in
            
            //NSApp.stopModalWithCode(response)
        })
        
        //disabled to allow manageobjectcontext notifications
        //NSApp.runModalForWindow(attributeSheet)
    }
    
    
    //MARK: Datasource
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return eventTypes.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        return eventTypes[row]
    }
    
    //MARK: Delegate
    
    func tableView(tableView: NSTableView, selectionIndexesForProposedSelection proposedSelectionIndexes: NSIndexSet) -> NSIndexSet {
        let index = proposedSelectionIndexes.firstIndex
        let indexInRange = index > -1 && index < eventTypes.count
        if indexInRange {
            selectedType = eventTypes[index]
            convertEventToLabel.stringValue = "... to type:  \(selectedType)"
            okButton.enabled = true
        }
        return proposedSelectionIndexes
    }
    
    //MARK: Actions
    
    @IBAction func okButtonClicked(_: AnyObject) {
        
        //convert the events to the selectedType
        if eventTypes.contains(selectedType) {
            
            let plugin = scriptData.pluginProvider.eventPlugins[selectedType]!
            var success = true
            
            scriptData.beginUndoGrouping("Convert Events")
            let conversions = convertAttributesController.conversions
            for event in events {
                //change icon
                if let icon = PSPluginSingleton.sharedInstance.getIconForType(selectedType) where event.layoutObject != nil {
                    event.layoutObject.icon = icon
                }
                
                //change type
                event.type = plugin.type()
                
                //rename eventType
                if let eventTypeEntry = scriptData.getSubEntry("EventType", entry: event) {
                    eventTypeEntry.currentValue = plugin.type()
                }
                
                //now apply attribute renaming rules
                let attributeNames = scriptData.getSubEntryNames(event)
                for attributeName in attributeNames {
                    if let replacementName = conversions[attributeName],
                    subEntry = scriptData.getSubEntry(attributeName, entry: event)
                    {
                        //do replacement
                        success = success && scriptData.renameEntry(subEntry, nameSuggestion: replacementName)
                    }
                }
            }
            scriptData.endUndoGrouping(success)
            
            if !success {
                PSModalAlert("There was an error converting attribute names, please check your suggestions are legal")
            }
        }
        
        
        parentWindow.endSheet(attributeSheet)
    }
    
    @IBAction func closeMyCustomSheet(_: AnyObject) {
        parentWindow.endSheet(attributeSheet)
    }
    
}