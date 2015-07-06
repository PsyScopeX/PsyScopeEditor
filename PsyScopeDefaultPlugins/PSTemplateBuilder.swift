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
    
    func setup(scriptData: PSScriptData!, selectionInterface: AnyObject!) {
        self.scriptData = scriptData
        //load nib and gain access to views
        NSBundle(forClass:self.dynamicType).loadNibNamed("TemplateBuilder", owner: self, topLevelObjects: &topLevelObjects)
        //allow the layout controller to change currently selected object
        layoutController.scriptData = scriptData
        layoutController.selectionInterface = selectionInterface as! PSSelectionInterface
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        eventToolbarViewDelegate.setup(scriptData.pluginProvider)
    }
    
    
    func icon() -> NSImage! {
        return NSImage(contentsOfFile: NSBundle(forClass:self.dynamicType).pathForImageResource("flag86")!)! as NSImage
    }
        
    func identifier() -> String! {
        return "TemplateBuilder"
    }
    
  
        
    //returns a new tabview item for the central panel
    func midPanelTab() -> NSTabViewItem! {
        let tabViewItem = NSTabViewItem(identifier: "TemplateBuilderWindow")
        tabViewItem.view = midPanelView
        return tabViewItem
    }
    
    //returns a left panel item
    func leftPanelTab() -> NSTabViewItem! {
        let tabViewItem = NSTabViewItem(identifier: "EventsBrowser")
        tabViewItem.view = leftPanelView
        return tabViewItem
    }
    
    func refresh() {
        layoutController.refresh()
        popupButtonController.refreshTemplatePopUpButton()
        popupButtonController.updateSelection()
    }
    
    func entryDeleted(entry: Entry!) { }
    
    func type() -> String! {
        return "TemplateBuilder"
    }

}
