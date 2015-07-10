//
//  PSLayoutObjectComboBox.swift
//  PsyScopeEditor
//
//  Created by James on 10/07/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

class PSLayoutObjectComboBox : NSObject, NSComboBoxDataSource, NSComboBoxDelegate {
    
    //MARK: Outlets

    @IBOutlet var comboBox : NSComboBox!
    @IBOutlet var document : Document!
    @IBOutlet var selectionController : PSSelectionController!
    
    //MARK: Variables
    
    var items : [String] = [] //holds entries to switch between
    
    //MARK: Combobox methods
    
    func numberOfItemsInComboBox(aComboBox: NSComboBox) -> Int {
        return items.count
    }
    
    func comboBox(aComboBox: NSComboBox, objectValueForItemAtIndex index: Int) -> AnyObject {
        if (index >= items.count || index < 0) {
            return ""
        } else {
            return items[index]
        }
    }
    
    func comboBox(aComboBox: NSComboBox, indexOfItemWithStringValue string: String) -> Int {
        if let r = items.indexOf(string) {
            return r
        }
        return -1
    }
    func comboBoxSelectionDidChange(notification: NSNotification) {
        selectionController.selectObjectForEntryNamed(getSelectedComboBoxItem())
    }
    
    func getSelectedComboBoxItem() -> String {
        if (comboBox.indexOfSelectedItem >= items.count || comboBox.indexOfSelectedItem < 0) {
            return ""
        } else {
            return items[comboBox.indexOfSelectedItem]
        }
    }
    
    //MARK: Refresh
    
    func refresh() {
        let entries = document.scriptData.getBaseEntriesWithLayoutObjects()
        let new_items = document.scriptData.getNamesOfEntries(entries)
        items = new_items.sort({ (s1: String, s2: String) -> Bool in
            return s1 < s2 })
        
        
        comboBox.reloadData()
        
        if let selectedEntry = selectionController.getSelectedEntry() {
            let currentSelectedItem : String = selectedEntry.name
            selectItem(currentSelectedItem)
        }
    }
    
    //MARK: Change selection
    
    //selects item in combobox, no delegate fired
    func selectItem(item : String) {
        if let index = items.indexOf(item) {
            comboBox.setDelegate(nil) //prevent firing selection did change
            comboBox.selectItemAtIndex(index)
            comboBox.setDelegate(self)
        } else {
            comboBox.setDelegate(nil) //prevent firing selection did change
            comboBox.stringValue = ""
            comboBox.setDelegate(self)
        }
    }
}