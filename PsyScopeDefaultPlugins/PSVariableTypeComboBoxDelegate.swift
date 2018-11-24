//
//  PSVariableTypeComboBoxDelegate.swift
//  PsyScopeEditor
//
//  Created by James on 22/04/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSVariableTypeComboBoxDelegate : NSObject, NSComboBoxDataSource, NSComboBoxDelegate, NSPopoverDelegate, NSTextFieldDelegate {
    
    var items : [String] = []
    var currentPopoverVariableTypeItem : AnyObject?
    
    //MARK: Outlets
    @IBOutlet var arraySizePopover : NSPopover!
    @IBOutlet var arraySizeTextField : NSTextField!
    
    //MARK: Refresh
    
    var refreshController : ((_ selectItem: AnyObject?)->())?
    func refreshWithVariableTypeNames(_ names : [String]) {
        items = names
    }
    
    //MARK: Combobox Datasource
    
    func numberOfItems(in aComboBox: NSComboBox) -> Int {
        return items.count
    }
    func comboBox(_ aComboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        return items[index]
    }
    
    func comboBox(_ aComboBox: NSComboBox, indexOfItemWithStringValue string: String) -> Int {
        if let index = items.index(of: string) {
            return index
        } else {
            return -1
        }
    }
    
    
    
    //MARK: Combobox Delegate
    
    func comboBoxWillDismiss(_ notification: Notification) {

        /*if let comboBox = notification.object as? NSComboBox,
            superView = comboBox.superview,
            tableCellView = superView as? PSVariableTypeComboBoxTableCellView,
            variableTypeItem : AnyObject = tableCellView.item {
                setNewType(comboBox.stringValue, variableTypeItem: variableTypeItem, comboBox: comboBox)
        }*/
    }
    
    func comboBoxSelectionDidChange(_ notification: Notification) {
        if let comboBox = notification.object as? NSComboBox,
            let superView = comboBox.superview,
            let tableCellView = superView as? PSVariableTypeComboBoxTableCellView,
            let variableTypeItem : AnyObject = tableCellView.item {
                setNewType(comboBox.stringValue, variableTypeItem: variableTypeItem, comboBox: comboBox)
        }
    }
    
    override func controlTextDidEndEditing(_ obj: Notification) {
        if let comboBox = obj.object as? NSComboBox,
            let superView = comboBox.superview,
            let tableCellView = superView as? PSVariableTypeComboBoxTableCellView,
            let variableTypeItem : AnyObject = tableCellView.item {
                setNewType(comboBox.stringValue, variableTypeItem: variableTypeItem, comboBox: comboBox)
        }
    }
    

    func setNewType(_ typeString : String, variableTypeItem : AnyObject, comboBox : NSComboBox) {

            
        var newTypeEnum : PSVariableTypeEnum = .stringType
        
        
        switch(typeString.lowercased()) {
        case "integer":
            newTypeEnum = .integerType
        case "long_integer":
            newTypeEnum = .longIntegerType
        case "float":
            newTypeEnum = .floatType
        case "string":
            newTypeEnum = .stringType
        case "array":
            arraySizeTextField.integerValue = 10
            currentPopoverVariableTypeItem = variableTypeItem
            arraySizePopover.show(relativeTo: comboBox.bounds, of: comboBox, preferredEdge: NSRectEdge.maxY)
            arraySizeTextField.becomeFirstResponder()
            return
        case "record":
            newTypeEnum = .record(PSVariableRecord(fields: []))
        default:
            
            //check validity of type
            if !items.contains(typeString) {
                
                //probably trying to create an array
                let stripped = typeString.trimmingCharacters(in: CharacterSet.decimalDigits.inverted)
                
                if let arraySize = Int(stripped), arraySize > 0 {
                    newTypeEnum = .array(PSVariableArray(count: arraySize, type: PSVariableType()))
                }
                
            } else {
                newTypeEnum = .defined(typeString)
            }
        }
        
        if let variableNamedType = variableTypeItem as? PSVariableNamedType {
            variableNamedType.type.type = newTypeEnum
        } else if let variableType = variableTypeItem as? PSVariableType {
            variableType.type = newTypeEnum
        } else {
            fatalError("Items with values should be PSVariableNamedType or PSVariableType")
        }
        
        
    
        if let refreshController = refreshController {
            refreshController(nil)
        }
        
    }
    
    //MARK: Array popover delegate
    
    func popoverWillClose(_ notification: Notification) {
        let arraySize = arraySizeTextField.integerValue
        var selectItem: AnyObject? = nil
        if let variableNamedType = currentPopoverVariableTypeItem as? PSVariableNamedType {
            variableNamedType.type.type = .array(PSVariableArray(count: arraySize, type: PSVariableType()))
            selectItem = variableNamedType
        } else if let variableType = currentPopoverVariableTypeItem as? PSVariableType {
            variableType.type = .array(PSVariableArray(count: arraySize, type: PSVariableType()))
            selectItem = variableType
        } else {
            fatalError("Items with values should be PSVariableNamedType or PSVariableType")
        }
        currentPopoverVariableTypeItem = nil
        if let refreshController = refreshController {
            refreshController(selectItem)
        }
    }
    
    @IBAction func arraySizeTextFieldDataEntered(_: AnyObject) {
        if currentPopoverVariableTypeItem != nil {
            arraySizePopover.performClose(self) //triggers saving
        }
    }
}
