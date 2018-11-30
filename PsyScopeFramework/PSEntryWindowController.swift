//
//  PSEntryWindowController.swift
//  PsyScopeEditor
//
//  Created by James on 24/07/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

//window controller associated with an entry (will disapear if entry deleted)
open class PSEntryWindowController : NSWindowController, NSWindowDelegate {
    public var entry : Entry!
    public var scriptData : PSScriptData!
    
    public func setupWithEntryAndAddToDocument(_ entry : Entry, scriptData : PSScriptData) {
        self.entry = entry
        self.scriptData = scriptData
        scriptData.addWindowController(self)
        registeredForChanges = true
    }
    
    var registeredForChanges : Bool = false {
        willSet {
            if newValue != registeredForChanges {
                if newValue {
                    NotificationCenter.default.addObserver(self, selector: #selector(PSEntryWindowController.docMocChanged(_:)), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: scriptData.docMoc)
                } else {
                    NotificationCenter.default.removeObserver(self)
                }
            }
        }
    }
    
    @objc open func docMocChanged(_ notification : Notification) {
        if entry.isDeleted == true || entry.currentValue == nil {
            registeredForChanges = false
            close()
            return
        }
    }
    
    public func windowWillClose(_ notification: Notification) {
        registeredForChanges = false
        scriptData.removeWindowController(self)
    }
}
