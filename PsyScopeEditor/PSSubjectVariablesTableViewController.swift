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
    var runStartVariables : [PSSubjectVariable] = []
    var runEndVariables : [PSSubjectVariable] = []
    var neverRunVariables : [PSSubjectVariable] = []

    var subjectInformation : PSSubjectInformation?
    var selectedVariable : PSSubjectVariable?
    var reloading : Bool = false
    
    let dragReorderType = "PSSubjectVariablesTableViewController"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tableView.register(forDraggedTypes: [dragReorderType])
    }
    
    func reloadData(_ subjectInformation : PSSubjectInformation) {
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
    func rowForVariable(_ variable : PSSubjectVariable) -> Int? {
        if let index = runStartVariables.index(of: variable) {
            return index + 1
        } else if let index = runEndVariables.index(of: variable) {
            return index + 2 + runStartVariables.count
        } else if let index = neverRunVariables.index(of: variable) {
            return index + 3 + runStartVariables.count + runEndVariables.count
        } else {

            return nil
        }
    }
    
    func variableForRow(_ row : Int) -> PSSubjectVariable? {
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
    
    func groupForRow(_ row : Int) -> PSSubjectVariableSchedule? {
        if row == 0 {
            return .runStart
        } else if row == runStartVariables.count + 1 {
            return .runEnd
        } else if row == runEndVariables.count + runStartVariables.count + 2 {
            return .never
        }
        return nil
    }
    
    func selectItem(_ subjectVariable : PSSubjectVariable?) {
        selectedVariable = subjectVariable
        if let selectedVariable = selectedVariable, row = rowForVariable(selectedVariable) {
            tableView.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
        } else {
            tableView.deselectAll(nil)
        }
    }
    
    func tableView(_ tableView: NSTableView, isGroupRow row: Int) -> Bool {
        return groupForRow(row) != nil
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 3 + runStartVariables.count + runEndVariables.count + neverRunVariables.count
    }
    
    func tableView(_ tableView: NSTableView, selectionIndexesForProposedSelection proposedSelectionIndexes: IndexSet) -> IndexSet {
        if proposedSelectionIndexes.count <= 1 && variableForRow(proposedSelectionIndexes.first) != nil {
            return proposedSelectionIndexes
        } else {
            return IndexSet(integer: -1)
        }
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        
        let selectedRow = selectedVariable == nil ? nil : rowForVariable(selectedVariable!)
        if !reloading && selectedRow != tableView.selectedRow && tableView.selectedRow != -1 {
            selectedVariable = variableForRow(tableView.selectedRow)
            let entry = selectedVariable?.entry
            experimentSetup.selectEntry(entry)
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let identifier = tableColumn == nil ? "NameColumn" : tableColumn!.identifier
        
        guard let view = tableView.make(withIdentifier: identifier, owner: nil) else {
            return nil
        }
        
        //first determine if a variable or a group
        if let group = groupForRow(row) {
            if let buttonView = view as? PSButtonTableViewCell {
                buttonView.button.isHidden = true
                buttonView.textField?.stringValue = ""
            } else  if let tableCellView = view as? NSTableCellView {
                tableCellView.textField?.stringValue = group.description()
            }
        } else if let subjectVariable = variableForRow(row) {
            if let buttonView = view as? PSButtonTableViewCell {
                buttonView.button.isHidden = false
                buttonView.row = row
                
                if identifier == "ValueColumn" {
                    buttonView.textField?.stringValue = subjectVariable.currentValue
                    buttonView.buttonClickBlock = { (clickedRow : Int) -> () in
                        let variable = subjectVariable
                        let newValue = PSSubjectVariableDialog(variable, currentValue: variable.currentValue)
                        variable.currentValue = newValue
                    }
                } else if identifier == "LogColumn" {
                    print("variable \(subjectVariable.name) - \(subjectVariable.storageOptions.inLogFile)")
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
                } else if identifier == "DataColumn" {
                    buttonView.button.state = subjectVariable.storageOptions.inDataFile ? 1 : 0
                    buttonView.buttonClickBlock = { (clickedRow : Int) -> () in
                        let variable = subjectVariable
                        var existingOptions = variable.storageOptions
                        if existingOptions.inDataFile != (buttonView.button.state == 1) {
                            existingOptions.inDataFile = (buttonView.button.state == 1)
                            variable.storageOptions = existingOptions
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
    
    
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
        print("Row: \(row)")
        let pboard = info.draggingPasteboard()
        if let data = pboard.data(forType: dragReorderType),
            rowIndexes : IndexSet = NSKeyedUnarchiver.unarchiveObject(with: data) as? IndexSet {
                
                guard let subjectVariableToMove = variableForRow(rowIndexes.first),
                    subjectInformation = subjectInformation else { return false }
                if let variablePositionToMoveTo = variableForRow(row) {
                    //this is a row with a subject variable so need to get index of where it is
                    var indexToMoveTo : Int = 0
                    if let index = runStartVariables.index(of: variablePositionToMoveTo) {
                        indexToMoveTo = index
                    } else if let index = runEndVariables.index(of: variablePositionToMoveTo) {
                        indexToMoveTo = index
                    } else if let index = neverRunVariables.index(of: variablePositionToMoveTo) {
                        indexToMoveTo = index
                    }
                    subjectInformation.moveVariable(subjectVariableToMove, schedule: variablePositionToMoveTo.storageOptions.schedule, position: indexToMoveTo)
                } else if let groupHeader = groupForRow(row) {
                    //this is a row where currently a group header is present.  This means that the previous group is the header we want to move to..
                    var groupPositionToMoveTo : PSSubjectVariableSchedule
                    var positionToMoveTo : Int
                    switch groupHeader {
                    case .runStart:
                        groupPositionToMoveTo = .runStart // should not be possible this is at zero index....
                        positionToMoveTo = 0
                    case .runEnd:
                        groupPositionToMoveTo = .runStart
                        positionToMoveTo = runStartVariables.count
                    case .never:
                        groupPositionToMoveTo = .runEnd
                        positionToMoveTo = runEndVariables.count
                    }
                    
                    subjectInformation.moveVariable(subjectVariableToMove, schedule: groupPositionToMoveTo, position: positionToMoveTo)
                } else {
                    //must have moved to the end
                    if row >= numberOfRows(in: tableView) {
                        subjectInformation.moveVariable(subjectVariableToMove, schedule: .never, position: neverRunVariables.count)
                    }
                }

                return true
        }
        return false
    }
    
    func tableView(_ tableView: NSTableView, writeRowsWith rowIndexes: IndexSet, to pboard: NSPasteboard) -> Bool {
        // Copy the row numbers to the pasteboard.
        let data = NSKeyedArchiver.archivedData(withRootObject: rowIndexes)
        pboard.declareTypes([dragReorderType], owner: self)
        pboard.setData(data, forType: dragReorderType)
        return true
    }
    
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableViewDropOperation) -> NSDragOperation {
        
        //cannot move to row 0 as that is always a group row
        if row > 0 && dropOperation == .above {
            return NSDragOperation.move
        } else {
            return NSDragOperation()
        }
    }

}
