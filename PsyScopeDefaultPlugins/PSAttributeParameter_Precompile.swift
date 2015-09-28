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
    
    override public func setCustomControl(visible: Bool) {
        
        if visible {
            if allCheck == nil {
                //spacing
                var halfAttributeValueControlFrame = attributeValueControlFrame
                halfAttributeValueControlFrame.size.width = halfAttributeValueControlFrame.size.width / 2
                
                
                //add check box
                allCheck = NSButton(frame: halfAttributeValueControlFrame)
                allCheck.setButtonType(NSButtonType.SwitchButton)
                allCheck.target = self
                allCheck.action = "checkSelected:"
                allCheck.title = "All"
                cell.addSubview(allCheck)
                
                
                let locationAlong = halfAttributeValueControlFrame.offsetBy(dx: halfAttributeValueControlFrame.size.width, dy: 0)
                
                //add number text field
                numberText = NSTextField(frame: locationAlong)
                numberText.autoresizingMask = NSAutoresizingMaskOptions.ViewWidthSizable
                numberText.target = self
                numberText.action = "numberChanged:"
                let intsOnly = NSNumberFormatter()
                intsOnly.maximumFractionDigits = 0
                numberText.formatter = intsOnly
                cell.addSubview(numberText)
            } else {
                allCheck.hidden = false
                numberText.hidden = false
            }
            updateContent()
        } else {
            if allCheck != nil {
                allCheck.hidden = true
                numberText.hidden = true
            }
        }
    }
    
    func checkSelected(item : NSMenuItem) {
        if allCheck.state == 1 {
            currentValue = "All"
        } else {
            currentValue = String(numberText.integerValue)
        }
        self.cell.updateScript()
    }
    
    func numberChanged(_:AnyObject) {
        currentValue = String(numberText.integerValue)
        self.cell.updateScript()
    }
    
    func updateContent() {
        if currentValue.lowercaseString == "all" {
            allCheck.state = 1
            numberText.stringValue = ""
            numberText.enabled = false
        } else if let _ = Int(currentValue) {
            allCheck.state = 0
            numberText.stringValue = currentValue
            numberText.enabled = true
        } else {
            allCheck.state = 0
            numberText.stringValue = "0"
            numberText.enabled = true
        }
    }
}