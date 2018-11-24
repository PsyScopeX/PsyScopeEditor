//
//  PSBlocksTableController.swift
//  PsyScopeEditor
//
//  Created by James on 26/05/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSBlocksTableController : PSChildTypeViewController {
    
    init?(pluginViewController : PSPluginViewController) {
        super.init(pluginViewController: pluginViewController,nibName: "BlocksTable")
        pluginViewController.storedDoubleClickAction = nil
        tableEntryName = "Blocks"
        tableTypeName = "Block"
    }
    
    
    @IBOutlet var orderPopUpButton : NSPopUpButton!
    @IBOutlet var cyclesTextField : NSTextField!
    @IBOutlet var scaleTextField : NSTextField!
    @IBOutlet var scalableButton : NSButton!
    
    var orderComboBoxItems : [String : String] = ["Sequential":"Sequential", "Random":"Random", "Random with replacement": "RRandom"]
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        refreshView()
    }
    
    
    func refreshView() {
        var selected_index = 0
        if let te = scriptData.getSubEntry("Blocks", entry: entry) {
            if let ae = scriptData.getSubEntry("AccessType", entry: te) {
                for (value, item) in orderComboBoxItems.enumerated() {
                    if ae.currentValue == item.1 {
                        selected_index = value
                    }
                }
            }
        }
        
        orderPopUpButton.removeAllItems()
        var items : [String] = []
        for k in orderComboBoxItems.keys {
            items.append(k)
        }
        orderPopUpButton.addItems(withTitles: items)
        
        if orderPopUpButton.indexOfSelectedItem != selected_index {
            orderPopUpButton.selectItem(at: selected_index)
        }
        
        
        
        if let bd_entry = scriptData.getSubEntry("Cycles", entry: entry) {
            scalableButton.state = NSControl.StateValue.on
            cyclesTextField.stringValue = bd_entry.currentValue
            scaleTextField.isEnabled = true
        } else if let bd_entry = scriptData.getSubEntry("FixedCycles", entry: entry) {
            scalableButton.state = NSControl.StateValue.off
            cyclesTextField.stringValue = bd_entry.currentValue
            scaleTextField.isEnabled = false
        } else {
            scalableButton.state = NSControl.StateValue.on
            cyclesTextField.stringValue = "1"
            scaleTextField.isEnabled = true
        }
        
        if let bd_entry = scriptData.getSubEntry("ScaleBlocks", entry: entry) {
            scaleTextField.stringValue = bd_entry.currentValue
        } else {
            scaleTextField.stringValue = "1"
        }

    }
    
    
    
    
    func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        processButtonChange()
        return true
    }
    
    @IBAction func orderPopUpButtons(_: AnyObject) {
        if let te = scriptData.getSubEntry("Blocks", entry: entry) {
            let access_entry = scriptData.getOrCreateSubEntry("AccessType", entry: te, isProperty: true)
            access_entry.currentValue = orderComboBoxItems[orderPopUpButton.selectedItem!.title]
        }
    }
    
    @IBAction func scalableButtonPress(_: AnyObject) {
        processButtonChange()
    }
    
    
    func processButtonChange(){
        
        let intCycle : Int = cyclesTextField.integerValue
    
        if scalableButton.state.rawValue == 1 {
            scriptData.deleteNamedSubEntryFromParentEntry(entry, name: "FixedCycles")
            let cyclesEntry = scriptData.getOrCreateSubEntry("Cycles", entry: entry, isProperty: true)
            cyclesEntry.currentValue = "\(intCycle)"
            
            let intScaleBlocks : Int = scaleTextField.integerValue
            let scaleEntry = scriptData.getOrCreateSubEntry("ScaleBlocks", entry: entry, isProperty: true)
            scaleEntry.currentValue = "\(intScaleBlocks)"
        } else {
            scriptData.deleteNamedSubEntryFromParentEntry(entry, name: "ScaleBlocks")
            scriptData.deleteNamedSubEntryFromParentEntry(entry, name: "Cycles")
            let cyclesEntry = scriptData.getOrCreateSubEntry("FixedCycles", entry: entry, isProperty: true)
            cyclesEntry.currentValue = "\(intCycle)"
        }
    }
}
