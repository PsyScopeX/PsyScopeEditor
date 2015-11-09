//
//  PSSubjectGroupingTableView.swift
//  PsyScopeEditor
//
//  Created by James on 11/05/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSSubjectVariablesTableViewController : NSObject, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate {
    
    @IBOutlet var nameColumn : NSTableColumn!
    @IBOutlet var subjectVariablesController: PSSubjectVariablesController!
    @IBOutlet var tableView : NSTableView!
    @IBOutlet var valueColumn : NSTableColumn!
    @IBOutlet var experimentSetup : PSExperimentSetup!
    dynamic var runStartVariables : [PSSubjectVariable] = []
    dynamic var runEndVariables : [PSSubjectVariable] = []
    dynamic var neverRunVariables : [PSSubjectVariable] = []
    var subjectInformation : PSSubjectInformation?
    var selectedVariable : PSSubjectVariable?
    var reloading : Bool = false
    
    let dragReorderType = "PSSubjectVariablesTableViewController"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tableView.registerForDraggedTypes([dragReorderType])
    }
    
    func reloadData(subjectInformation : PSSubjectInformation) {
        reloading = true
        self.subjectInformation = subjectInformation
        self.runStartVariables = subjectInformation.runStartVariables
        self.runEndVariables = subjectInformation.runEndVariables
        self.neverRunVariables = subjectInformation.neverRunVariables
        
        //re-highlight selected item
        selectItem(selectedVariable)
        tableView.reloadData()
        
        reloading = false
    }
    
    //get row for variable taking into account headers, and previous schedule categories of variable
    func rowForVariable(variable : PSSubjectVariable) -> Int? {
        if let index = runStartVariables.indexOf(variable) {
            return index + 1
        } else if let index = runEndVariables.indexOf(variable) {
            return index + 2 + runStartVariables.count
        } else if let index = neverRunVariables.indexOf(variable) {
            return index + 3 + runStartVariables.count + runEndVariables.count
        } else {
            return nil
        }
    }
    
    func variableForRow(row : Int) -> PSSubjectVariable? {
        if row <= 0 { return nil }
        let runStartIndex = row - 1
        if runStartVariables.count > runStartIndex {
            return runStartVariables[runStartIndex]
        }
        let runEndIndex = row - 2 - runStartVariables.count
        if (runEndVariables.count > runEndIndex && runEndIndex >= 0) {
            return runEndVariables[runEndIndex]
        }
        let neverRunIndex = row - 3 - runStartVariables.count - runEndVariables.count
        if (neverRunVariables.count > neverRunIndex && neverRunIndex >= 0) {
            return neverRunVariables[neverRunIndex]
        }
        return nil
    }
    
    func groupForRow(row : Int) -> PSSubjectVariableSchedule? {
        if row == 0 {
            return .RunStart
        } else if row == runStartVariables.count + 1 {
            return .RunEnd
        } else if row == runEndVariables.count + runStartVariables.count + 2 {
            return .Never
        }
        return nil
    }
    
    func selectItem(subjectVariable : PSSubjectVariable?) {
        selectedVariable = subjectVariable
        if let selectedVariable = selectedVariable, row = rowForVariable(selectedVariable) {
            tableView.selectRowIndexes(NSIndexSet(index: row), byExtendingSelection: false)
        } else {
            tableView.deselectAll(nil)
        }
    }
    
    func tableView(tableView: NSTableView, isGroupRow row: Int) -> Bool {
        return groupForRow(row) != nil
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return 3 + runStartVariables.count + runEndVariables.count + neverRunVariables.count
    }
    
    func tableView(tableView: NSTableView, selectionIndexesForProposedSelection proposedSelectionIndexes: NSIndexSet) -> NSIndexSet {
        if proposedSelectionIndexes.count <= 1 && variableForRow(proposedSelectionIndexes.firstIndex) != nil {
            subjectVariablesController.tableViewSelectionBecameActive(tableView)
            return proposedSelectionIndexes
        } else {
            return NSIndexSet(index: -1)
        }
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        
        let selectedRow = selectedVariable == nil ? nil : rowForVariable(selectedVariable!)
        if !reloading && selectedRow != tableView.selectedRow && tableView.selectedRow != -1 {
            selectedVariable = variableForRow(tableView.selectedRow)
            let entry = selectedVariable?.entry
            experimentSetup.selectEntry(entry)
        }
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let identifier = tableColumn == nil ? "NameColumn" : tableColumn!.identifier
        
        guard let view = tableView.makeViewWithIdentifier(identifier, owner: nil) else {
            return nil
        }
        
        //first determine if a variable or a group
        if let group = groupForRow(row) {
            if let buttonView = view as? PSButtonTableViewCell {
                buttonView.button.hidden = true
                buttonView.textField?.stringValue = ""
            } else  if let tableCellView = view as? NSTableCellView {
                tableCellView.textField?.stringValue = group.description()
            }
        } else if let subjectVariable = variableForRow(row) {
            if let buttonView = view as? PSButtonTableViewCell {
                buttonView.button.hidden = false
                buttonView.row = row
                
                if identifier == "ValueColumn" {
                    buttonView.textField?.stringValue = subjectVariable.currentValue
                    buttonView.buttonClickBlock = { (clickedRow : Int) -> () in
                        let variable = subjectVariable
                        let newValue = PSSubjectVariableDialog(variable, currentValue: variable.currentValue)
                        variable.currentValue = newValue
                    }
                } else if identifier == "LogColumn" {
                    buttonView.button.state = subjectVariable.storageOptions.inLogFile ? 1 : 0
                    buttonView.buttonClickBlock = { (clickedRow : Int) -> () in
                        let variable = subjectVariable
                        var existingOptions = variable.storageOptions
                        if existingOptions.inLogFile != (buttonView.button.state == 1) {
                            existingOptions.inLogFile = (buttonView.button.state == 1)
                            variable.storageOptions = existingOptions
                        }
                    }
                } else if identifier == "GroupColumn" {
                    buttonView.button.state = subjectVariable.isGroupingVariable ? 1 : 0
                    buttonView.buttonClickBlock = { (clickedRow : Int) -> () in
                        if subjectVariable.isGroupingVariable != (buttonView.button.state == 1) {
                            subjectVariable.isGroupingVariable = (buttonView.button.state == 1)
                        }
                    }
                }
            } else  if let tableCellView = view as? NSTableCellView {
                tableCellView.textField?.stringValue = subjectVariable.name
            }
        }
        
        
        return view
    }
    
    //MARK: Drag reordering
    
    
    func tableView(tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
        let pboard = info.draggingPasteboard()
        if let data = pboard.dataForType(dragReorderType),
            rowIndexes : NSIndexSet = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? NSIndexSet {
                
                guard let subjectVariableToMove = variableForRow(rowIndexes.firstIndex),
                    subjectInformation = subjectInformation else { return false }
                if let variablePositionToMoveTo = variableForRow(row) {
                    //this is a row with a subject variable so need to get index of where it is
                    var indexToMoveTo : Int = 0
                    if let index = runStartVariables.indexOf(variablePositionToMoveTo) {
                        indexToMoveTo = index
                    } else if let index = runEndVariables.indexOf(variablePositionToMoveTo) {
                        indexToMoveTo = index
                    } else if let index = neverRunVariables.indexOf(variablePositionToMoveTo) {
                        indexToMoveTo = index
                    }
                    subjectInformation.moveVariable(subjectVariableToMove, schedule: variablePositionToMoveTo.storageOptions.schedule, position: indexToMoveTo)
                } else if let groupHeader = groupForRow(row) {
                    //this is a row where currently a group header is present.  This means that the previous group is the header we want to move to..
                    var groupPositionToMoveTo : PSSubjectVariableSchedule
                    var positionToMoveTo : Int
                    switch groupHeader {
                    case .RunStart:
                        groupPositionToMoveTo = .RunStart // should not be possible this is at zero index....
                        positionToMoveTo = 0
                    case .RunEnd:
                        groupPositionToMoveTo = .RunStart
                        positionToMoveTo = runStartVariables.count
                    case .Never:
                        groupPositionToMoveTo = .RunEnd
                        positionToMoveTo = runEndVariables.count
                    }
                    
                    subjectInformation.moveVariable(subjectVariableToMove, schedule: groupPositionToMoveTo, position: positionToMoveTo)
                } else {
                    //must have moved to the end
                    if row >= numberOfRowsInTableView(tableView) {
                        subjectInformation.moveVariable(subjectVariableToMove, schedule: .Never, position: neverRunVariables.count)
                    }
                }

                return true
        }
        return false
    }
    
    func tableView(tableView: NSTableView, writeRowsWithIndexes rowIndexes: NSIndexSet, toPasteboard pboard: NSPasteboard) -> Bool {
        // Copy the row numbers to the pasteboard.
        let data = NSKeyedArchiver.archivedDataWithRootObject(rowIndexes)
        pboard.declareTypes([dragReorderType], owner: self)
        pboard.setData(data, forType: dragReorderType)
        return true
    }
    
    func tableView(tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableViewDropOperation) -> NSDragOperation {
        
        //cannot move to row 0 as that is always a group row
        if row > 0 && dropOperation == .Above {
            return NSDragOperation.Move
        } else {
            return NSDragOperation.None
        }
    }

}