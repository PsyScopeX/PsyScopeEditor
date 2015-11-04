//
//  TemplateTableController.swift
//  PsyScopeEditor
//
//  Created by James on 22/05/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSTemplateTableController : PSChildTypeViewController {
    
    init?(pluginViewController : PSPluginViewController) {
        super.init(pluginViewController: pluginViewController,nibName: "TemplatesTable")
        pluginViewController.storedDoubleClickAction = nil
        tableEntryName = "Templates"
        tableTypeName = "Template"
    }

    
    @IBOutlet var templateOrderPopUpButton : NSPopUpButton!
    @IBOutlet var modeMatrix : NSMatrix!
    @IBOutlet var blockDurationTextField : NSTextField!
    @IBOutlet var trialsInBlockTextField : NSTextField!
    
    
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
        if let te = scriptData.getSubEntry("Templates", entry: entry) {
            if let ae = scriptData.getSubEntry("AccessType", entry: te) {
                for (value, item) in orderComboBoxItems.enumerate() {
                    if ae.currentValue == item.1 {
                        selected_index = value
                    }
                }
            }
        }
        
        templateOrderPopUpButton.removeAllItems()
        var items : [String] = []
        for k in orderComboBoxItems.keys {
            items.append(k)
        }
        templateOrderPopUpButton.addItemsWithTitles(items)
        
        if templateOrderPopUpButton.indexOfSelectedItem != selected_index {
            templateOrderPopUpButton.selectItemAtIndex(selected_index)
        }
        
        
        
        if let bd_entry = scriptData.getSubEntry("BlockDuration", entry: entry) {
            modeMatrix.selectCellWithTag(1)
            blockDurationTextField.enabled = true
            blockDurationTextField.stringValue = bd_entry.currentValue
            trialsInBlockTextField.enabled = false
            trialsInBlockTextField.stringValue = ""
        } else if let cycle_entry = scriptData.getSubEntry("Cycles", entry: entry) {
            modeMatrix.selectCellWithTag(3)
            blockDurationTextField.enabled = false
            blockDurationTextField.stringValue = ""
            trialsInBlockTextField.enabled = true
            trialsInBlockTextField.stringValue = cycle_entry.currentValue
        } else if let fixedcycle_entry = scriptData.getSubEntry("FixedCycles", entry: entry) {
            modeMatrix.selectCellWithTag(2)
            blockDurationTextField.enabled = false
            blockDurationTextField.stringValue = ""
            trialsInBlockTextField.enabled = true
            trialsInBlockTextField.stringValue = fixedcycle_entry.currentValue
        } else {
            modeMatrix.selectCellWithTag(3)
            blockDurationTextField.enabled = false
            blockDurationTextField.stringValue = ""
            trialsInBlockTextField.enabled = true
            trialsInBlockTextField.stringValue = "1"
        }
    }
    
    
    
    
    func control(control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        processButtonChange()
        return true
    }
    
    @IBAction func orderPopUpButtons(_: AnyObject) {
        if let te = scriptData.getSubEntry("Templates", entry: entry) {
            let access_entry = scriptData.getOrCreateSubEntry("AccessType", entry: te, isProperty: true)
            access_entry.currentValue = orderComboBoxItems[templateOrderPopUpButton.selectedItem!.title]
        }
    }
    
    @IBAction func modeRadioButton(_: AnyObject) {
        processButtonChange()
    }
    
    func processButtonChange(){
        let selected_mode = modeMatrix.selectedCell() as! NSButtonCell
        let selected_tag = selected_mode.tag
        if selected_tag == 1 {
            let bd_entry = scriptData.getOrCreateSubEntry("BlockDuration", entry: entry, isProperty: true)
            if blockDurationTextField.stringValue == "" { blockDurationTextField.stringValue = "1" }
            bd_entry.currentValue = blockDurationTextField.stringValue
            scriptData.deleteNamedSubEntryFromParentEntry(entry, name: "Cycles")
            scriptData.deleteNamedSubEntryFromParentEntry(entry, name: "FixedCycles")
        } else if selected_tag == 2 {
            let tib_entry = scriptData.getOrCreateSubEntry("FixedCycles", entry: entry, isProperty: true)
            if trialsInBlockTextField.stringValue == "" { trialsInBlockTextField.stringValue = "1" }
            tib_entry.currentValue = trialsInBlockTextField.stringValue
            scriptData.deleteNamedSubEntryFromParentEntry(entry, name: "Cycles")
            scriptData.deleteNamedSubEntryFromParentEntry(entry, name: "BlockDuration")
        } else if selected_tag == 3 {
            let tib_entry = scriptData.getOrCreateSubEntry("Cycles", entry: entry, isProperty: true)
            if trialsInBlockTextField.stringValue == "" { trialsInBlockTextField.stringValue = "1" }
            tib_entry.currentValue = trialsInBlockTextField.stringValue
            scriptData.deleteNamedSubEntryFromParentEntry(entry, name: "FixedCycles")
            scriptData.deleteNamedSubEntryFromParentEntry(entry, name: "BlockDuration")
        }
    }
}