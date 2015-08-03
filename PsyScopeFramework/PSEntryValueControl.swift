//
//  PSEntryValueControl.swift
//  PsyScopeEditor
//
//  Created by James on 03/08/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

public class PSEntryValueControl : NSView, NSTextFieldDelegate {
    @IBOutlet var mainControl : NSControl!
    @IBOutlet var delegate : PSEntryValueControlDelegate!
    private var _entryElement : PSEntryElement = .Null
    private lazy var functionTextField : PSFunctionTextField = PSFunctionTextField()
    
    public var entryElement : PSEntryElement {
        get {
            return _entryElement
        }
        
        set {
            switch (newValue) {
            case let .Function(functionElement):
                break
            case let .StringToken(stringValue):
                break
            case let .List(listElement):
                break
            case .Null:
                break
            }
        }
    }
    
    public func varyByMenuCommandClicked(menuItem : NSMenuItem) {
        if let val = delegate.scriptData().valueForMenuItem(menuItem, original: self.stringValue) {
            
        } else {
            //either define value or enter formula
            if menuItem.title == "Define Value" {
                displayMainControlHideFunctionTextField()
            } else if menuItem.title == "Enter Formula" {
                hideMainControlDisplayFunctionTextField()
            }
        }
    }

    public func displayMainControlHideFunctionTextField() {
        
    }
        
    public func hideMainControlDisplayFunctionTextField() {
        mainControl.hidden = true
        mainControl.enabled = false
        if let superview = superview where functionTextField.superview != superview {
            superview.addSubview(functionTextField)
            functionTextField.frame = mainControl.frame
            functionTextField.delegate = self
            functionTextField.setupContextMenu(self, action: "varyByMenuCommandClicked:", scriptData: delegate.scriptData())
        }
        functionTextField.hidden = false
        functionTextField.enabled = true
    }


    public var stringValue : String {
        get {
            return _entryElement.stringValue()
        }

        set { //will not deal with bracketed strings etc, this must be done in sub class
            //need to parse
            let parsedList = PSEntryValueParser(stringValue: newValue)
            
            if parsedList.values.count == 1 {
                if let theValue = parsedList.values.first {
                    entryElement = theValue
                    return
                } else {
                    fatalError()
                }
            } else {
                entryElement = parsedList.listElement
            }
        }
    }
    
    public func control(control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        if control == functionTextField {
            //try and parse
            let parsedValue = PSEntryValueParser(stringValue: control.stringValue)
            if parsedValue.foundErrors {
                NSBeep()
                return false
            } else {
                return true
            }
        }
        return true
    }
    
    
}