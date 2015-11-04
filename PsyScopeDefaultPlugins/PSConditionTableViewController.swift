//
//  PSConditionTableViewController.swift
//  PsyScopeEditor
//
//  Created by James on 12/12/2014.
//

import Foundation

class PSConditionTableViewController: NSObject, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet var conditionsTableView : NSTableView!
    
    let addConditionCellViewIdentifier : String = "AddConditionCell"
    var entry : Entry!
    var scriptData : PSScriptData!
    var conditionAttribute : PSConditionAttribute!
    var conditionPicker : PSConditionPicker? //to prevent conditoin picker becoming zombie
    
    override func awakeFromNib() {
        let accnib = NSNib(nibNamed: "AddConditionCell", bundle: NSBundle(forClass:self.dynamicType))
        conditionsTableView.registerNib(accnib!, forIdentifier: addConditionCellViewIdentifier)
        
    }
    
    func enable(entry : Entry, scriptData : PSScriptData) {
        self.entry = entry
        self.scriptData = scriptData
        self.conditionAttribute = PSConditionAttribute(condition_entry: entry, scriptData: scriptData)
        self.conditionAttribute.parseFromEntry()
        conditionsTableView.enabled = true
        refresh()
    }
    
    func disable() {
        conditionsTableView.enabled = false
        conditionAttribute = nil
        conditionsTableView.reloadData()
    }
    
    func refresh() {
        //register nibs
        for condition in conditionAttribute.conditions {
            self.conditionsTableView.registerNib(condition.condition.nib(), forIdentifier: "PSCustomAction\(condition.condition.type())")
        }
        conditionsTableView.reloadData()
    }
    
    //returns the height of the view - is a class func as PSActionsBuilder uses it too
    class func heightOfViewFor(conditionAttribute : PSConditionAttribute) -> CGFloat {

        //either actions or conditions tallest
        var conditionsHeight : CGFloat = PSConditionsButtonHeight
      
        for (index,c) in conditionAttribute.conditions.enumerate() {
            conditionsHeight += conditionAttribute.itemIsExpanded(index) ? CGFloat(c.condition.expandedCellHeight()) : CGFloat(22)
        }
        
        return CGFloat(10) + conditionsHeight
        
    }
    
    func deSelect() {
        conditionsTableView.deselectAll(self)
    }
    
    // MARK: Tableview
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        if conditionAttribute != nil {
            return conditionAttribute.conditions.count + 1
        } else {
            return 0
        }
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        //determine wether it is action or condition
            if row < conditionAttribute.conditions.count {
                let identifier = "PSCustomAction\(conditionAttribute.conditions[row].condition.type())"
                let view = tableView.makeViewWithIdentifier(identifier, owner: self) as! PSConditionCell
                view.setup(conditionAttribute.conditions[row].condition,function: conditionAttribute.conditions[row],scriptData: scriptData, expandedHeight: conditionAttribute.conditions[row].condition.expandedCellHeight())
                view.updateScriptBlock = { () -> () in self.conditionAttribute.updateEntry() }
                
                view.expandAction = { (expanded : Bool) -> () in
                    self.conditionAttribute.setItemExpanded(row, expanded: expanded)
                }
                let currentlyExpanded = conditionAttribute.itemIsExpanded(row)
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
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        //get the height of the row
            if row < conditionAttribute.conditions.count {
                return conditionAttribute.itemIsExpanded(row) ? CGFloat(conditionAttribute.conditions[row].condition.expandedCellHeight()) : CGFloat(22)
                
                
            } else {
                //is add condition button
                return PSConditionsButtonHeight
            }
    }
    
    // MARK: Adding Conditions
    
    func addCondition(button : NSButton) {
        //existing conditions
        let existingConditionTypes = conditionAttribute.conditions.map({
            (condition : PSEventConditionFunction) -> String in
            return condition.functionName
        })
        
        //callback when condition picked
        let selectConditionFunction = {
            (conditionInterface : PSConditionInterface, selected : Bool) -> () in
            if (selected) {
                //append
                self.conditionsTableView.registerNib(conditionInterface.nib(), forIdentifier: "PSCustomAction\(conditionInterface.type())")
                self.conditionAttribute.appendCondition(conditionInterface)
            } else {
                //remove
                self.conditionAttribute.removeCondition(conditionInterface)
            }
        }
        
        self.conditionPicker = PSConditionPicker(scriptData: scriptData, existingConditionTypes: existingConditionTypes, selectConditionCallback: selectConditionFunction)
        
        self.conditionPicker!.showConditionWindow(conditionsTableView)
    }
    
    // MARK: Deleteing conditions
    @IBAction func deleteMenuClicked(menuItem : NSMenuItem) {
        //get selected item
        let selectedIndex = conditionsTableView.selectedRow
        
        //delete it
        if selectedIndex > -1 {
            self.conditionAttribute.removeConditionAtIndex(selectedIndex)
        }
        
    }
}