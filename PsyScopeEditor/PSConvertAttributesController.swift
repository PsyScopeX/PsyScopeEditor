//
//  PSConvertAttributesController.swift
//  PsyScopeEditor
//
//  Created by James on 07/12/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation



class PSConvertAttributesController : NSObject, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate {
    
    //MARK: Outlets
    
    @IBOutlet var fromTextField : NSTextField!
    @IBOutlet var toTextField : NSTextField!
    @IBOutlet var addButton : NSButton!
    @IBOutlet var removeButton : NSButton!
    @IBOutlet var renameTableView : NSTableView!
    
    //MARK: Variables
    var conversions : [String : String] = [:]
    
    
    override func awakeFromNib() {
        removeButton.enabled = false
        addButton.enabled = false
    }
    
    
    //MARK: Button Actions
    
    @IBAction func addButtonClicked(_:AnyObject) {
        if (fromTextField.stringValue == "") || (toTextField.stringValue == "") {
            NSBeep()
            return
        }

        conversions[fromTextField.stringValue] = toTextField.stringValue
        renameTableView.reloadData()
    }
    
    @IBAction func deleteButtonClicked(_:AnyObject) {
        let selectedRow = renameTableView.selectedRow
        let orderedConversions = Array(conversions).sort({$0.0 < $1.0})
        if selectedRow > -1 && selectedRow < orderedConversions.count {
            let key = orderedConversions[selectedRow].0
            conversions[key] = nil
            renameTableView.reloadData()
        }
    }
    
    //MARK: Datasource
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return conversions.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        let conversion = Array(conversions).sort({$0.0 < $1.0})[row]
        return conversion.0 + " >> " + conversion.1
    }
    
    //MARK: Delegate
    
    func tableView(tableView: NSTableView, selectionIndexesForProposedSelection proposedSelectionIndexes: NSIndexSet) -> NSIndexSet {
        let index = proposedSelectionIndexes.firstIndex
        let indexInRange = index > -1 && index < conversions.count
        removeButton.enabled = indexInRange
        return proposedSelectionIndexes
    }
    
    
    //MARK: Textfield
    
    override func controlTextDidChange(obj: NSNotification) {
        let oneTextIsEmpty = (fromTextField.stringValue == "") || (toTextField.stringValue == "")
        addButton.enabled = !oneTextIsEmpty
    }
    
}