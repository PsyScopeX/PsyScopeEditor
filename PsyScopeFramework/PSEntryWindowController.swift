//
//  PSEntryWindowController.swift
//  PsyScopeEditor
//
//  Created by James on 24/07/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

//window controller associated with an entry (will disapear if entry deleted)
public class PSEntryWindowController : NSWindowController, NSWindowDelegate {
    public var entry : Entry!
    public var scriptData : PSScriptData!
    
    public func setupWithEntryAndAddToDocument(entry : Entry, scriptData : PSScriptData) {
        self.entry = entry
        self.scriptData = scriptData
        scriptData.addWindowController(self)
        registeredForChanges = true
    }
    
    var registeredForChanges : Bool = false {
        willSet {
            if newValue != registeredForChanges {
                if newValue {
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: "docMocChanged:", name: NSManagedObjectContextObjectsDidChangeNotification, object: scriptData.docMoc)
                } else {
                    NSNotificationCenter.defaultCenter().removeObserver(self)
                }
            }
        }
    }
    
    public func docMocChanged(notification : NSNotification) {
        if entry.deleted == true || entry.currentValue == nil {
            registeredForChanges = false
            close()
        }
    }
    
    public func windowWillClose(notification: NSNotification) {
        registeredForChanges = false
        scriptData.removeWindowController(self)
    }
}