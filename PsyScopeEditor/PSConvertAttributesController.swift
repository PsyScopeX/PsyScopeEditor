//
//  PSConvertAttributesController.swift
//  PsyScopeEditor
//
//  Created by James on 07/12/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation


/**
 * PSConvertAttributesController: Controller in ConvertEvents.xib to allow the selection of attributes to be changed during conversion of events in PSConvertEvents.  User enters the name of an existing attribute, and the name to change it to, then clicks add.
*/
class PSConvertAttributesController : NSObject, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate {
    
    //MARK: Outlets
    
    @IBOutlet var fromTextField : NSTextField!
    @IBOutlet var toTextField : NSTextField!
    @IBOutlet var addButton : NSButton!
    @IBOutlet var removeButton : NSButton!
    @IBOutlet var renameTableView : NSTableView!
    
    //MARK: Variables
    
    var conversions : [String : String] = [:]
    
    //MARK: Startup
    
    override func awakeFromNib() {
        removeButton.isEnabled = false
        addButton.isEnabled = false
    }
    
    
    //MARK: Button Actions
    
    @IBAction func addButtonClicked(_:AnyObject) {
        if (fromTextField.stringValue == "") || (toTextField.stringValue == "") {
            //cannot have blank strings on from or to text fields
            NSSound.beep()
            return
        }

        conversions[fromTextField.stringValue] = toTextField.stringValue
        renameTableView.reloadData()
    }
    
    @IBAction func deleteButtonClicked(_:AnyObject) {
        let selectedRow = renameTableView.selectedRow
        let orderedConversions = Array(conversions).sorted(by: {$0.0 < $1.0})
        if selectedRow > -1 && selectedRow < orderedConversions.count {
            let key = orderedConversions[selectedRow].0
            conversions[key] = nil
            renameTableView.reloadData()
        }
    }
    
    //MARK: Datasource
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return conversions.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        let conversion = Array(conversions).sorted(by: {$0.0 < $1.0})[row]
        return conversion.0 + " >> " + conversion.1
    }
    
    //MARK: Delegate
    
    func tableView(_ tableView: NSTableView, selectionIndexesForProposedSelection proposedSelectionIndexes: IndexSet) -> IndexSet {
        let index = proposedSelectionIndexes.first!
        let indexInRange = index > -1 && index < conversions.count
        removeButton.isEnabled = indexInRange
        return proposedSelectionIndexes
    }
    
    
    //MARK: Textfield
    
    func controlTextDidChange(_ obj: Notification) {
        let oneTextIsEmpty = (fromTextField.stringValue == "") || (toTextField.stringValue == "")
        addButton.isEnabled = !oneTextIsEmpty
    }
    
}
