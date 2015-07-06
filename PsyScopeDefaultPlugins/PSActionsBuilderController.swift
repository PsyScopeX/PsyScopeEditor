//
//  PSActionsBuilderController.swift
//  PsyScopeEditor
//
//  Created by James on 03/12/2014.
//

import Foundation

class PSActionsBuilderController : NSObject, NSTableViewDataSource, NSTableViewDelegate {
    
    @IBOutlet var actionsBuilder : PSActionsBuilder!
    @IBOutlet var actionsMenu : NSMenu!
    @IBOutlet var actionsTableView : NSTableView!
    @IBOutlet var actionButton : NSPopUpButton!
    @IBOutlet var deleteButton : NSButton!
    @IBOutlet var addButton : NSButton!
    @IBOutlet var actionsTypePopup : NSPopUpButton!
    @IBOutlet var instancesActiveUntilMenuItem : NSMenuItem!
    
    var selectionInterface : PSSelectionInterface!
    var scriptData : PSScriptData!
    var actionsAttribute : PSEventActionsAttribute?
    let tableCellViewIdentifier : String = "PSActionsBuilderCell"
    var actionPicker : PSActionPicker? //to prevent zombie formation of popup
    var conditionPicker : PSConditionPicker? //to prevent zombie formation of popup
    var selectedActionCondition : PSEventActionCondition?
    var eventEntry : Entry?
    var templateEntries : [Entry] = []
    var views : [Int : PSActionsBuilderCell] = [ : ]
    
    var displayViewMetaData : [PSActionBuilderViewMetaDataSet] = []
    
    
    override func awakeFromNib() {
        scriptData = actionsBuilder.scriptData
        let nib = NSNib(nibNamed: "ActionsBuilderCell", bundle: NSBundle(forClass:self.dynamicType))
        actionsTableView.registerNib(nib!, forIdentifier: tableCellViewIdentifier)
        

        //if nothing selected don't allow the pressing of action button
        actionButton.enabled = (selectedActionCondition != nil)
        deleteButton.enabled = actionsTableView.selectedRow != -1

    }
    
    func docMocChanged(notification : NSNotification) {
        loadEvent()
    }
    
    func entryDeleted(entry : Entry) {

    }
    
    func refresh() {
        //now can add actions to each type
        eventEntry = selectionInterface.getSelectedEntry()
        self.views = [:]
        loadEvent()
        actionsTableView.reloadData()
    }
    
    func loadEvent() {
        
        if eventEntry == nil {
            addButton.enabled = false
            actionsTableView.reloadData()
            return
        }
        
        
        guard let actionsAttribute = selectionInterface.getEventActionsAttribute() else {
            fatalError("Could not get event actions attribute")
        }
        
        self.actionsAttribute = actionsAttribute
        actionsTypePopup.selectItemWithTitle(actionsAttribute.attributeName)
        
        guard let displayViewMetaData = selectionInterface.getActionConditionViewMetaData() else {
            fatalError("Could not get view meta data")
        }
        
        
        self.displayViewMetaData = displayViewMetaData
        addButton.enabled = true
    }

    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        if let aa = actionsAttribute {
            return aa.actionConditionSets.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let view = tableView.makeViewWithIdentifier(tableCellViewIdentifier, owner: self) as! PSActionsBuilderCell
        view.controller = self
        view.actionsAttribute = self.actionsAttribute
        view.rowIndex = row
        self.views[row] = view
        
        if row < displayViewMetaData.count{
            view.refresh(displayViewMetaData[row])
        } else {
            view.refresh(PSEmptyActionBuilderViewMetaDataSet)
        }

        return view
    }
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        //get the height of the row (cannot get the exact view from this method)
        var heightData : PSActionBuilderViewMetaDataSet
        
        if row < displayViewMetaData.count{
            heightData = displayViewMetaData[row]
        } else {
            heightData = PSEmptyActionBuilderViewMetaDataSet
        }
        return CGFloat(10) + max(heightData.actionsHeight, heightData.conditionsHeight)
    }
    
    func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        ////tableViewSelectionIsChanging?
        selectedActionCondition(nil, fromView: nil)
        if row == -1 {
            //deleteButton.enabled = false
        }
        
        return true
    }
    
    func selectedActionCondition(actionCondition : PSEventActionCondition?, fromView : PSActionsBuilderCell?) {
        selectedActionCondition = actionCondition
        //alter state of the action button
        actionButton.enabled = (selectedActionCondition != nil)
        //deleteButton.enabled = (selectedActionCondition == nil)
        
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
    
    
    func deleteActionCondition(actionCondition : PSEventActionCondition) {
        if let aa = actionsAttribute, _ = aa.removeActionCondition(actionCondition) {
            deleteButton.enabled = false //nothing selected when deleted
        }
        
    }
    
    //MARK: Action button
    
    @IBAction func deleteActionMenuClicked(sender : AnyObject) {
        if let s = selectedActionCondition {
            deleteActionCondition(s)
        }
    }
    
    @IBAction func toggleInstancesActiveUntil(sender : AnyObject) {
        if let selectedActionCondition = selectedActionCondition,
            actionFunction = selectedActionCondition as? PSEventActionFunction {
                actionFunction.setInstancesActiveUntilOn(!actionFunction.hasInstancesOrActiveUntilValueAttributes)
                self.actionsAttribute!.updateAttributeEntry()
        }
    }
    
    //MARK: Add / Delete Button
    
    @IBAction func addActionButton(sender : AnyObject) {
        actionsAttribute?.newActionConditionSet()
        actionsTableView.reloadData()
    }
    
    @IBAction func deleteActionButton(sender : AnyObject) {
        actionsAttribute?.removeActionConditionSet(actionsTableView.selectedRow)
    }
    
    //MARK: Actions for chosing trial/event actions attribute
    
    @IBAction func eventActionsMenuClicked(AnyObject) {
        if let e = self.eventEntry {
            e.metaData = "EventActions"
            loadEvent()
        }
    }
    
    
    @IBAction func trialActionsMenuClicked(AnyObject) {
        if let e = self.eventEntry {
            e.metaData = "TrialActions"
            loadEvent()
        }
    }

}