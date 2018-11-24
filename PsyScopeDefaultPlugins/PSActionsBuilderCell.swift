//
//  PSActionsBuilderCell.swift
//  PsyScopeEditor
//
//  Created by James on 03/12/2014.
//

import Cocoa



class PSActionsBuilderCell: NSView, NSTableViewDelegate, NSTableViewDataSource {
    @IBOutlet var actionsTableView : NSTableView!
    @IBOutlet var conditionsTableView : NSTableView!

    var controller : PSActionsBuilderController!
    var actionsAttribute : PSEventActionsAttribute!
    
    var rowIndex : Int = 0
    var actions : [PSEventActionFunction] = []
    var conditions : [PSEventConditionFunction] = []
    let addActionCellViewIdentifier = NSUserInterfaceItemIdentifier(rawValue:"AddActionCell")
    let addConditionCellViewIdentifier = NSUserInterfaceItemIdentifier(rawValue:"AddConditionCell")
    var registeredNibs : Set<String> = []
    var currentViewMetaData : PSActionBuilderViewMetaDataSet!
    
    override func awakeFromNib() {        
        let aacnib = NSNib(nibNamed: "AddActionCell", bundle: Bundle(for:type(of: self)))
        actionsTableView.register(aacnib!, forIdentifier:addActionCellViewIdentifier)
        let accnib = NSNib(nibNamed: "AddConditionCell", bundle: Bundle(for:type(of: self)))
        conditionsTableView.register(accnib!, forIdentifier:addConditionCellViewIdentifier)
    }
    
    func refresh(_ viewMetaData : PSActionBuilderViewMetaDataSet) {
        currentViewMetaData = viewMetaData
        (conditions, actions) = actionsAttribute.actionConditionSets[rowIndex]
        
        //register nibs for conditions
        for condition in conditions {
            let identifier = NSUserInterfaceItemIdentifier(rawValue:"PSCustomAction\(condition.functionName)")
            if !registeredNibs.contains(identifier) {
                self.conditionsTableView.register(condition.condition.nib(), forIdentifier:identifier)
                registeredNibs.insert(identifier)
            }
        }
        
        var new_frame_size = self.frame.size
        new_frame_size.height = CGFloat(10) + max(viewMetaData.actionsHeight, viewMetaData.conditionsHeight)
        self.frame.size = new_frame_size
        
        
        actionsTableView.reloadData()
        conditionsTableView.reloadData()
        
    }
    
    func deSelect() {
        actionsTableView.deselectAll(self)
        conditionsTableView.deselectAll(self)
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        switch (tableView) {
        case actionsTableView:
            return actions.count + 1
        case conditionsTableView:
            return conditions.count + 1
        default:
            return 0
        }
    }

