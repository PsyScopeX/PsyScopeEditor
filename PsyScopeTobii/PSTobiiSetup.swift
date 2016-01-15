//
//  PSTobiiSetup.swift
//  PsyScopeEditor
//
//  Created by James on 15/01/2016.
//  Copyright © 2016 James. All rights reserved.
//

import Foundation

class PSTobiiSetup: NSObject, PSWindowViewInterface {
    //before accessing any of the items, make sure to set up by passing scriptData
    var scriptData : PSScriptData!
    var templateEntry : Entry!
    
    @IBOutlet var midPanelView : NSView!

    
    var topLevelObjects : NSArray?
    
    func setup(scriptData: PSScriptData, selectionInterface: PSSelectionInterface) {
        self.scriptData = scriptData
        //load nib and gain access to views
        NSBundle(forClass:self.dynamicType).loadNibNamed("PSTobiiSetup", owner: self, topLevelObjects: &topLevelObjects)
    }
    
    //return a tool bar item for the item
    func icon() -> NSImage {
        return NSImage(contentsOfFile: NSBundle(forClass:self.dynamicType).pathForImageResource("eye_watch")!)!
    }
    
    //return a tool bar item for the item
    func identifier() -> String {
        return "PSTobiiSetup"
    }
    
    //returns a new view for the central panel
    func midPanelTab() -> NSView {
        return midPanelView
    }
    
    //returns a view for the left panel item (optional)
    func leftPanelTab() -> NSView? {
        return nil
    }
    
    //called when an object is deleted
    func entryDeleted(entry : Entry) {
        
    }
    
    //called to refresh with selected object
    func refresh() {
        
    }
}