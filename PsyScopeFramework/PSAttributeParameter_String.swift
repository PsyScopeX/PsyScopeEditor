//
//  PSAttributeParameter_String.swift
//  PsyScopeEditor
//
//  Created by James on 04/02/2015.
//

import Foundation

public class PSAttributeParameter_String : PSAttributeParameter, NSTextFieldDelegate {
    
    public var textField : PSCustomMenuNSTextField!
    
    override public func setCustomControl(visible: Bool) {
        if visible {
            if textField == nil {
                //add textField
                textField = PSCustomMenuNSTextField(frame: attributeValueControlFrame)
                textField.bordered = true
                textField.bezeled  = true
                textField.drawsBackground = true
                textField.alignment = NSTextAlignment.Center
                
                
                if let cell = self.cell as? PSListCellView {
                    textField.firstResponderAction = {
                        if let a = cell.firstResponderBlock {
                            a()
                        }
                    }
                }
                cell?.activateViewBlock = { self.textField.becomeFirstResponder() }// luca following the xcode suggestion
                let bcell = textField.cell!
                bcell.lineBreakMode = NSLineBreakMode.ByTruncatingTail
                textField.setupContextMenu(self, action: "clickMenuItem:", scriptData: scriptData)
                textField.autoresizingMask = NSAutoresizingMaskOptions.ViewWidthSizable
                textField.delegate = self
                cell.addSubview(textField)
            } else {
                textField.hidden = false
            }
            
            if currentValue == "NULL" {
                textField.stringValue = ""
            } else {
                textField.stringValue = currentValue
            }
        } else {
            if textField != nil {
                textField.hidden = true
            }
        }
    }
    
    //override this to hide any borders if they appear ugly in table views etc
    public override func hideBorders() {
        textField.bordered = false
        textField.bezeled  = false
        textField.drawsBackground = false
    }
    
    override public func controlTextDidEndEditing(obj: NSNotification) {
        if textField.stringValue != "" {
            currentValue = textField.stringValue
        } else {
            currentValue = "NULL"
        }
        self.cell.updateScript()
    }
}


public class PSCustomMenuNSTextField : NSTextField, NSTextViewDelegate {

    var firstResponderAction : (()->())?
    var scriptData : PSScriptData!
    var menuTarget : AnyObject!
    var menuAction : Selector!
    
    func setupContextMenu(target: AnyObject, action: Selector, scriptData: PSScriptData) {
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
    
    override public func becomeFirstResponder() -> Bool {
        if let fra = firstResponderAction {
            fra()
        }
        return super.becomeFirstResponder()
    }
    
    public func textView(view: NSTextView, menu: NSMenu, forEvent event: NSEvent, atIndex charIndex: Int) -> NSMenu? {
        return self.menu
    }
}