    @IBAction func deleteContextMenuClicked(_ sender : AnyObject) {
        //controller.deleteActionCondition(actionConditionAt(tableView.selectedRow))
    }
    
    
    func selectActionCondition(_ index : Int, action : Bool, window : NSWindow) -> Bool {
        if action && self.tableView(actionsTableView, shouldSelectRow: index) {
            actionsTableView.selectRowIndexes(IndexSet(integer: index), byExtendingSelection: false)
            window.makeFirstResponder(actionsTableView)
            self.tableView(actionsTableView, shouldSelectRow: index)
            return true
        } else if self.tableView(conditionsTableView,  shouldSelectRow: index) {
            conditionsTableView.selectRowIndexes(IndexSet(integer: index), byExtendingSelection: false)
            window.makeFirstResponder(conditionsTableView)
            self.tableView(conditionsTableView, shouldSelectRow: index)
            return true
        }
        return false
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        //determine wether it is action or condition
        switch (tableView) {
        case actionsTableView:
            if row < actions.count {
                //construct new action view
                let view = actions[row].action.createCellView(actions[row], scriptData: controller.scriptData, expandedHeight: currentViewMetaData.actions[row].expandedCellHeight) //set up done inside
                view?.updateScriptBlock = { () -> () in self.actionsAttribute.updateAttributeEntry() }
                
                view?.expandAction = { (expanded : Bool) -> () in
                    self.actionsAttribute.userSetItemExpanded(self.rowIndex, itemIndex: row, action: true, expanded: expanded)
                
                }
                let currentlyExpanded = currentViewMetaData.actions[row].expanded
                view?.setExpanded(currentlyExpanded)
                
                return view
            } else {
                //is add action button
                let view = tableView.makeView(withIdentifier:addActionCellViewIdentifier, owner: self) as! PSButtonCell
                view.action = { (sender : NSButton) -> () in
                    self.addAction(sender)
                }
                return view
            }
        case conditionsTableView:
            if row < conditions.count {
                let identifier = NSUserInterfaceItemIdentifier(rawValue:"PSCustomAction\(conditions[row].functionName)")
                let view = tableView.makeView(withIdentifier:identifier, owner: self) as! PSConditionCell
                view.setup(conditions[row].condition,function: conditions[row],scriptData: controller.scriptData, expandedHeight: currentViewMetaData.conditions[row].expandedCellHeight)
                view.updateScriptBlock = { () -> () in self.actionsAttribute.updateAttributeEntry() }
                view.expandAction = { (expanded : Bool) -> () in
                    self.actionsAttribute.userSetItemExpanded(self.rowIndex, itemIndex: row, action: false, expanded: expanded)
                }
                let currentlyExpanded = currentViewMetaData.conditions[row].expanded
                view.setExpanded(currentlyExpanded)
                return view
            } else {
                //is add condition button
                let view = tableView.makeView(withIdentifier:addConditionCellViewIdentifier, owner: self) as! PSButtonCell
                view.action = { (sender : NSButton) -> () in
                    self.addCondition(sender)
                }
                return view
            }
        default:
            return nil
        }

    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        //get the height of the row
        switch (tableView) {
        case actionsTableView:
            if row < actions.count {
                if currentViewMetaData.actions[row].expanded {
                    return currentViewMetaData.actions[row].expandedCellHeight
                } else {
                    return PSCollapsedViewHeight
                }
            } else {
                //is add action button
                return PSActionsButtonHeight
            }
        case conditionsTableView:
            if row < conditions.count {
                if currentViewMetaData.conditions[row].expanded {
                    return currentViewMetaData.conditions[row].expandedCellHeight
                } else {
                    return PSCollapsedViewHeight
                }
            } else {
                //is add condition button
                return PSActionsButtonHeight
            }
        default:
            return 30
        }

    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        //tableViewSelectionIsChanging?
        switch (tableView) {
        case actionsTableView:
            if row < actions.count {
                conditionsTableView.deselectAll(nil)
                controller.selectedActionCondition(actions[row], fromView: self)
                return true
            }
        case conditionsTableView:
            if row < conditions.count {
                actionsTableView.deselectAll(nil)
                controller.selectedActionCondition(conditions[row], fromView: self)
                return true
            }
        default:
            return false
        }
        
        return false
    }
    
    func addCondition(_ button : NSButton) {
        //existing conditions
        let existingConditionTypes = conditions.map({
            (condition : PSEventConditionFunction) -> String in
            return condition.functionName
        })
        
        let selectConditionFunction = {
            (conditionInterface : PSConditionInterface, selected : Bool) -> () in
            if (selected) {
                //append
                self.conditionsTableView.register(conditionInterface.nib(), forIdentifier: NSUserInterfaceItemIdentifier(rawValue:"PSCustomAction\(conditionInterface.type())"))
                self.actionsAttribute.appendCondition(self.rowIndex, condition: conditionInterface)
            } else {
                //remove
                self.actionsAttribute.removeCondition(self.rowIndex, condition: conditionInterface)
            }
            return
        }
        
        controller.conditionPicker = PSConditionPicker(scriptData: controller.scriptData, existingConditionTypes: existingConditionTypes, selectConditionCallback: selectConditionFunction)
        
        controller.conditionPicker!.showConditionWindow(controller.actionsTableView)

    }
    
    func addAction(_ button : NSButton) {

        let selectActionFunction = {
            (new_action : PSActionInterface) -> () in
            self.actionsAttribute.appendAction(self.rowIndex, action: new_action)
        }
        
        controller.actionPicker = PSActionPicker(scriptData: controller.scriptData, selectActionCallback: selectActionFunction)
        controller.actionPicker!.showActionWindow(controller.actionsTableView)
    }
}
