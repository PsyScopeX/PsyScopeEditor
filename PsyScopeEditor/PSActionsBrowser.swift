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
    @IBOutlet var mainWindowController : PSMainWindowController!
    
    
    var actionsAttribute : PSEventActionsAttribute?
    var views : [Int : PSActionConditionView] = [ : ]
    var actionPicker : PSActionPicker?//remembering the picker to prevent xombie creation
    var conditionPicker : PSConditionPicker? //remembering the picker to prevent xombie creation
    var selectedActionCondition : PSEventActionCondition?
    var selectedEntry : Entry?
    var scriptData : PSScriptData!
    var selectionInterface : PSSelectionInterface!
    var displayViewMetaData : [PSActionBuilderViewMetaDataSet] = []
    
    let tableCellViewIdentifier : String = "PSActionConditionView"
    
    
    func setup(_ scriptData : PSScriptData) {
        //setup actions table view
        let nib = NSNib(nibNamed: "ActionConditionView", bundle: Bundle(for:type(of: self)))
        actionsTableView.register(nib!, forIdentifier: convertToNSUserInterfaceItemIdentifier(tableCellViewIdentifier))
        
        
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
        loadEvent()
        actionsTableView.reloadData()
    }
    
    func loadEvent() {
        
        if selectedEntry == nil {
            actionsSegmentedControl.isEnabled = false
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
        actionsSegmentedControl.isEnabled = true
    }
    
    //called from tableview objects containing actions/conditions
    func selectedActionCondition(_ actionCondition : PSEventActionCondition?, fromView : PSActionConditionView?) {
        
        selectedActionCondition = actionCondition
        
        //alter state of the action button
        actionsSegmentedControl.setEnabled((selectedActionCondition != nil), forSegment: 2)
        actionsSegmentedControl.setEnabled((selectedActionCondition == nil), forSegment: 1)
        
        if let selectedActionCondition = selectedActionCondition,
            let actionFunction = selectedActionCondition as? PSEventActionFunction {
                instancesActiveUntilMenuItem.isHidden = false
                if actionFunction.hasInstancesOrActiveUntilValueAttributes {
                    instancesActiveUntilMenuItem.state = NSOnState
                } else {
                    instancesActiveUntilMenuItem.state = NSOffState
                }
        } else {
            instancesActiveUntilMenuItem.isHidden = true
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
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if let aa = actionsAttribute {
            return aa.actionConditionSets.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let view = tableView.makeView(withIdentifier: convertToNSUserInterfaceItemIdentifier(tableCellViewIdentifier), owner: nil) as! PSActionConditionView
        
        view.actionsAttribute = self.actionsAttribute
        view.rowIndex = row
        view.actionsBrowser = self
        self.views[row] = view
        
        if row < displayViewMetaData.count{
            view.refresh(displayViewMetaData[row])
        } else {
            view.refresh(PSEmptyActionBuilderViewMetaDataSet)
        }

        return view
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        //get the height of the row
        var heightData : PSActionBuilderViewMetaDataSet
        
        if row < displayViewMetaData.count{
            heightData = displayViewMetaData[row]
        } else {
            heightData = PSEmptyActionBuilderViewMetaDataSet
        }
        
        return CGFloat(20) + heightData.actionsHeight + heightData.conditionsHeight
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
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
    
    @IBAction func actionsSegmentedControlClicked(_ sender : AnyObject) {
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
    
    func deleteActionCondition(_ actionCondition : PSEventActionCondition) {
        if let aa = actionsAttribute, let _ = aa.removeActionCondition(actionCondition) {
            updateEventActions()
            actionsSegmentedControl.setEnabled(false, forSegment: 1) //nothing selected when deleted
        }
        
    }
    
    //MARK: Actions from action menu
    
    @IBAction func toggleInstancesActiveUntil(_ sender : AnyObject) {
        if let selectedActionCondition = selectedActionCondition,
            let actionFunction = selectedActionCondition as? PSEventActionFunction {
                actionFunction.setInstancesActiveUntilOn(!actionFunction.hasInstancesOrActiveUntilValueAttributes)
                updateEventActions()
        }
        
    }
    
    @IBAction func deleteActionMenuClicked(_ sender : AnyObject) {
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSUserInterfaceItemIdentifier(_ input: String) -> NSUserInterfaceItemIdentifier {
	return NSUserInterfaceItemIdentifier(rawValue: input)
}
