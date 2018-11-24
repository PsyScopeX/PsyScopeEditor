//
//  PSSubjectVariableDialog.swift
//  PsyScopeEditor
//
//  Created by James on 25/05/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

public func PSSubjectVariableDialog(_ variable : PSSubjectVariable, currentValue : String) -> String {
    let new_alert = NSAlert()
    var returnValue : String
    
    switch(variable.dialogType) {
    case let .checkBoxes(values):
        
        if values.count == 0 {
            PSModalAlert("There are no items set for th check box dialog '\(variable.name)'.")
            return currentValue
        }
        
        let inputView = NSView(frame: NSMakeRect(0, 0, 200, CGFloat(24 * values.count)))
        var checkBoxes : [NSButton] = []
        for (index,val) in values.enumerated() {
            let newCheckBox = NSButton(frame: NSMakeRect(0, CGFloat(index * 24), 200, 24))
            newCheckBox.setButtonType(NSButton.ButtonType.switch)
            newCheckBox.title = val
            inputView.addSubview(newCheckBox)
            checkBoxes.append(newCheckBox)
        }
        
        new_alert.accessoryView = inputView
        new_alert.messageText = "Please pick values"
        new_alert.runModal()
        
        var stringValues : [String] = []
        for (index,cb) in checkBoxes.enumerated() {
            if cb.state.rawValue == 1 {
                stringValues.append(values[index])
            }
        }
        
        returnValue = stringValues.joined(separator: " ")
    case let .radioButtons(values):
        
        if values.count == 0 {
            PSModalAlert("There are no items set for the radio button dialog box '\(variable.name)'.")
            return currentValue
        }
        
        let proto = NSButtonCell()
        proto.title = "Button"
        proto.setButtonType(NSButton.ButtonType.radio)
        
        let matrixRect = NSMakeRect(0, 0, 200, CGFloat(values.count * 24))
        let matrix = NSMatrix(frame: matrixRect, mode: NSMatrix.Mode.radioModeMatrix, prototype: proto, numberOfRows: values.count, numberOfColumns: 1)
        new_alert.accessoryView = matrix
        var cells = matrix.cells as! [NSButtonCell]
        for (index, val) in values.enumerated() {
            cells[index].title = val
        }
        
        new_alert.messageText = "Please pick value"
        new_alert.runModal()
        
        returnValue = values[matrix.selectedRow]
        
    default:
        let inputTextView = NSTextField(frame: NSMakeRect(0, 0, 200, 24))
        inputTextView.stringValue = currentValue
        new_alert.accessoryView = inputTextView
        new_alert.messageText = "Please enter value"
        new_alert.runModal()
        returnValue = inputTextView.stringValue
    }
    
    print("returning: \(returnValue)")
    
    return returnValue
}
