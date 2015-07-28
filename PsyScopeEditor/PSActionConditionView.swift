//
//  PSActionConditionView.swift
//  PsyScopeEditor
//
//  Created by James on 13/11/2014.
//

import Foundation

class PSActionConditionView: NSView, NSTableViewDelegate, NSTableViewDataSource {
    @IBOutlet var actionsTableView : NSTableView!
    @IBOutlet var conditionsTableView : NSTableView!
    @IBOutlet var actionsScrollView : NSScrollView!
    @IBOutlet var conditionsScrollView : NSScrollView!
    @IBOutlet var arrowImage : NSImageView!
    
    @IBOutlet var segmentedControl : NSSegmentedControl!
    
    var actionsBrowser : PSActionsBrowser!
    var actionsAttribute : PSEventActionsAttribute!
    var currentViewMetaData : PSActionBuilderViewMetaDataSet!
    var rowIndex : Int = 0
    var actions : [PSEventActionFunction] = []
    var conditions : [PSEventConditionFunction] = []
    
    let addActionCellViewIdentifier : String = "AddActionCell"
    let addConditionCellViewIdentifier : String = "AddConditionCell"
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let aacnib = NSNib(nibNamed: "AddActionCell", bundle: NSBundle(forClass:self.dynamicType))
        actionsTableView.registerNib(aacnib!, forIdentifier: addActionCellViewIdentifier)
        let accnib = NSNib(nibNamed: "AddConditionCell", bundle: NSBundle(forClass:self.dynamicType))
        conditionsTableView.registerNib(accnib!, forIdentifier: addConditionCellViewIdentifier)
    }
    
    func refresh(viewMetaData : PSActionBuilderViewMetaDataSet) {
        currentViewMetaData = viewMetaData
        (conditions, actions) = actionsAttribute.actionConditionSets[rowIndex]
        
        //register nibs
        for condition in conditions {
            self.conditionsTableView.registerNib(condition.condition.nib(), forIdentifier: "PSCustomAction\(condition.condition.type())")
        }
        
        resizeControls()
        actionsTableView.reloadData()
        conditionsTableView.reloadData()
        
    }
    
    func resizeControls() {
    
        var new_frame_size = self.frame.size
        new_frame_size.height = CGFloat(20) + currentViewMetaData.actionsHeight + currentViewMetaData.conditionsHeight
        self.frame.size = new_frame_size
        
        let new_actions_frame = NSMakeRect(1, 0, new_frame_size.width - 2, currentViewMetaData.actionsHeight)
        
        let new_conditions_frame = NSMakeRect(1, new_actions_frame.height + 20, new_frame_size.width - 2, currentViewMetaData.conditionsHeight)

        var new_arrow_frame = arrowImage.frame
        let imageX : CGFloat = CGFloat((new_conditions_frame.width - 20) / CGFloat(2))
        new_arrow_frame.origin = NSMakePoint(imageX, new_actions_frame.height)
        actionsScrollView.frame = new_actions_frame
        conditionsScrollView.frame = new_conditions_frame
        arrowImage.frame = new_arrow_frame
    }
    
    func deSelect() {
        actionsTableView.deselectAll(self)
        conditionsTableView.deselectAll(self)
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        if tableView === actionsTableView {
            return actions.count + 1
        } else {
            return conditions.count + 1
        }
    }
   
    
    @IBAction func deleteContextMenuClicked(sender : AnyObject) {
        if actionsTableView.selectedRow > -1 && actionsTableView.selectedRow < actions.count {
            actionsBrowser.deleteActionCondition(actions[actionsTableView.selectedRow])
        } else if conditionsTableView.selectedRow > -1 && conditionsTableView.selectedRow < conditions.count {
            actionsBrowser.deleteActionCondition(conditions[conditionsTableView.selectedRow])
        }
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        //determine wether it is action or condition
        
        
        if tableView === actionsTableView {
            //is action
            if row < actions.count {
            let ac = actions[row]
                let view = ac.action.createCellView(ac, scriptData: actionsBrowser.scriptData, expandedHeight: currentViewMetaData.actions[row].expandedCellHeight) //set up done inside
            view.updateScriptBlock = { () -> () in self.actionsBrowser.updateEventActions() }
            view.expandAction = { (expanded : Bool) -> () in
                self.actionsAttribute.userSetItemExpanded(self.rowIndex, itemIndex: row, action: true, expanded: expanded)
                
            }
            let currentlyExpanded = actionsAttribute.itemIsExpanded(rowIndex, itemIndex: row, action: true)
            view.setExpanded(currentlyExpanded)
            return view
            } else {
                //is add action button
                let view = tableView.makeViewWithIdentifier(addActionCellViewIdentifier, owner: self) as! PSButtonCell
                view.action = { (sender : NSButton) -> () in
                    self.addAction(sender)
                }
                return view
            }
        } else if tableView === conditionsTableView {
            //is condition
            if row < conditions.count {
                let ec = conditions[row]
                let identifier = "PSCustomAction\(ec.condition.type())"
                let view = tableView.makeViewWithIdentifier(identifier, owner: self) as! PSConditionCell
                view.setup(ec.condition,function: conditions[row],scriptData: actionsBrowser.scriptData, expandedHeight: currentViewMetaData.conditions[row].expandedCellHeight)
                view.updateScriptBlock = { () -> () in self.actionsBrowser.updateEventActions() }
                view.expandAction = { (expanded : Bool) -> () in
                    self.actionsAttribute.userSetItemExpanded(self.rowIndex, itemIndex: row, action: false, expanded: expanded)
                    
                }
                let currentlyExpanded = actionsAttribute.itemIsExpanded(rowIndex, itemIndex: row, action: false)
                view.setExpanded(currentlyExpanded)
                return view
            } else {
                //is add condition button
                let view = tableView.makeViewWithIdentifier(addConditionCellViewIdentifier, owner: self) as! PSButtonCell
                view.action = { (sender : NSButton) -> () in
                    self.addCondition(sender)
                }
                return view
            }
        }
        return nil
    }
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        //get the height of the row
        if tableView === actionsTableView {
            if row < actions.count {
                if currentViewMetaData.actions[row].expanded {
                    return currentViewMetaData.actions[row].expandedCellHeight
                } else {
                    return PSCollapsedViewHeight
                }
            } else {
                return PSActionsButtonHeight
            }
        } else if tableView === conditionsTableView {
            if row < conditions.count {
                if currentViewMetaData.conditions[row].expanded {
                    return currentViewMetaData.conditions[row].expandedCellHeight
                } else {
                    return PSCollapsedViewHeight
                }
            } else {
                return PSConditionsButtonHeight
            }
        }
        return PSCollapsedViewHeight
    }
    
    
    func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        //tableViewSelectionIsChanging?
        switch (tableView) {
        case actionsTableView:
            if row < actions.count {
                conditionsTableView.deselectAll(nil)
                actionsBrowser.selectedActionCondition(actions[row], fromView: self)
                return true
            }
        case conditionsTableView:
            if row < conditions.count {
                actionsTableView.deselectAll(nil)
                actionsBrowser.selectedActionCondition(conditions[row], fromView: self)
                return true
            }
        default:
            return false
        }
        
        return false
    }
    
    func addCondition(button : NSButton) {
        //existing conditions
        let existingConditionTypes = conditions.map({
            (condition : PSEventConditionFunction) -> String in
            return condition.functionName
        })
        
        let selectConditionFunction = {
            (conditionInterface : PSConditionInterface, selected : Bool) -> () in
            if (selected) {
                //append
                self.conditionsTableView.registerNib(conditionInterface.nib(), forIdentifier: "PSCustomAction\(conditionInterface.type())")
                self.actionsAttribute.appendCondition(self.rowIndex, condition: conditionInterface)
            } else {
                //remove
                self.actionsAttribute.removeCondition(self.rowIndex, condition: conditionInterface)
            }
            return
        }
        
        actionsBrowser.conditionPicker = PSConditionPicker(scriptData: actionsBrowser.scriptData, existingConditionTypes: existingConditionTypes, selectConditionCallback: selectConditionFunction)
        
        actionsBrowser.conditionPicker!.showConditionWindow(actionsBrowser.actionsTableView)
        
    }
    
    func addAction(button : NSButton) {
        
        let selectActionFunction = {
            (new_action : PSActionInterface) -> () in
            self.actionsAttribute.appendAction(self.rowIndex, action: new_action)
        }
        
        actionsBrowser.actionPicker = PSActionPicker(scriptData: actionsBrowser.scriptData, selectActionCallback: selectActionFunction)
        actionsBrowser.actionPicker!.showActionWindow(actionsBrowser.actionsTableView)
    }
    
    
}