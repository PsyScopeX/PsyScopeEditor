//
//  PSDialogPropertiesController.swift
//  PsyScopeEditor
//
//  Created by James on 28/04/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSDialogVariablePropertiesController : PSToolPropertyController {
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(entry : Entry, scriptData : PSScriptData) {
        let bundle = NSBundle(forClass:self.dynamicType)
        self.selectedSubjectVariable = PSSubjectVariable(entry: entry, scriptData: scriptData)
        self.items = []
        super.init(nibName: "SubjectVariableView", bundle: bundle, entry: entry, scriptData: scriptData)
        self.entry = entry
    }
    
    var selectedSubjectVariable : PSSubjectVariable
    private var items : [String]
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        refreshControls()
    }
    
    //MARK: Outlets
    
    @IBOutlet var typePopUpButton : NSPopUpButton!
    @IBOutlet var schedulePopUpButton : NSPopUpButton!
    @IBOutlet var itemsTableView : NSTableView!
    @IBOutlet var itemsSegmentedControl : NSSegmentedControl!
    @IBOutlet var recordToLogFileCheck : NSButton!
    
    //MARK: Parse
    
    func refreshControls() {

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
        
        recordToLogFileCheck.state = selectedSubjectVariable.storageOptions.inLogFile ? 1 : 0

    
        itemsTableView.reloadData()
    }
    
    //MARK: Actions / Control delegate
    
    @IBAction func schedulePopUpChanged(_: AnyObject) {
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
        selectedSubjectVariable.dialogType = type
        selectedSubjectVariable.saveToScript()
        refreshControls()
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
    
    @IBAction func recordToLogCheckClicked(_: AnyObject) {
        var existingOptions = selectedSubjectVariable.storageOptions
        if existingOptions.inLogFile != (recordToLogFileCheck.state == 1) {
            existingOptions.inLogFile = (recordToLogFileCheck.state == 1)
            selectedSubjectVariable.storageOptions = existingOptions
        }
        
    }
    
    //MARK: Items tableview delegate
    
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
    
    
    
    func saveType() {

        switch(selectedSubjectVariable.dialogType) {
        case  .CheckBoxes(_):
            selectedSubjectVariable.dialogType = .CheckBoxes(items)
        case .RadioButtons(_):
            selectedSubjectVariable.dialogType = .RadioButtons(items)
        default:
            break
        }

    }
    
}