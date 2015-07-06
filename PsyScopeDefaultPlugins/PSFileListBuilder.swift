//
//  PSFileListBuilder.swift
//  PsyScopeEditor
//
//  Created by James on 27/05/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSFileListBuilder: NSObject {
    
    @IBOutlet var window : NSWindow!
    @IBOutlet var controller : PSListBuilderTableController!
    
    var scriptData : PSScriptData
    var objects : NSArray?
    var listEntry : Entry
    
    init (scriptData : PSScriptData, listEntry : Entry) {
        print("init filelistbuilder")
        self.scriptData = scriptData
        self.listEntry = listEntry
        super.init()
    }
    
    func showWindow() {
        print("show window filelistbuilder")
        NSBundle(forClass:self.dynamicType).loadNibNamed("FileListBuilder", owner: self, topLevelObjects: &objects)
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