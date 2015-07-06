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
    
    var refreshController : ((selectItem: AnyObject?)->())?
    func refreshWithVariableTypeNames(names : [String]) {
        items = names
    }
    
    //MARK: Combobox Datasource
    
    func numberOfItemsInComboBox(aComboBox: NSComboBox) -> Int {
        return items.count
    }
    func comboBox(aComboBox: NSComboBox, objectValueForItemAtIndex index: Int) -> AnyObject {
        return items[index]
    }
    
    func comboBox(aComboBox: NSComboBox, indexOfItemWithStringValue string: String) -> Int {
        if let index = items.indexOf(string) {
            return index
        } else {
            return -1
        }
    }
    
    
    
    //MARK: Combobox Delegate
    
    func comboBoxWillDismiss(notification: NSNotification) {

        /*if let comboBox = notification.object as? NSComboBox,
            superView = comboBox.superview,
            tableCellView = superView as? PSVariableTypeComboBoxTableCellView,
            variableTypeItem : AnyObject = tableCellView.item {
                setNewType(comboBox.stringValue, variableTypeItem: variableTypeItem, comboBox: comboBox)
        }*/
    }
    
    func comboBoxSelectionDidChange(notification: NSNotification) {
        if let comboBox = notification.object as? NSComboBox,
            superView = comboBox.superview,
            tableCellView = superView as? PSVariableTypeComboBoxTableCellView,
            variableTypeItem : AnyObject = tableCellView.item {
                setNewType(comboBox.stringValue, variableTypeItem: variableTypeItem, comboBox: comboBox)
        }
    }
    
    override func controlTextDidEndEditing(obj: NSNotification) {
        if let comboBox = obj.object as? NSComboBox,
            superView = comboBox.superview,
            tableCellView = superView as? PSVariableTypeComboBoxTableCellView,
            variableTypeItem : AnyObject = tableCellView.item {
                setNewType(comboBox.stringValue, variableTypeItem: variableTypeItem, comboBox: comboBox)
        }
    }
    

    func setNewType(typeString : String, variableTypeItem : AnyObject, comboBox : NSComboBox) {

            
        var newTypeEnum : PSVariableTypeEnum = .StringType
        
        
        switch(typeString.lowercaseString) {
        case "integer":
            newTypeEnum = .IntegerType
        case "long_integer":
            newTypeEnum = .LongIntegerType
        case "float":
            newTypeEnum = .FloatType
        case "string":
            newTypeEnum = .StringType
        case "array":
            arraySizeTextField.integerValue = 10
            currentPopoverVariableTypeItem = variableTypeItem
            arraySizePopover.showRelativeToRect(comboBox.bounds, ofView: comboBox, preferredEdge: NSRectEdge.MaxY)
            arraySizeTextField.becomeFirstResponder()
            return
        case "record":
            newTypeEnum = .Record(PSVariableRecord(fields: []))
        default:
            
            //check validity of type
            if !items.contains(typeString) {
                
                //probably trying to create an array
                let stripped = typeString.stringByTrimmingCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
                
                if let arraySize = Int(stripped) where arraySize > 0 {
                    newTypeEnum = .Array(PSVariableArray(count: arraySize, type: PSVariableType()))
                }
                
            } else {
                newTypeEnum = .Defined(typeString)
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
            refreshController(selectItem: nil)
        }
        
    }
    
    //MARK: Array popover delegate
    
    func popoverWillClose(notification: NSNotification) {
        let arraySize = arraySizeTextField.integerValue
        var selectItem: AnyObject? = nil
        if let variableNamedType = currentPopoverVariableTypeItem as? PSVariableNamedType {
            variableNamedType.type.type = .Array(PSVariableArray(count: arraySize, type: PSVariableType()))
            selectItem = variableNamedType
        } else if let variableType = currentPopoverVariableTypeItem as? PSVariableType {
            variableType.type = .Array(PSVariableArray(count: arraySize, type: PSVariableType()))
            selectItem = variableType
        } else {
            fatalError("Items with values should be PSVariableNamedType or PSVariableType")
        }
        currentPopoverVariableTypeItem = nil
        if let refreshController = refreshController {
            refreshController(selectItem: selectItem)
        }
    }
    
    @IBAction func arraySizeTextFieldDataEntered(AnyObject) {
        if let cpi : AnyObject = currentPopoverVariableTypeItem {
            arraySizePopover.performClose(self) //triggers saving
        }
    }
}