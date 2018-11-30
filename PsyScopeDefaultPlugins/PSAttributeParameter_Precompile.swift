//
//  PSAttributeParamer_Precompile.swift
//  PsyScopeEditor
//
//  Created by James on 10/08/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

public class PSAttributeParameter_Precompile : PSAttributeParameter {
    var allCheck : NSButton!
    var numberText : NSTextField!
    
    override public func setCustomControl(_ visible: Bool) {
        
        if visible {
            if allCheck == nil {
                //spacing
                var halfAttributeValueControlFrame = attributeValueControlFrame
                halfAttributeValueControlFrame.size.width = halfAttributeValueControlFrame.size.width / 2
                
                
                //add check box
                allCheck = NSButton(frame: halfAttributeValueControlFrame)
                allCheck.setButtonType(NSButton.ButtonType.switch)
                allCheck.target = self
                allCheck.action = #selector(PSAttributeParameter_Precompile.checkSelected(_:))
                allCheck.title = "All"
                cell.addSubview(allCheck)
                
                
                let locationAlong = halfAttributeValueControlFrame.offsetBy(dx: halfAttributeValueControlFrame.size.width, dy: 0)
                
                //add number text field
                numberText = NSTextField(frame: locationAlong)
                numberText.autoresizingMask = NSView.AutoresizingMask.width
                numberText.target = self
                numberText.action = #selector(PSAttributeParameter_Precompile.numberChanged(_:))
                let intsOnly = NumberFormatter()
                intsOnly.maximumFractionDigits = 0
                numberText.formatter = intsOnly
                cell.addSubview(numberText)
            } else {
                allCheck.isHidden = false
                numberText.isHidden = false
            }
            updateContent()
        } else {
            if allCheck != nil {
                allCheck.isHidden = true
                numberText.isHidden = true
            }
        }
    }
    
    @objc func checkSelected(_ item : NSMenuItem) {
        if allCheck.state.rawValue == 1 {
            currentValue = PSGetFirstEntryElementForStringOrNull("All")
        } else {
            currentValue = PSGetFirstEntryElementForStringOrNull(String(numberText.integerValue))
        }
        self.cell.updateScript()
    }
    
    @objc func numberChanged(_:AnyObject) {
        currentValue = PSGetFirstEntryElementForStringOrNull(String(numberText.integerValue))
        self.cell.updateScript()
    }
    
    func updateContent() {
        let stringValue = currentValue.stringValue()
        if stringValue.lowercased() == "all" {
            allCheck.state = NSControl.StateValue.on
            numberText.stringValue = ""
            numberText.isEnabled = false
        } else if let _ = Int(stringValue) {
            allCheck.state = NSControl.StateValue.off
            numberText.stringValue = stringValue
            numberText.isEnabled = true
        } else {
            allCheck.state = NSControl.StateValue.off
            numberText.stringValue = "0"
            numberText.isEnabled = true
        }
    }
}
