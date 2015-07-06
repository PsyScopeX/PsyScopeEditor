//
//  PSActionConditionView.swift
//  PsyScopeEditor
//
//  Created by James on 13/11/2014.
//  Copyright (c) 2014 James. All rights reserved.
//

import Foundation

class PSActionConditionTableView : NSTableView {
    override func menuForEvent(event: NSEvent) -> NSMenu? {
        // what row are we at?
        var row = self.rowAtPoint(self.convertPoint(event.locationInWindow, fromView: nil))
        if (row != -1) {
            self.selectRowIndexes(NSIndexSet(index: row), byExtendingSelection: false)
            return super.menuForEvent(event)
        }
        return nil
    }
}

class PSActionConditionView: NSView, NSTableViewDelegate, NSTableViewDataSource {
    @IBOutlet var tableView : NSTableView!
    @IBOutlet var segmentedControl : NSSegmentedControl!
    
    var propertiesController : PSEventPropertiesController!
    var actionsAttribute : PSEventActionsAttribute!
    var rowIndex : Int = 0
    var actions : [PSEventAction] = []
    var conditions : [PSEventCondition] = []
    let actionCellViewIdentifier : String = "ActionCell"
    let conditionCellViewIdentifier : String = "ConditionCell"
    
    override func awakeFromNib() {
        self.addSubview(tableView)
        var anib = NSNib(nibNamed: "ActionCell", bundle: NSBundle(forClass: PSActionCell.self))
        tableView.registerNib(anib!, forIdentifier: actionCellViewIdentifier)
        var cnib = NSNib(nibNamed: "ConditionCell", bundle: NSBundle(forClass: PSConditionCell.self))
        tableView.registerNib(cnib!, forIdentifier: conditionCellViewIdentifier)
    }
    
    func refresh() {
        (conditions, actions) = actionsAttribute.actionConditionSets[rowIndex]
        
        var elements = actions.count + conditions.count
        var new_frame_height = PSDefaultConstants.Spacing.ACVToolbarHeight + elements * PSDefaultConstants.Spacing.ACVRowHeight
        var new_frame_size = self.frame.size
        new_frame_size.height = CGFloat(new_frame_height)
        self.frame.size = new_frame_size
        
        println(actionsAttribute.stringValue)
        
        tableView.reloadData()
        
    }
    
    func deSelect() {
        tableView.deselectAll(self)
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return actions.count + conditions.count
    }
    /*func tableView(tableView: NSTableView!, objectValueForTableColumn tableColumn: NSTableColumn!, row: Int) -> AnyObject! {
    var attribute_name : NSString = attributes[row].userFriendlyName
    println(attribute_name)
    return attribute_name
    }*/
   
    func actionConditionAt(row : Int) -> PSEventActionCondition {
        var isCondition = row < conditions.count
        if (isCondition) {
            return conditions[row]
        } else {
            return actions[row - conditions.count]
        }
    }
    
    @IBAction func editContextMenuClicked(sender : AnyObject) {
        propertiesController.editActionCondition(actionConditionAt(tableView.selectedRow))
    }
    
    @IBAction func deleteContextMenuClicked(sender : AnyObject) {
        propertiesController.deleteActionCondition(actionConditionAt(tableView.selectedRow))
    }
    
    func tableView(tableView: NSTableView!, viewForTableColumn tableColumn: NSTableColumn!, row: Int) -> NSView! {
        //determine wether it is action or condition
        var actionCondition = actionConditionAt(row)
        
        if let ac = actionCondition as? PSEventAction {
        
            var view = tableView.makeViewWithIdentifier(actionCellViewIdentifier, owner: self) as PSActionCell
            view.setup(ac.action)
            return view
        } else if let ec = actionCondition as? PSEventCondition {
            //is condition
            var view = tableView.makeViewWithIdentifier(conditionCellViewIdentifier, owner: self) as PSConditionCell
            view.setup(ec.condition)
            return view
        }
        return nil
    }
    
    func tableView(tableView: NSTableView!, heightOfRow row: Int) -> CGFloat {
        //get the height of the row
        return CGFloat(25)
    }
    
    func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        //tableViewSelectionIsChanging?
        propertiesController.selectedActionCondition(actionConditionAt(row), fromView: self)
        return true
    }
    
    @IBAction func actionsSegmentedControlClicked(sender : AnyObject) {
        switch(segmentedControl.selectedSegment) {
        case 0:
            //condition
            
            propertiesController.conditionPicker.selectConditionFunction = {
                (new_action : PSActionInterface, selected : Bool) -> () in
                if (selected) {
                    //append
                    self.actionsAttribute.appendCondition(self.rowIndex, condition: new_action)
                } else {
                    //remove
                    
                }
                self.propertiesController.updateEventActions()
                //this causes popover window to dissapear why?
                self.propertiesController.actionsTableView.reloadData()
                return
            }
            
            propertiesController.conditionPicker.showConditionWindow(propertiesController.scriptData, view: self, entryType: "", existingConditions: [])
            
            
        case 1:
            //action
           
            propertiesController.actionPicker.selectActionFunction = {
                (new_action : PSActionInterface, selected : Bool) -> () in
                if (selected) {
                    //append
                    self.actionsAttribute.appendAction(self.rowIndex, action: new_action)
                } else {
                    //remove
                }
                self.propertiesController.updateEventActions()
                //this causes popover window to dissapear why?
                self.propertiesController.actionsTableView.reloadData()
                return
            }
            
            propertiesController.actionPicker.showActionWindow(propertiesController.scriptData, view: self, entryType: "", existingActions: [])
            
        default:
            break
        }
        
        refresh()
    }
    
    
}