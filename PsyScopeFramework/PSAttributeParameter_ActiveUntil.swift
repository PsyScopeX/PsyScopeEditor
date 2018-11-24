//
//  PSAttributeParameter_ActiveUntil.swift
//  PsyScopeEditor
//
//  Created by James on 24/06/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

open class PSAttributeParameter_ActiveUntil : PSAttributeParameter {
    var popUpButton : NSPopUpButton!
    
    var defaultValues = ["End of this event" : "NONE", "All instances" : "FORCE_ONE", "At least one instance" : "FORCE_ALL"]
    
    override open func setCustomControl(_ visible: Bool) {
        
        values = Array(defaultValues.keys)
        values += scriptData.getAllEvents().map({ $0.name })
        
        if visible {
            if popUpButton == nil {
                //add popupbutton
                popUpButton = NSPopUpButton(frame: attributeValueControlFrame, pullsDown: false)
                popUpButton.autoresizingMask = NSAutoresizingMaskOptions.viewWidthSizable
                popUpButton.target = self
                popUpButton.action = "selected:"
                cell.addSubview(popUpButton)
            } else {
                popUpButton.isHidden = false
            }
            
            updatePopUpMenuContent()
            
            for value in values {
                if currentValue.stringValue().lowercased() == value.lowercased() {
                    popUpButton.selectItem(withTitle: value)
                }
            }
        } else {
            if popUpButton != nil {
                popUpButton.isHidden = true
            }
        }
    }
    
    func selected(_ item : NSMenuItem) {
        if let defaultValue = defaultValues[item.title] {
            currentValue = PSGetFirstEntryElementForStringOrNull(defaultValue)
        } else {
            currentValue = PSGetFirstEntryElementForStringOrNull(item.title)
        }
        self.cell.updateScript()
    }
    
    open var values : [String] = []
    
    func updatePopUpMenuContent() {
        
        let new_menu = NSMenu()
        for val in values {
            let new_item = NSMenuItem(title: val, action: "selected:", keyEquivalent: "")
            new_item.target = self
            new_item.action = "selected:"
            new_menu.addItem(new_item)
        }
        popUpButton.menu = new_menu
    }
}
