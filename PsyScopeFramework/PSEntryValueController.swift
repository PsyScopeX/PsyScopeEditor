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
    let scriptData : PSScriptData
    public enum Mode { case mainControl, function }
    public var mode : Mode
    
    public init(mainControl : NSControl, delegate : PSEntryValueControllerDelegate) {
        self.mainControl = mainControl
        self.delegate = delegate
        self.scriptData = delegate.getScriptData()
        self.mode = .mainControl
        super.init()
    }
    
    fileprivate var _entryElement : PSEntryElement = .null
    fileprivate lazy var functionTextField : PSFunctionTextField = PSFunctionTextField()
    
    public var entryElement : PSEntryElement {
        get {
            return _entryElement
        }
        
        set {
            _entryElement = newValue
            switch (newValue) {
            case .function(_):
                hideMainControlDisplayFunctionTextField()
                break
            case .stringToken(_):
                displayMainControlHideFunctionTextField()
                break
            case .list(_):
                hideMainControlDisplayFunctionTextField()
                break
            case .null:
                displayMainControlHideFunctionTextField()
                break
            }
        }
    }
    
    @objc public func varyByMenuCommandClicked(_ menuItem : NSMenuItem) {
        if let val = scriptData.valueForMenuItem(menuItem, original: self.stringValue, originalFullType:  nil) {
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
        mainControl.isHidden = false
        mainControl.isEnabled = true
        functionTextField.isHidden = true
        functionTextField.isEnabled = false
        if mode == .function {
            mainControl.stringValue = self.stringValue
            mode = .mainControl
        }
    }
        
    public func hideMainControlDisplayFunctionTextField() {
        
        if let superview = mainControl.superview, functionTextField.superview != superview {
            superview.addSubview(functionTextField)
            functionTextField.frame = mainControl.frame
            functionTextField.delegate = self
            functionTextField.textColor = NSColor.red
            functionTextField.setupContextMenu(self, action: #selector(PSEntryValueController.varyByMenuCommandClicked(_:)), scriptData: scriptData, controller: self)
        }
        
        mainControl.isHidden = true
        mainControl.isEnabled = false
        functionTextField.isHidden = false
        functionTextField.isEnabled = true
        if mode == .mainControl {
            functionTextField.stringValue = self.stringValue
            mode = .function
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
                entryElement = .null
            } else {
                entryElement = parsedList.listElement
            }
        }
    }
    
    public func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        if control == functionTextField {
            //try and parse
            let parsedValue = PSEntryValueParser(stringValue: control.stringValue)
            if parsedValue.foundErrors {
                NSSound.beep()
                return false
            } else {
                
                return delegate.control(self)
            }
        }
        return true
    }
    
    
}
