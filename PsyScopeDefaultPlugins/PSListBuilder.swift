//
//  PSListBuilder.swift
//  PsyScopeEditor
//
//  Created by James on 17/09/2014.
//


import Cocoa

class PSListBuilder: NSObject {
    
    @IBOutlet var window : NSWindow!
    @IBOutlet var controller : PSListBuilderTableController!
    
    var scriptData : PSScriptData
    var objects : NSArray?
    var listEntry : Entry
    
    init (scriptData : PSScriptData, listEntry : Entry) {
        self.scriptData = scriptData
        self.listEntry = listEntry
        super.init()
    }
    
    func showWindow() {
        NSBundle(forClass:self.dynamicType).loadNibNamed("ListBuilder", owner: self, topLevelObjects: &objects)
        window.title = "Edit List: \(listEntry.name)"
        window.releasedWhenClosed = true
        controller.registeredForChanges = true
        window.makeKeyAndOrderFront(self)
    }
    
    //make sure to degregister when window gets closed
    func deregister() {
        controller.registeredForChanges = false
    }

    func closeWindow() {
        deregister()
        window.close()
    }
}
