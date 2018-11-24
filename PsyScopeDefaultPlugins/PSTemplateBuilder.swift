//
//  PSTemplateBuilder.swift
//  PsyScopeEditor
//
//  Created by James on 05/09/2014.
//

import Cocoa


class PSTemplateBuilder: NSObject, PSWindowViewInterface {
    //before accessing any of the items, make sure to set up by passing scriptData
    var scriptData : PSScriptData!
    var templateEntry : Entry!
    
    @IBOutlet var midPanelView : NSView!
    @IBOutlet var leftPanelView : NSView!
    @IBOutlet var layoutController : PSTemplateLayoutBoardController!
    @IBOutlet var eventToolbarViewDelegate : PSEventBrowserViewDelegate!
    @IBOutlet var popupButtonController : PSTemplatePopupButtonController!
    
    var topLevelObjects : NSArray?
    
    func setup(_ scriptData: PSScriptData, selectionInterface: PSSelectionInterface) {
        self.scriptData = scriptData
        //load nib and gain access to views
        Bundle(for:type(of: self)).loadNibNamed("TemplateBuilder", owner: self, topLevelObjects: &topLevelObjects)
        //allow the layout controller to change currently selected object
        layoutController.scriptData = scriptData
        layoutController.selectionInterface = selectionInterface
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        eventToolbarViewDelegate.setup(scriptData.pluginProvider)
    }
    
    
    func icon() -> NSImage {
        return NSImage(contentsOfFile: Bundle(for:type(of: self)).pathForImageResource("flag86")!)!
    }
        
    func identifier() -> String {
        return "TemplateBuilder"
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
        layoutController.refresh()
        popupButtonController.refreshTemplatePopUpButton()
        popupButtonController.updateSelection()
    }
    
    func entryDeleted(_ entry: Entry) { }

}
