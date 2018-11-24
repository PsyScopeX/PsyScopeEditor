//
//  PSAttributeParameter_String.swift
//  PsyScopeEditor
//
//  Created by James on 04/02/2015.
//

import Foundation

open class PSAttributeParameter_String : PSAttributeParameter, NSTextFieldDelegate {
    
    open var textField : PSCustomMenuNSTextField!
    
    override open func setCustomControl(_ visible: Bool) {
        if visible {
            if textField == nil {
                //add textField
                textField = PSCustomMenuNSTextField(frame: attributeValueControlFrame)
                textField.isBordered = true
                textField.isBezeled  = true
                textField.drawsBackground = true
                textField.alignment = NSTextAlignment.center
                
                
                if let cell = self.cell as? PSListCellView {
                    textField.firstResponderAction = {
                        if let a = cell.firstResponderBlock {
                            a()
                        }
                    }
                }
                cell?.activateViewBlock = { self.textField.becomeFirstResponder() }// luca following the xcode suggestion
                let bcell = textField.cell!
                bcell.lineBreakMode = NSLineBreakMode.byTruncatingTail
                textField.setupContextMenu(self, action: "clickMenuItem:", scriptData: scriptData)
                textField.autoresizingMask = NSAutoresizingMaskOptions.viewWidthSizable
                textField.delegate = self
                cell.addSubview(textField)
            } else {
                textField.isHidden = false
            }
            
            if currentValue.stringValue() == "NULL" {
                textField.stringValue = ""
            } else {
                //is it a bracketed string?
                textField.stringValue = currentValue.stringValue()
            }
        } else {
            if textField != nil {
                textField.isHidden = true
            }
        }
    }
    
    //override this to hide any borders if they appear ugly in table views etc
    open override func hideBorders() {
        textField.isBordered = false
        textField.isBezeled  = false
        textField.drawsBackground = false
    }
    
    override open func controlTextDidEndEditing(_ obj: Notification) {
        //parse and take first value
        currentValue = PSConvertListElementToStringElement(PSGetListElementForString(textField.stringValue))
        self.cell.updateScript()
    }
}


open class PSCustomMenuNSTextField : NSTextField, NSTextViewDelegate {

    var firstResponderAction : (()->())?
    var scriptData : PSScriptData!
    var menuTarget : AnyObject!
    var menuAction : Selector!
    
    func setupContextMenu(_ target: AnyObject, action: Selector, scriptData: PSScriptData) {
        self.scriptData = scriptData
        menuTarget = target
        menuAction = action
    }
    
    override open var menu : NSMenu? {
        get {
            return scriptData.getVaryByMenu(menuTarget, action: menuAction)
        }
        set {
        }
    }
    
    override open func becomeFirstResponder() -> Bool {
        if let fra = firstResponderAction {
            fra()
        }
        return super.becomeFirstResponder()
    }
    
    open func textView(_ view: NSTextView, menu: NSMenu, for event: NSEvent, at charIndex: Int) -> NSMenu? {
        return self.menu
    }
}
