//
//  PSEntryValueControl.swift
//  PsyScopeEditor
//
//  Created by James on 03/08/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

public class PSEntryValueController : NSObject, NSTextFieldDelegate {
    
    
    let mainControl : NSControl
    let delegate : PSEntryValueControllerDelegate
    public let scriptData : PSScriptData
    public enum Mode { case MainControl, Function }
    public var mode : Mode
    
    public init(mainControl : NSControl, delegate : PSEntryValueControllerDelegate) {
        self.mainControl = mainControl
        self.delegate = delegate
        self.scriptData = delegate.getScriptData()
        self.mode = .MainControl
        super.init()
    }
    
    private var _entryElement : PSEntryElement = .Null
    private lazy var functionTextField : PSFunctionTextField = PSFunctionTextField()
    
    public var entryElement : PSEntryElement {
        get {
            return _entryElement
        }
        
        set {
            switch (newValue) {
            case .Function(_):
                hideMainControlDisplayFunctionTextField()
                break
            case .StringToken(_):
                displayMainControlHideFunctionTextField()
                break
            case .List(_):
                hideMainControlDisplayFunctionTextField()
                break
            case .Null:
                displayMainControlHideFunctionTextField()
                break
            }
        }
    }
    
    public func varyByMenuCommandClicked(menuItem : NSMenuItem) {
        if let val = scriptData.valueForMenuItem(menuItem, original: self.stringValue) {
            print(val)
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
        mainControl.hidden = false
        mainControl.enabled = true
        functionTextField.hidden = true
        functionTextField.enabled = false
        if mode == .Function {
            mainControl.stringValue = self.stringValue
            mode = .MainControl
        }
    }
        
    public func hideMainControlDisplayFunctionTextField() {
        
        if let superview = mainControl.superview where functionTextField.superview != superview {
            superview.addSubview(functionTextField)
            functionTextField.frame = mainControl.frame
            functionTextField.delegate = self
            functionTextField.textColor = NSColor.redColor()
            functionTextField.setupContextMenu(self, action: "varyByMenuCommandClicked:", scriptData: scriptData, controller: self)
        }
        
        mainControl.hidden = true
        mainControl.enabled = false
        functionTextField.hidden = false
        functionTextField.enabled = true
        if mode == .MainControl {
            functionTextField.stringValue = self.stringValue
            mode = .Function
        }
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
            } else if parsedList.values.count == 0 {
                entryElement = .Null
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
                
                return delegate.control(self)
            }
        }
        return true
    }
    
    
}