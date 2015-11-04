//
//  PSSubjectVariableViews.swift
//  PsyScopeEditor
//
//  Created by James on 23/05/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

public class PSSubjectVariableView : NSView {
    
    let subjectVariable : PSSubjectVariable
    
    public init(subjectVariable : PSSubjectVariable) {
        self.subjectVariable = subjectVariable
        super.init(frame: NSMakeRect(0, 0, 100, PSSubjectVariableView.heightOfViewForDialogType(subjectVariable.dialogType)))
        constructSubViews()
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func constructSubViews() {

        //construct header
        let label = newLabel(NSMakeRect(0, self.frame.height - 17, self.frame.width, 17), value: subjectVariable.name)
        self.addSubview(label)
        
        switch(subjectVariable.dialogType) {
        case .StringType:
            constructInputOnlySubView()
        case .Integer:
            constructInputOnlySubView()
        case .Rational:
            constructInputOnlySubView()
        case .Number:
            constructInputOnlySubView()
        case let .CheckBoxes(values):
            constructCheckBoxesSubView(values)
        case let .RadioButtons(values):
            constructRadioButtonsSubView(values)
        }
    }
    
    func newLabel(frame : NSRect, value : String) -> NSTextField {
        let textField = NSTextField(frame: frame)
        textField.stringValue = value
        textField.bezeled = false
        textField.drawsBackground = false
        textField.editable = false
        textField.selectable = false
        return textField
    }
    
    func constructInputOnlySubView() {
        let textField = NSTextField(frame: NSMakeRect(5, self.frame.height - 39, self.frame.width - 10, 22))
        self.addSubview(textField)
    }
    
    func constructCheckBoxesSubView(values : [String]) {
        /*for val in values {
            var checkBox = NSButton(frame: NSMakeRect(5,self.frame.height - 39, self.frame.width - 10, 22))
        }*/
    }
    
    func constructRadioButtonsSubView(values : [String]) {
        
    }
    
    class func heightOfViewForDialogType(dialogType : PSSubjectVariableType) -> CGFloat {
        switch(dialogType) {
        case let .CheckBoxes(values):
            return CGFloat(22 + (values.count * 17))
        case let .RadioButtons(values):
            return CGFloat(22 + (values.count * 17))
        default:
            return CGFloat(22 + 17)
        }
    }
}