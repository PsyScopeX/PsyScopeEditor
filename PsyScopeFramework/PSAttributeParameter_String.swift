//
//  PSAttributeParameter_String.swift
//  PsyScopeEditor
//
//  Created by James on 04/02/2015.
//

import Foundation

open class PSAttributeParameter_String : PSAttributeParameter, NSTextFieldDelegate {
    
    public var textField : PSCustomMenuNSTextField?
    
    func assertTextField() -> PSCustomMenuNSTextField {
        if textField != nil {
            return textField!
        }
        
        //add textField
        let newTextField = PSCustomMenuNSTextField(frame: attributeValueControlFrame)
        newTextField.isBordered = true
        newTextField.isBezeled  = true
        newTextField.drawsBackground = true
        newTextField.alignment = NSTextAlignment.center
        
        if let frCell = cell as? PSListCellView {
            newTextField.firstResponderAction = {
                if let a = frCell.firstResponderBlock {
                    a()
                }
            }
        }
        
        
        cell.activateViewBlock = { newTextField.becomeFirstResponder() }
        let bcell = newTextField.cell!
        bcell.lineBreakMode = NSLineBreakMode.byTruncatingTail
        newTextField.setupContextMenu(self, action: #selector(PSAttributeParameter.clickMenuItem(_:)), scriptData: scriptData)
        newTextField.autoresizingMask = NSView.AutoresizingMask.width
        newTextField.delegate = self
        cell.addSubview(newTextField)
        self.textField = newTextField
        return newTextField
    }
    
    override open func setCustomControl(_ visible: Bool) {
        
        let textField = assertTextField()
        
        if visible {
            textField.isHidden = false
 
            if currentValue.stringValue() == "NULL" {
                textField.stringValue = ""
            } else {
                //is it a bracketed string?
                textField.stringValue = currentValue.stringValue()
            }
        } else {
             textField.isHidden = true
        }
    }
    
    //override this to hide any borders if they appear ugly in table views etc
    open override func hideBorders() {
        let textField = assertTextField()
        textField.isBordered = false
        textField.isBezeled  = false
        textField.drawsBackground = false
    }
    
    public func controlTextDidEndEditing(_ obj: Notification) {
        let textField = assertTextField()
        guard let cell = cell else { fatalError("Cell of PSAttributeParameter_String not set up before use") }
        
        //parse and take first value
        currentValue = PSConvertListElementToStringElement(PSGetListElementForString(textField.stringValue))
        cell.updateScript()
    }
}


public class PSCustomMenuNSTextField : NSTextField, NSTextViewDelegate {

    var firstResponderAction : (()->())?
    var scriptData : PSScriptData!
    var menuTarget : AnyObject!
    var menuAction : Selector!
    
    func setupContextMenu(_ target: AnyObject, action: Selector, scriptData: PSScriptData) {
        self.scriptData = scriptData
        menuTarget = target
        menuAction = action
    }
    
    override public var menu : NSMenu? {
        get {
            return scriptData.getVaryByMenu(menuTarget, action: menuAction)
        }
        set {
        }
    }
    
    @discardableResult
    override open func becomeFirstResponder() -> Bool {
        if let fra = firstResponderAction {
            fra()
        }
        return super.becomeFirstResponder()
    }
    
    public func textView(_ view: NSTextView, menu: NSMenu, for event: NSEvent, at charIndex: Int) -> NSMenu? {
        return self.menu
    }
}
