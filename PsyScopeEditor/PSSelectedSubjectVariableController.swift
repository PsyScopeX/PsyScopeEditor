//
//  PSSelectedSubjectVariableController.swift
//  PsyScopeEditor
//
//  Created by James on 20/05/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSSelectedSubjectVariableController : NSObject {
    
    @IBOutlet var nameTextField : NSTextField!
    @IBOutlet var typePopUpButton : NSPopUpButton!
    @IBOutlet var schedulePopUpButton : NSPopUpButton!
    @IBOutlet var itemsTableView : NSTableView!
    @IBOutlet var itemsSegmentedControl : NSSegmentedControl!
    @IBOutlet var subjectVariableController : PSSubjectVariablesController!

    
    private var items : [String] = []
    dynamic var selectedSubjectVariable : PSSubjectVariable? = nil
    
    func setSelectedItem(subjectVariable : PSSubjectVariable?) {
        selectedSubjectVariable = subjectVariable
        refreshControls()
    }
    
    @IBAction func swapButtonClicked(_: AnyObject) {
        if let selectedSubjectVariable = selectedSubjectVariable {
            selectedSubjectVariable.isGroupingVariable = !selectedSubjectVariable.isGroupingVariable
            selectedSubjectVariable.saveToScript()
            subjectVariableController.reloadData()
        }
    }
    
    @IBAction func schedulePopUpChanged(_: AnyObject) {
        if let selectedSubjectVariable = selectedSubjectVariable {
            var existingOptions = selectedSubjectVariable.storageOptions
            switch(schedulePopUpButton.selectedItem!.title) {
            case "Experiment Start":
                existingOptions.schedule = .RunStart
            case "Experiment End":
                existingOptions.schedule = .RunEnd
            case "Never":
                existingOptions.schedule = .Never
            default:
                break
            }
            selectedSubjectVariable.storageOptions = existingOptions
        }
    }
    
    @IBAction func typePopUpChanged(_: AnyObject) {
        var type : PSSubjectVariableType
        switch(typePopUpButton.selectedItem!.title) {
        case "String":
            type = .StringType
        case "Integer":
            type = .Integer
        case "Rational":
            type = .Rational
        case "Real":
            type = .Number
        case "CheckBoxes":
            type = .CheckBoxes([])
        case "RadioButtons":
            type = .RadioButtons([])
        default:
            type = .StringType
        }
        if let selectedSubjectVariable = selectedSubjectVariable {
            selectedSubjectVariable.dialogType = type
        }
    }
    
    override func controlTextDidEndEditing(obj: NSNotification) {
        if let selectedSubjectVariable = selectedSubjectVariable {
            selectedSubjectVariable.name = nameTextField.stringValue
        }
    }
    
    
    
    func refreshControls() {
        if let selectedSubjectVariable = selectedSubjectVariable {
            nameTextField.enabled = true
            nameTextField.stringValue = selectedSubjectVariable.name
            
            var type : String
            var buttonValues : [String]? = nil
            switch(selectedSubjectVariable.dialogType) {
            case .StringType:
                type = "String"
            case .Integer:
                type = "Integer"
            case .Rational:
                type = "Rational"
            case .Number:
                type = "Real"
            case let .CheckBoxes(values):
                type = "CheckBoxes"
                buttonValues = values
            case let .RadioButtons(values):
                type = "RadioButtons"
                buttonValues = values
            }
            
            var schedule : String
            switch(selectedSubjectVariable.storageOptions.schedule) {
            case .RunStart:
                schedule = "Experiment Start"
            case .RunEnd:
                schedule = "Experiment End"
            case .Never:
                schedule = "Never"
            }
            
            schedulePopUpButton.enabled = true
            schedulePopUpButton.selectItemWithTitle(schedule)
            
            typePopUpButton.enabled = true
            typePopUpButton.selectItemWithTitle(type)
            
            if let buttonValues = buttonValues {
                items = buttonValues
                itemsTableView.enabled = true
                itemsSegmentedControl.enabled = true
            } else {
                items = []
                itemsTableView.enabled = false
                itemsSegmentedControl.enabled = false
                
            }
            
        } else {
            nameTextField.enabled = false
            typePopUpButton.enabled = false
            itemsTableView.enabled = false
            itemsSegmentedControl.enabled = false
        }
        
        itemsTableView.reloadData()
    }
    
    
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return items.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        return items[row]
    }
    
    func tableView(tableView: NSTableView, setObjectValue object: AnyObject?, forTableColumn tableColumn: NSTableColumn?, row: Int) {
        items[row] = object as! String
        saveType()
    }
    
    @IBAction func itemsSegmentedControlClicked(_: AnyObject) {
        switch(itemsSegmentedControl.selectedSegment) {
        case 0: // add
            items.append("Item")
        case 1: // remove
            if itemsTableView.selectedRow > -1 {
                items.removeAtIndex(itemsTableView.selectedRow)
            }
        default:
            break
        }
        saveType()
        refreshControls()
    }
    
    func saveType() {
        if let selectedSubjectVariable = selectedSubjectVariable {
            switch(selectedSubjectVariable.dialogType) {
            case let .CheckBoxes(values):
                selectedSubjectVariable.dialogType = .CheckBoxes(items)
            case let .RadioButtons(values):
                selectedSubjectVariable.dialogType = .RadioButtons(items)
            default:
                break
            }
        }
    }
}