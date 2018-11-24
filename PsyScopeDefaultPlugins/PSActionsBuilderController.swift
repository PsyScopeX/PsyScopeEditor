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
    @IBOutlet var addButton : NSButton!
    @IBOutlet var actionsTypePopup : NSPopUpButton!
    
    @IBOutlet var instancesActiveUntilMenuItem : NSMenuItem!
    @IBOutlet var deleteSetMenuItem : NSMenuItem!
    @IBOutlet var deleteMenuItem : NSMenuItem!
    @IBOutlet var moveUpMenuItem : NSMenuItem!
    @IBOutlet var moveDownMenuItem : NSMenuItem!
    @IBOutlet var moveSetUpMenuItem : NSMenuItem!
    @IBOutlet var moveSetDownMenuItem : NSMenuItem!
    
    var selectionInterface : PSSelectionInterface!
    var scriptData : PSScriptData!
    var actionsAttribute : PSEventActionsAttribute?
    let tableCellViewIdentifier = NSUserInterfaceItemIdentifier(rawValue:"PSActionsBuilderCell")
    var actionPicker : PSActionPicker? //to prevent zombie formation of popup
    var conditionPicker : PSConditionPicker? //to prevent zombie formation of popup
    var selectedActionCondition : PSEventActionCondition?
    var eventEntry : Entry?
    var templateEntries : [Entry] = []
    var views : [Int : PSActionsBuilderCell] = [ : ]
    
    var displayViewMetaData : [PSActionBuilderViewMetaDataSet] = []
    var selectedActionConditionLocation : (index1 : Int, index2 : Int, action : Bool)?
    
    
    override func awakeFromNib() {
        scriptData = actionsBuilder.scriptData
        let nib = NSNib(nibNamed: "ActionsBuilderCell", bundle: Bundle(for:type(of: self)))
        actionsTableView.register(nib!, forIdentifier:tableCellViewIdentifier)
        

        //if nothing selected don't allow the pressing of action button
        actionButton.isEnabled = (selectedActionCondition != nil)
    }
    
    func docMocChanged(_ notification : Notification) {
        loadEvent()
    }
    
    func entryDeleted(_ entry : Entry) {

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
            addButton.isEnabled = false
            actionsTableView.reloadData()
            return
        }
        
        
        guard let actionsAttribute = selectionInterface.getEventActionsAttribute() else {
            fatalError("Could not get event actions attribute")
        }
        
        self.actionsAttribute = actionsAttribute
        actionsTypePopup.selectItem(withTitle: actionsAttribute.attributeName)
        
        guard let displayViewMetaData = selectionInterface.getActionConditionViewMetaData() else {
            fatalError("Could not get view meta data")
        }
        
        
        self.displayViewMetaData = displayViewMetaData
        addButton.isEnabled = true
        
        
    }

    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if let aa = actionsAttribute {
            return aa.actionConditionSets.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let view = tableView.makeView(withIdentifier:tableCellViewIdentifier, owner: self) as! PSActionsBuilderCell
        view.controller = self
        view.actionsAttribute = self.actionsAttribute
        view.rowIndex = row
        self.views[row] = view
        
        if row < displayViewMetaData.count{
            view.refresh(displayViewMetaData[row])
        } else {
            view.refresh(PSEmptyActionBuilderViewMetaDataSet)
        }
        
        //restore selection
        if let selectedActionConditionLocation = selectedActionConditionLocation,
            row == selectedActionConditionLocation.index1 {
                let selected = view.selectActionCondition(selectedActionConditionLocation.index2,action: selectedActionConditionLocation.action, window: scriptData.window)
                
                if !selected {
                    disableMenuItemsAndDeselectEverything()
                }
                
        }

        return view
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        //get the height of the row (cannot get the exact view from this method)
        var heightData : PSActionBuilderViewMetaDataSet
        
        if row < displayViewMetaData.count{
            heightData = displayViewMetaData[row]
        } else {
            heightData = PSEmptyActionBuilderViewMetaDataSet
        }
        return CGFloat(10) + max(heightData.actionsHeight, heightData.conditionsHeight)
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return false
    }
    
    func selectedActionCondition(_ actionCondition : PSEventActionCondition?, fromView : PSActionsBuilderCell?) {
        selectedActionCondition = actionCondition
        //alter state of the action button
        actionButton.isEnabled = (selectedActionCondition != nil)
        //deleteButton.enabled = (selectedActionCondition == nil)
        
        if let selectedActionCondition = selectedActionCondition,
            let actionFunction = selectedActionCondition as? PSEventActionFunction {
                instancesActiveUntilMenuItem.isHidden = false
                if actionFunction.hasInstancesOrActiveUntilValueAttributes {
                    instancesActiveUntilMenuItem.state = NSControl.StateValue.on
                } else {
                    instancesActiveUntilMenuItem.state = NSControl.StateValue.off
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
        
        //remember selection
        if let actionsAttribute = actionsAttribute,
            let actionCondition = actionCondition {
            selectedActionConditionLocation = actionsAttribute.getIndexesForActionCondition(actionCondition)
        } else {
            selectedActionConditionLocation = nil
        }
    }
    
    
    //MARK: Action button / validating menu items
    
    @IBAction func actionButtonSelected(_:AnyObject) {
        validateMenuItems()
    }
    
    func validateMenuItems() {
        
        guard let s = selectedActionConditionLocation else {
            disableMenuItemsAndDeselectEverything()
            return
        }
        
        //verify actual selection
        if s.index1 >= views.count || s.index1 < 0 {
            disableMenuItemsAndDeselectEverything()
            return
        }
        
        let selectedSetView = views[s.index1]!
            
        if s.action {
            let actionsSelectedRow = selectedSetView.actionsTableView.selectedRow
            if actionsSelectedRow != s.index2 {
                disableMenuItemsAndDeselectEverything()
                return
            }
        } else {
            let conditionsSelectedRow = selectedSetView.conditionsTableView.selectedRow
            if conditionsSelectedRow != s.index2 {
                disableMenuItemsAndDeselectEverything()
                return
            }
        }
        
        enableMenuItems()
    }
    
    func disableMenuItemsAndDeselectEverything() {
        //deselect in all other tableviews
        for (_,view) in views {
            view.deSelect()
        }
        deleteSetMenuItem.isEnabled = false
        deleteMenuItem.isEnabled = false
        moveUpMenuItem.isEnabled = false
        moveDownMenuItem.isEnabled = false
        moveSetUpMenuItem.isEnabled = false
        moveSetDownMenuItem.isEnabled = false
        instancesActiveUntilMenuItem.state = NSControl.StateValue.off
        instancesActiveUntilMenuItem.isEnabled = false
        selectedActionCondition = nil
        selectedActionConditionLocation = nil
        actionButton.isEnabled = false
    }
    
    func enableMenuItems() {
        deleteSetMenuItem.isEnabled = true
        deleteMenuItem.isEnabled = true
        moveUpMenuItem.isEnabled = true
        moveDownMenuItem.isEnabled = true
        moveSetUpMenuItem.isEnabled = true
        moveSetDownMenuItem.isEnabled = true
        instancesActiveUntilMenuItem.isEnabled = true
    }
    
    //MARK: Action button menu items
    
    @IBAction func deleteActionMenuClicked(_ sender : AnyObject) {
        if let s = selectedActionCondition, let actionsAttribute = actionsAttribute {
            actionsAttribute.removeActionCondition(s)
        }
    }
    
    @IBAction func deleteSetMenuClicked(_ : AnyObject) {
        if let s = selectedActionConditionLocation {
            actionsAttribute?.removeActionConditionSet(s.index1)
        }
    }
    
    @IBAction func toggleInstancesActiveUntil(_ sender : AnyObject) {
        if let selectedActionCondition = selectedActionCondition,
            let actionFunction = selectedActionCondition as? PSEventActionFunction {
                actionFunction.setInstancesActiveUntilOn(!actionFunction.hasInstancesOrActiveUntilValueAttributes)
                
                self.actionsAttribute!.updateAttributeEntry()
        }
    }
    
    @IBAction func moveUpClicked(_ sender : AnyObject) {
        if let actionsAttribute = actionsAttribute,
        let selectedActionCondition = selectedActionCondition{
            let newIndex2 = actionsAttribute.moveActionConditionUp(selectedActionCondition)
            if selectedActionConditionLocation != nil {
                selectedActionConditionLocation!.index2 = newIndex2
            }
        }
    }
    
    @IBAction func moveDownClicked(_ sender : AnyObject) {
        if let actionsAttribute = actionsAttribute,
        let selectedActionCondition = selectedActionCondition{
            let newIndex2 = actionsAttribute.moveActionConditionDown(selectedActionCondition)
            if selectedActionConditionLocation != nil {
                selectedActionConditionLocation!.index2 = newIndex2
            }
        }
    }
    
    @IBAction func moveSetUpClicked(_ : AnyObject) {
        actionsAttribute?.moveSetUp(selectedActionCondition)
        //update selection
        if let s = selectedActionConditionLocation {
            if s.index1 > 0 {
                selectedActionConditionLocation!.index1 -= 1
            }
        }
        
    }
    
    @IBAction func moveSetDownClicked(_ : AnyObject) {
        if let actionsAttribute = actionsAttribute {
            actionsAttribute.moveSetDown(selectedActionCondition)
            //update selection
            if let s = selectedActionConditionLocation {
                if s.index1 < actionsAttribute.actionConditionSets.count - 1 {
                    selectedActionConditionLocation!.index1 += 1
                }
            }
        }
    }
    
    //MARK: Add / Delete Button
    
    @IBAction func addActionButton(_ sender : AnyObject) {
        actionsAttribute?.newActionConditionSet()
        actionsTableView.reloadData()
    }

    //MARK: Actions for chosing trial/event actions attribute
    
    @IBAction func eventActionsMenuClicked(_: AnyObject) {
        if let e = self.eventEntry {
            e.metaData = "EventActions"
            loadEvent()
        }
    }
    
    
    @IBAction func trialActionsMenuClicked(_: AnyObject) {
        if let e = self.eventEntry {
            e.metaData = "TrialActions"
            loadEvent()
        }
    }

}

