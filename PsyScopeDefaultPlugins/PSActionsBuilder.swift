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
    
    override func setup(_ scriptData: PSScriptData, selectionInterface: PSSelectionInterface) {
        super.setup(scriptData, selectionInterface: selectionInterface)
        Bundle(for:type(of: self)).loadNibNamed("ActionsBuilder", owner: self, topLevelObjects: &topLevelObjects)
        layoutController.selectionInterface = selectionInterface
    }
    
    override func docMocChanged(_ notification : Notification) {
        layoutController.docMocChanged(notification)
    }
    
    override func entryDeleted(_ entry: Entry) {
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
    
    var topLevelObjects : NSArray = []
    
    func setup(_ scriptData: PSScriptData, selectionInterface: PSSelectionInterface) {
        self.scriptData = scriptData
        //load nib and gain access to views
    }
    
    func docMocChanged(_ notification : Notification) {
        
    }
    
    func icon() -> NSImage {
        return NSImage(contentsOfFile: Bundle(for:type(of: self)).pathForImageResource("hand225")!)! as NSImage
    }
    
    func identifier() -> String {
        return toolbarItemIdentifier
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
    
    func entryDeleted(_ entry: Entry) {
        
    }
    
}
