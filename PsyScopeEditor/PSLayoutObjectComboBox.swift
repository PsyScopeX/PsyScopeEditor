//
//  PSLayoutObjectComboBox.swift
//  PsyScopeEditor
//
//  Created by James on 10/07/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

/*
 * PSLayoutObjectComboBox: Object loaded on Document.xib.  Controls combobox which appears in tool bar allowing to switch selection of layout objects.
*/
class PSLayoutObjectComboBox : NSObject, NSComboBoxDataSource, NSComboBoxDelegate {
    
    //MARK: Outlets

    @IBOutlet var comboBox : NSComboBox!
    @IBOutlet var mainWindowController : PSMainWindowController!
    
    //MARK: Variables
    
    var entryNames : [String] = [] //holds names of entries to switch between
    
    //MARK: Combobox methods
    
    func numberOfItemsInComboBox(aComboBox: NSComboBox) -> Int {
        return entryNames.count
    }
    
    func comboBox(aComboBox: NSComboBox, objectValueForItemAtIndex index: Int) -> AnyObject {
        if (index >= entryNames.count || index < 0) {
            return ""
        } else {
            return entryNames[index]
        }
    }
    
    func comboBox(aComboBox: NSComboBox, indexOfItemWithStringValue string: String) -> Int {
        if let r = entryNames.indexOf(string) {
            return r
        }
        return -1
    }
    
    func comboBoxSelectionDidChange(notification: NSNotification) {
        mainWindowController.selectionController.selectObjectForEntryNamed(getSelectedComboBoxItem())
    }
    
    func getSelectedComboBoxItem() -> String {
        if (comboBox.indexOfSelectedItem >= entryNames.count || comboBox.indexOfSelectedItem < 0) {
            return ""
        } else {
            return entryNames[comboBox.indexOfSelectedItem]
        }
    }
    
    //MARK: Refresh
    
    func refresh() {
        let entries = mainWindowController.scriptData.getBaseEntriesWithLayoutObjects()
        let new_items = mainWindowController.scriptData.getNamesOfEntries(entries)
        entryNames = new_items.sort({ (s1: String, s2: String) -> Bool in
            return s1 < s2 })
        
        
        comboBox.reloadData()
        
        if let selectedEntry = mainWindowController.selectionController.getSelectedEntry() {
            let currentSelectedItem : String = selectedEntry.name
            selectItem(currentSelectedItem)
        }
    }
    
    //MARK: Change selection
    
    //selects item in combobox, no delegate fired
    func selectItem(item : String) {
        if let index = entryNames.indexOf(item) {
            comboBox.setDelegate(nil) //prevent firing comboBoxSelectionDidChange
            comboBox.selectItemAtIndex(index)
            comboBox.setDelegate(self)
        } else {
            comboBox.setDelegate(nil) //prevent firing comboBoxSelectionDidChange
            comboBox.stringValue = ""
            comboBox.setDelegate(self)
        }
    }
}