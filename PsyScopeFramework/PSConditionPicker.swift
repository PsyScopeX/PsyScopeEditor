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

open class PSConditionPicker: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    
    public init(scriptData : PSScriptData, existingConditionTypes : [String], selectConditionCallback : @escaping PSConditionPickerCallback) {
        self.scriptData = scriptData
        self.tableCellViewIdentifier = NSUserInterfaceItemIdentifier(rawValue:"PSConditionPickerCell")
        self.existingConditionTypes = existingConditionTypes
        self.selectConditionCallback = selectConditionCallback
        super.init()
        Bundle(for:type(of: self)).loadNibNamed("ConditionPicker", owner: self, topLevelObjects: &topLevelObjects)
    }
    
    // MARK: Variables / Constants
    let scriptData : PSScriptData
    let tableCellViewIdentifier : NSUserInterfaceItemIdentifier
    let selectConditionCallback : PSConditionPickerCallback
    
    var tableViewConditions : [PSConditionPickerCondition] = []
    var topLevelObjects : NSArray?
    var existingConditionTypes : [String]
    
    // MARK: Outlets
    
    @IBOutlet var conditionTableView : NSTableView!
    @IBOutlet var popover : NSPopover!
    
    // MARK: Setup and start
    
    override open func awakeFromNib() {
        let nib = NSNib(nibNamed: "ConditionPickerCell", bundle: Bundle(for:type(of: self)))
        conditionTableView.register(nib!, forIdentifier:tableCellViewIdentifier)
        tableViewConditions = []
        
        for (_, a_plugin) in scriptData.pluginProvider.conditionPlugins {
            let new_Condition = PSConditionPickerCondition()
            new_Condition.type = a_plugin.type()
            new_Condition.userFriendlyName = a_plugin.userFriendlyName()
            new_Condition.helpfulDescription = a_plugin.helpfulDescription()
            new_Condition.condition = a_plugin
            tableViewConditions.append(new_Condition)
            
        }
        
        tableViewConditions = tableViewConditions.sorted(by: { (s1: PSConditionPickerCondition, s2: PSConditionPickerCondition) -> Bool in
            return s1.userFriendlyName < s2.userFriendlyName })
    }
    
    open func showConditionWindow(_ view : NSView) {
        popover.show(relativeTo: view.bounds, of: view, preferredEdge: NSRectEdge.minX)
        conditionTableView.reloadData()
    }
    
    // MARK: User interaction
    
    @IBAction func doneButtonClicked(_ sender : AnyObject) {
        popover.close()
    }
    
    func conditionButtonClicked(_ row : Int, clickedOn : Bool) {
        let type = tableViewConditions[row].type
        if (clickedOn) {
            self.existingConditionTypes.append(type)
        } else {
            if let index = self.existingConditionTypes.index(of: type) {
                self.existingConditionTypes.remove(at: index)
            }
        }
        selectConditionCallback(tableViewConditions[row].condition,clickedOn)
    }
    
    // MARK: Tableview
    
    open func numberOfRows(in tableView: NSTableView) -> Int {
        return tableViewConditions.count
    }
    
    open func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let view = tableView.makeView(withIdentifier:tableCellViewIdentifier, owner: nil) as! PSConditionPickerCell
        
        view.setup(tableViewConditions[row].userFriendlyName, image: NSImage(), row: row, clickCallback: conditionButtonClicked)
        
        //preset button state
        view.button.state = NSControl.StateValue(rawValue: existingConditionTypes.contains(tableViewConditions[row].type) ? 1 : 0)
        
        return view
    }
    
    open func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
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
