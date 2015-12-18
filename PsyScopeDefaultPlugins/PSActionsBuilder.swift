//
//  PSActionsBuilder.swift
//  PsyScopeEditor
//
//  Created by James on 03/12/2014.
//

import Foundation

class PSActionsBuilder : PSWindowView {
    
    @IBOutlet var layoutController : PSActionsBuilderController!
    
    override init() {
        super.init()
        midPanelIdentifier = "ActionsBuilderWindow"
        leftPanelIdentifier = "ActionsBuilderToolbar"
        toolbarItemIdentifier = "ActionsBuilder"
    }
    
    override func setup(scriptData: PSScriptData, selectionInterface: PSSelectionInterface) {
        super.setup(scriptData, selectionInterface: selectionInterface)
        NSBundle(forClass:self.dynamicType).loadNibNamed("ActionsBuilder", owner: self, topLevelObjects: &topLevelObjects)
        layoutController.selectionInterface = selectionInterface
    }
    
    override func docMocChanged(notification : NSNotification) {
        layoutController.docMocChanged(notification)
    }
    
    override func entryDeleted(entry: Entry) {
        layoutController.entryDeleted(entry)
    }
    
    override func refresh() {
        layoutController.refresh()
    }
}

class PSWindowView: NSObject, PSWindowViewInterface {
    //before accessing any of the items, make sure to set up by passing scriptData
    var scriptData : PSScriptData!
    var templateEntry : Entry!
    var midPanelIdentifier : String = ""
    var leftPanelIdentifier : String = ""
    var toolbarItemIdentifier : String = ""
    
    
    
    @IBOutlet var midPanelView : NSView!
    @IBOutlet var leftPanelView : NSView!
    @IBOutlet var controller : PSActionsBuilderController!
    
    var topLevelObjects : NSArray?
    
    func setup(scriptData: PSScriptData, selectionInterface: PSSelectionInterface) {
        self.scriptData = scriptData
        //load nib and gain access to views
    }
    
    func docMocChanged(notification : NSNotification) {
        
    }
    
    func icon() -> NSImage {
        return NSImage(contentsOfFile: NSBundle(forClass:self.dynamicType).pathForImageResource("hand225")!)! as NSImage
    }
    
    func identifier() -> String {
        return "ActionsBuilder"
    }

    
    //returns a new tabview item for the central panel
    func midPanelTab() -> NSView {
        return midPanelView
    }
    
    //returns a left panel item
    func leftPanelTab() -> NSView? {
        return leftPanelView
    }
    
    func refresh() {
        fatalError("Not supposed to use this super class")
    }
    
    func entryDeleted(entry: Entry) {
        
    }
    
    func type() -> String {
        return toolbarItemIdentifier
    }
    
}