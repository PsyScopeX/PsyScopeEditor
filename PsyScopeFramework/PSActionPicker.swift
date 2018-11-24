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

open class PSActionPicker: NSObject, NSOutlineViewDataSource, NSOutlineViewDelegate {
    
    public init(scriptData : PSScriptData, selectActionCallback : @escaping PSActionPickerCallback) {
        self.scriptData = scriptData
        self.selectActionCallback = selectActionCallback
        self.groups = PSActionPickerGroups(scriptData)
        super.init()
        Bundle(for:type(of: self)).loadNibNamed("ActionPicker", owner: self, topLevelObjects: &topLevelObjects)
    }
    
    //MARK: Variables / Constants
    
    let scriptData : PSScriptData
    let selectActionCallback : PSActionPickerCallback
    let tableCellViewIdentifier = NSUserInterfaceItemIdentifier(rawValue:"PSActionPickerCell")
    let groups : [PSActionPickerGroup]
    
    var topLevelObjects : NSArray?
    
    //MARK: Outlets
    
    @IBOutlet var actionOutlineView : NSOutlineView!
    @IBOutlet var popover : NSPopover!
    
    //MARK: Setup and start

    override open func awakeFromNib() {
        let nib = NSNib(nibNamed: "ActionPickerCell", bundle: Bundle(for:type(of: self)))
        actionOutlineView.register(nib!, forIdentifier:tableCellViewIdentifier)
    }
    
    open func showActionWindow(_ view : NSView) {

        popover.show(relativeTo: view.bounds, of: view, preferredEdge: NSRectEdge.minX)
        actionOutlineView.reloadData()
        
        //always start expanded
        for group in groups {
            actionOutlineView.expandItem(group)
        }
    }
    

    //MARK: User interaction
    
    @IBAction func doneButtonClicked(_ sender : AnyObject) {
        popover.close()
    }
    
    func actionButtonClicked(_ action : PSActionPickerAction) {
        let tool = action.action
        selectActionCallback(tool!)
    }

    //MARK: Outlineview

    open func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
    
        if (item == nil) {
            return groups.count
        }
        
        if let group = item as? PSActionPickerGroup {
            return group.actions.count
        }
        return 0
    }

    open func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if (item == nil) {
            return groups[index]
        }
        if let group = item as? PSActionPickerGroup {
            return group.actions[index]
        }
        return ""
    }

    open func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let group = item as? PSActionPickerGroup {
            if group.actions.count > 0 {
                return true
            }
        }
        return false
    }

    open func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        if let act = item as? PSActionPickerAction {
            let view = outlineView.makeView(withIdentifier:tableCellViewIdentifier, owner: nil) as! PSActionPickerCell
            
            view.setup(act, clickCallback: actionButtonClicked)
            return view
        }
        if let group = item as? PSActionPickerGroup {
            let view = (outlineView.makeView(withIdentifier: tableColumn!.identifier, owner: nil) as! NSTableCellView)
            view.textField?.stringValue = group.name
            return view
        }
        return nil
    }
    
    open func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        if item is PSActionPickerAction {
            return 25
        } else {
            return 17
        }
        
    }
    
}
