//
//  PSActionsBrowser.swift
//  PsyScopeEditor
//
//  Created by James on 09/01/2015.
//

import Foundation

class PSActionsBrowser : NSObject, NSTableViewDataSource, NSTableViewDelegate {
    @IBOutlet var actionsTableView : NSTableView!
    @IBOutlet var actionsSegmentedControl : NSSegmentedControl!
    @IBOutlet var actionsMenu : NSMenu!
    @IBOutlet var actionsTypeMenu : NSMenu!
    @IBOutlet var instancesActiveUntilMenuItem : NSMenuItem!
    @IBOutlet var document : Document!
    
    
    var actionsAttribute : PSEventActionsAttribute?
    var views : [Int : PSActionConditionView] = [ : ]
    var actionPicker : PSActionPicker?//remembering the picker to prevent xombie creation
    var conditionPicker : PSConditionPicker? //remembering the picker to prevent xombie creation
    var selectedActionCondition : PSEventActionCondition?
    var selectedEntry : Entry?
    var scriptData : PSScriptData!
    var selectionInterface : PSSelectionInterface!
    var displayViewMetaData : [PSActionBuilderViewMetaDataSet]?
    
    let tableCellViewIdentifier : String = "PSActionConditionView"
    
    
    func setup(scriptData : PSScriptData) {
        //setup actions table view
        let nib = NSNib(nibNamed: "ActionConditionView", bundle: NSBundle(forClass:self.dynamicType))
        actionsTableView.registerNib(nib!, forIdentifier: tableCellViewIdentifier)
        
        
        //Set menu for actions button in segmented control
        actionsSegmentedControl.setMenu(actionsMenu, forSegment: 2)
        actionsSegmentedControl.setMenu(actionsTypeMenu, forSegment: 3)
        
        //if nothing selected don't allow the pressing of actions / delete button
        actionsSegmentedControl.setEnabled((selectedActionCondition != nil), forSegment: 2)
        actionsSegmentedControl.setEnabled(actionsTableView.selectedRow != -1, forSegment: 1)
        self.scriptData = scriptData
        self.selectionInterface = scriptData.selectionInterface
    }
    
    func refresh() {
        self.selectedEntry = selectionInterface.getSelectedEntry()
        self.views = [:]
        self.actionsAttribute = nil
        self.displayViewMetaData = nil
        loadEvent()
        actionsTableView.reloadData()
    }
    
    func loadEvent() {
        
        if selectedEntry == nil {
            actionsSegmentedControl.enabled = false
            return
        }
        
        
        guard let actionsAttribute = selectionInterface.getEventActionsAttribute() else {
            fatalError("Could not get event actions attribute")
        }
        
        guard let displayViewMetaData = selectionInterface.getActionConditionViewMetaData() else {
            fatalError("Could not get view meta data")
        }
        
        self.actionsAttribute = actionsAttribute
        self.displayViewMetaData = displayViewMetaData
        actionsSegmentedControl.setLabel(actionsAttribute.attributeName, forSegment: 3)
        actionsSegmentedControl.enabled = true
    }

    //called when an object is deleted
    func entryDeleted(entry : Entry) {
        
    }
    
    //called from tableview objects containing actions/conditions
    func selectedActionCondition(actionCondition : PSEventActionCondition?, fromView : PSActionConditionView?) {
        
        selectedActionCondition = actionCondition
        
        //alter state of the action button
        actionsSegmentedControl.setEnabled((selectedActionCondition != nil), forSegment: 2)
        actionsSegmentedControl.setEnabled((selectedActionCondition == nil), forSegment: 1)
        
        if let selectedActionCondition = selectedActionCondition,
            actionFunction = selectedActionCondition as? PSEventActionFunction {
                instancesActiveUntilMenuItem.hidden = false
                if actionFunction.hasInstancesOrActiveUntilValueAttributes {
                    instancesActiveUntilMenuItem.state = NSOnState
                } else {
                    instancesActiveUntilMenuItem.state = NSOffState
                }
        } else {
            instancesActiveUntilMenuItem.hidden = true
        }
        
        
        if fromView != nil {
            actionsTableView.deselectAll(self)
        }
        //deselect in all other tableviews
        for (_,view) in views {
            if (view != fromView) {
                view.deSelect()
            }
        }
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        if let aa = actionsAttribute {
            return aa.actionConditionSets.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let view = tableView.makeViewWithIdentifier(tableCellViewIdentifier, owner: nil) as! PSActionConditionView
        
        view.actionsAttribute = self.actionsAttribute
        view.rowIndex = row
        view.actionsBrowser = self
        self.views[row] = view
        
        view.refresh(self.displayViewMetaData![row])
        return view
    }
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        //get the height of the row
        if let displayViewMetaData = displayViewMetaData {
            let heightData = displayViewMetaData[row]
            return CGFloat(20) + heightData.actionsHeight + heightData.conditionsHeight
        } else {
            return 0
        }
    }
    
    func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        //tableViewSelectionIsChanging?
        selectedActionCondition(nil, fromView: nil)
        if row == -1 {
            actionsSegmentedControl.setEnabled(false, forSegment: 1)
        }
        
        return true
    }
    
    func updateEventActions() {
        if let aa = actionsAttribute {
            scriptData.beginUndoGrouping("Change Event Actions Attribute")
            aa.updateAttributeEntry()
            scriptData.endUndoGrouping(true)
        }
        
        actionsTableView.reloadData()
    }
    
    @IBAction func actionsSegmentedControlClicked(sender : AnyObject) {
        switch(actionsSegmentedControl.selectedSegment) {
        case 0:
            //add
            actionsAttribute?.newActionConditionSet()
            actionsTableView.reloadData()
        case 1:
            //remove
            actionsAttribute?.removeActionConditionSet(actionsTableView.selectedRow)
            updateEventActions()
            break
        default:
            break
        }
        
    }
    
    func deleteActionCondition(actionCondition : PSEventActionCondition) {
        if let aa = actionsAttribute, _ = aa.removeActionCondition(actionCondition) {
            updateEventActions()
            actionsSegmentedControl.setEnabled(false, forSegment: 1) //nothing selected when deleted
        }
        
    }
    
    //MARK: Actions from action menu
    
    @IBAction func toggleInstancesActiveUntil(sender : AnyObject) {
        if let selectedActionCondition = selectedActionCondition,
            actionFunction = selectedActionCondition as? PSEventActionFunction {
                actionFunction.setInstancesActiveUntilOn(!actionFunction.hasInstancesOrActiveUntilValueAttributes)
                updateEventActions()
        }
        
    }
    
    @IBAction func deleteActionMenuClicked(sender : AnyObject) {
        if let selectedActionCondition = selectedActionCondition {
            deleteActionCondition(selectedActionCondition)
        }
    }
    
    //MARK: Actions for chosing trial/event actions attribute
    
    @IBAction func eventActionsMenuClicked(_: AnyObject) {
        if let e = self.selectedEntry {
            e.metaData = "EventActions"
        }
    }


    @IBAction func trialActionsMenuClicked(_: AnyObject) {
        if let e = self.selectedEntry {
            e.metaData = "TrialActions"
        }
    }
}