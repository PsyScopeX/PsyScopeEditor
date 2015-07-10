//
//  PSSubjectGroupingTableView.swift
//  PsyScopeEditor
//
//  Created by James on 11/05/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSSubjectVariablesTableViewController : NSObject, NSTableViewDelegate, NSTextFieldDelegate {
    
    @IBOutlet var nameColumn : NSTableColumn!
    @IBOutlet var subjectVariablesController: PSSubjectVariablesController!
    @IBOutlet var selectedSubjectVariableController : PSSelectedSubjectVariableController!
    @IBOutlet var tableView : NSTableView!
    @IBOutlet var valueColumn : NSTableColumn!
    @IBOutlet var experimentSetup : PSExperimentSetup!
    dynamic var variables : [PSSubjectVariable] = []
    var selectedRow : Int?
    var reloading : Bool = false
    
    func reloadData(variables : [PSSubjectVariable]) {
        reloading = true
        self.variables = variables
        
        //tableView.reloadData()
        
        
        //highlight selected item
        if let selectedRow = selectedRow {
            print("Setting selected row  \(selectedRow) for \(tableView)")
            tableView.selectRowIndexes(NSIndexSet(index: selectedRow), byExtendingSelection: false)
        }
        reloading = false
    }
    
    func selectItem(subjectVariable : PSSubjectVariable) {
        print("Select item called on \(tableView)")
        if let index = variables.indexOf(subjectVariable) {
            print("selectedRow = \(index)")
            selectedRow = index
            tableView.selectRowIndexes(NSIndexSet(index: index), byExtendingSelection: false)
        } else {
            print("selectedRow = nil")
            selectedRow = nil
            tableView.deselectAll(nil)
        }
    }
    
    func tableView(tableView: NSTableView, selectionIndexesForProposedSelection proposedSelectionIndexes: NSIndexSet) -> NSIndexSet {
        subjectVariablesController.tableViewSelectionBecameActive(tableView)
        return proposedSelectionIndexes
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        if !reloading && selectedRow != tableView.selectedRow && tableView.selectedRow != -1 {
            selectedRow = tableView.selectedRow
            print("Selecting entry on row \(tableView.selectedRow) from tableView \(tableView)")
            experimentSetup.selectEntry(variables[tableView.selectedRow].entry)
        }
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let view = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: nil)!
        if let buttonView = view as? PSButtonTableViewCell {
            buttonView.row = row
            buttonView.buttonClickBlock = { (clickedRow : Int) -> () in
                let variable = self.variables[clickedRow]
                let newValue = PSSubjectVariableDialog(variable, currentValue: variable.currentValue)
                variable.currentValue = newValue
                tableView.reloadData()
            }
        }
        return view
    }
    

}