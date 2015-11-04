//
//  PSActionPicker.swift
//  PsyScopeEditor
//
//  Created by James on 15/11/2014.
//

import Foundation
import Cocoa


public typealias PSActionPickerCallback = ((PSActionInterface) -> ())


//MARK: PSActionPicker

public class PSActionPicker: NSObject, NSOutlineViewDataSource, NSOutlineViewDelegate {
    
    public init(scriptData : PSScriptData, selectActionCallback : PSActionPickerCallback) {
        self.scriptData = scriptData
        self.selectActionCallback = selectActionCallback
        self.groups = PSActionPickerGroups(scriptData)
        super.init()
        NSBundle(forClass:self.dynamicType).loadNibNamed("ActionPicker", owner: self, topLevelObjects: &topLevelObjects)
    }
    
    //MARK: Variables / Constants
    
    let scriptData : PSScriptData
    let selectActionCallback : PSActionPickerCallback
    let tableCellViewIdentifier : String = "PSActionPickerCell"
    let groups : [PSActionPickerGroup]
    
    var topLevelObjects : NSArray?
    
    //MARK: Outlets
    
    @IBOutlet var actionOutlineView : NSOutlineView!
    @IBOutlet var popover : NSPopover!
    
    //MARK: Setup and start

    override public func awakeFromNib() {
        let nib = NSNib(nibNamed: "ActionPickerCell", bundle: NSBundle(forClass:self.dynamicType))
        actionOutlineView.registerNib(nib!, forIdentifier: tableCellViewIdentifier)
    }
    
    public func showActionWindow(view : NSView) {

        popover.showRelativeToRect(view.bounds, ofView: view, preferredEdge: NSRectEdge.MinX)
        actionOutlineView.reloadData()
        
        //always start expanded
        for group in groups {
            actionOutlineView.expandItem(group)
        }
    }
    

    //MARK: User interaction
    
    @IBAction func doneButtonClicked(sender : AnyObject) {
        popover.close()
    }
    
    func actionButtonClicked(action : PSActionPickerAction) {
        let tool = action.action
        selectActionCallback(tool)
    }

    //MARK: Outlineview

    public func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
    
        if (item == nil) {
            return groups.count
        }
        
        if let group = item as? PSActionPickerGroup {
            return group.actions.count
        }
        return 0
    }

    public func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        if (item == nil) {
            return groups[index]
        }
        if let group = item as? PSActionPickerGroup {
            return group.actions[index]
        }
        return ""
    }

    public func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
        if let group = item as? PSActionPickerGroup {
            if group.actions.count > 0 {
                return true
            }
        }
        return false
    }

    public func outlineView(outlineView: NSOutlineView, viewForTableColumn tableColumn: NSTableColumn?, item: AnyObject) -> NSView? {
        if let act = item as? PSActionPickerAction {
            let view = outlineView.makeViewWithIdentifier(tableCellViewIdentifier, owner: nil) as! PSActionPickerCell
            
            view.setup(act, clickCallback: actionButtonClicked)
            return view
        }
        if let group = item as? PSActionPickerGroup {
            let view = (outlineView.makeViewWithIdentifier(tableColumn!.identifier, owner: nil) as! NSTableCellView)
            view.textField?.stringValue = group.name
            return view
        }
        return nil
    }
    
    public func outlineView(outlineView: NSOutlineView, heightOfRowByItem item: AnyObject) -> CGFloat {
        if item is PSActionPickerAction {
            return 25
        } else {
            return 17
        }
        
    }
    
}

