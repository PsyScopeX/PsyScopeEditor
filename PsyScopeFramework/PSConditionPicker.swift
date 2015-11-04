//
//  PSConditionPicker.swift
//  PsyScopeEditor
//
//  Created by James on 16/11/2014.
//

import Foundation
import Cocoa

public typealias PSConditionPickerCallback = ((PSConditionInterface,Bool) -> ())

//MARK: PSConditionPicker

public class PSConditionPicker: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    
    public init(scriptData : PSScriptData, existingConditionTypes : [String], selectConditionCallback : PSConditionPickerCallback) {
        self.scriptData = scriptData
        self.tableCellViewIdentifier = "PSConditionPickerCell"
        self.existingConditionTypes = existingConditionTypes
        self.selectConditionCallback = selectConditionCallback
        super.init()
        NSBundle(forClass:self.dynamicType).loadNibNamed("ConditionPicker", owner: self, topLevelObjects: &topLevelObjects)
    }
    
    // MARK: Variables / Constants
    let scriptData : PSScriptData
    let tableCellViewIdentifier : String
    let selectConditionCallback : PSConditionPickerCallback
    
    var tableViewConditions : [PSConditionPickerCondition] = []
    var topLevelObjects : NSArray?
    var existingConditionTypes : [String]
    
    // MARK: Outlets
    
    @IBOutlet var conditionTableView : NSTableView!
    @IBOutlet var popover : NSPopover!
    
    // MARK: Setup and start
    
    override public func awakeFromNib() {
        let nib = NSNib(nibNamed: "ConditionPickerCell", bundle: NSBundle(forClass:self.dynamicType))
        conditionTableView.registerNib(nib!, forIdentifier: tableCellViewIdentifier)
        tableViewConditions = []
        
        for (_, a_plugin) in scriptData.pluginProvider.conditionPlugins {
            let new_Condition = PSConditionPickerCondition()
            new_Condition.type = a_plugin.type()
            new_Condition.userFriendlyName = a_plugin.userFriendlyName()
            new_Condition.helpfulDescription = a_plugin.helpfulDescription()
            new_Condition.condition = a_plugin
            tableViewConditions.append(new_Condition)
            
        }
        
        tableViewConditions = tableViewConditions.sort({ (s1: PSConditionPickerCondition, s2: PSConditionPickerCondition) -> Bool in
            return s1.userFriendlyName < s2.userFriendlyName })
    }
    
    public func showConditionWindow(view : NSView) {
        popover.showRelativeToRect(view.bounds, ofView: view, preferredEdge: NSRectEdge.MinX)
        conditionTableView.reloadData()
    }
    
    // MARK: User interaction
    
    @IBAction func doneButtonClicked(sender : AnyObject) {
        popover.close()
    }
    
    func conditionButtonClicked(row : Int, clickedOn : Bool) {
        let type = tableViewConditions[row].type
        if (clickedOn) {
            self.existingConditionTypes.append(type)
        } else {
            if let index = self.existingConditionTypes.indexOf(type) {
                self.existingConditionTypes.removeAtIndex(index)
            }
        }
        selectConditionCallback(tableViewConditions[row].condition,clickedOn)
    }
    
    // MARK: Tableview
    
    public func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return tableViewConditions.count
    }
    
    public func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let view = tableView.makeViewWithIdentifier(tableCellViewIdentifier, owner: nil) as! PSConditionPickerCell
        
        view.setup(tableViewConditions[row].userFriendlyName, image: NSImage(), row: row, clickCallback: conditionButtonClicked)
        
        //preset button state
        view.button.state = existingConditionTypes.contains(tableViewConditions[row].type) ? 1 : 0
        
        return view
    }
    
    public func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return CGFloat(25)
    }
    
}

// MARK: Struct

class PSConditionPickerCondition : NSObject {
    var type : String = ""
    var userFriendlyName : String = ""
    var helpfulDescription : String = ""
    var condition : PSConditionInterface! = nil
}
