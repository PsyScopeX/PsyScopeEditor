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
        let bundle = Bundle(for:type(of: self))
        self.selectedSubjectVariable = PSSubjectVariable(entry: entry, scriptData: scriptData)
        self.items = []
        super.init(nibName: "SubjectVariableView", bundle: bundle, entry: entry, scriptData: scriptData)
        self.entry = entry
    }
    
    var selectedSubjectVariable : PSSubjectVariable
    fileprivate var items : [String]
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        refreshControls()
    }
    
    //MARK: Outlets
    
    @IBOutlet var typePopUpButton : NSPopUpButton!
    @IBOutlet var schedulePopUpButton : NSPopUpButton!
    @IBOutlet var itemsTableView : NSTableView!
    @IBOutlet var itemsSegmentedControl : NSSegmentedControl!
    @IBOutlet var itemsLabel : NSTextField!
    @IBOutlet var itemsScrollView : NSScrollView!
    @IBOutlet var recordToLogFileCheck : NSButton!
    
    //MARK: Parse
    
    func refreshControls() {

        var type : String
        var buttonValues : [String]? = nil
        switch(selectedSubjectVariable.dialogType) {
        case .stringType:
            type = "String"
        case .integer:
            type = "Integer"
        case .rational:
            type = "Rational"
        case .number:
            type = "Real"
        case let .checkBoxes(values):
            type = "CheckBoxes"
            buttonValues = values
        case let .radioButtons(values):
            type = "RadioButtons"
            buttonValues = values
        }
        
        var schedule : String
        switch(selectedSubjectVariable.storageOptions.schedule) {
        case .runStart:
            schedule = "Experiment Start"
        case .runEnd:
            schedule = "Experiment End"
        case .never:
            schedule = "Never"
        }
        
        schedulePopUpButton.isEnabled = true
        schedulePopUpButton.selectItem(withTitle: schedule)
        
        typePopUpButton.isEnabled = true
        typePopUpButton.selectItem(withTitle: type)
        
        if let buttonValues = buttonValues {
            items = buttonValues
            itemsTableView.isEnabled = true
            itemsScrollView.isHidden = false
            itemsSegmentedControl.isEnabled = true
            itemsSegmentedControl.isHidden = false
            itemsLabel.isHidden = false
        } else {
            items = []
            itemsTableView.isEnabled = false
            itemsScrollView.isHidden = true
            itemsSegmentedControl.isEnabled = false
            itemsSegmentedControl.isHidden = true
            itemsLabel.isHidden = true
            
        }
        
        recordToLogFileCheck.state = selectedSubjectVariable.storageOptions.inLogFile ? 1 : 0

    
        itemsTableView.reloadData()
    }
    
    //MARK: Actions / Control delegate
    
    @IBAction func schedulePopUpChanged(_: AnyObject) {
        var existingOptions = selectedSubjectVariable.storageOptions
        switch(schedulePopUpButton.selectedItem!.title) {
            case "Experiment Start":
                existingOptions.schedule = .runStart
            case "Experiment End":
                existingOptions.schedule = .runEnd
            case "Never":
                existingOptions.schedule = .never
        default:
            break
        }
        selectedSubjectVariable.storageOptions = existingOptions
    }
    
    @IBAction func typePopUpChanged(_: AnyObject) {
        var type : PSSubjectVariableType
        switch(typePopUpButton.selectedItem!.title) {
        case "String":
            type = .stringType
        case "Integer":
            type = .integer
        case "Rational":
            type = .rational
        case "Real":
            type = .number
        case "CheckBoxes":
            type = .checkBoxes([])
        case "RadioButtons":
            type = .radioButtons([])
        default:
            type = .stringType
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
                items.remove(at: itemsTableView.selectedRow)
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
    
    func numberOfRowsInTableView(_ tableView: NSTableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        return items[row] as AnyObject
    }
    
    func tableView(_ tableView: NSTableView, setObjectValue object: AnyObject?, forTableColumn tableColumn: NSTableColumn?, row: Int) {
        items[row] = object as! String
        saveType()
    }
    
    
    
    func saveType() {

        switch(selectedSubjectVariable.dialogType) {
        case  .checkBoxes(_):
            selectedSubjectVariable.dialogType = .checkBoxes(items)
        case .radioButtons(_):
            selectedSubjectVariable.dialogType = .radioButtons(items)
        default:
            break
        }

    }
    
}
