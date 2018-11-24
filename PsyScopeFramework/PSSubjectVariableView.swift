//
//  PSSubjectVariableViews.swift
//  PsyScopeEditor
//
//  Created by James on 23/05/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

open class PSSubjectVariableView : NSView {
    
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
        case .stringType:
            constructInputOnlySubView()
        case .integer:
            constructInputOnlySubView()
        case .rational:
            constructInputOnlySubView()
        case .number:
            constructInputOnlySubView()
        case let .checkBoxes(values):
            constructCheckBoxesSubView(values)
        case let .radioButtons(values):
            constructRadioButtonsSubView(values)
        }
    }
    
    func newLabel(_ frame : NSRect, value : String) -> NSTextField {
        let textField = NSTextField(frame: frame)
        textField.stringValue = value
        textField.isBezeled = false
        textField.drawsBackground = false
        textField.isEditable = false
        textField.isSelectable = false
        return textField
    }
    
    func constructInputOnlySubView() {
        let textField = NSTextField(frame: NSMakeRect(5, self.frame.height - 39, self.frame.width - 10, 22))
        self.addSubview(textField)
    }
    
    func constructCheckBoxesSubView(_ values : [String]) {
        /*for val in values {
            var checkBox = NSButton(frame: NSMakeRect(5,self.frame.height - 39, self.frame.width - 10, 22))
        }*/
    }
    
    func constructRadioButtonsSubView(_ values : [String]) {
        
    }
    
    class func heightOfViewForDialogType(_ dialogType : PSSubjectVariableType) -> CGFloat {
        switch(dialogType) {
        case let .checkBoxes(values):
            return CGFloat(22 + (values.count * 17))
        case let .radioButtons(values):
            return CGFloat(22 + (values.count * 17))
        default:
            return CGFloat(22 + 17)
        }
    }
}
