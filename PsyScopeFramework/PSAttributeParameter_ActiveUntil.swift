//
//  PSAttributeParameter_ActiveUntil.swift
//  PsyScopeEditor
//
//  Created by James on 24/06/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

public class PSAttributeParameter_ActiveUntil : PSAttributeParameter {
    var popUpButton : NSPopUpButton!
    
    var defaultValues = ["End of this event" : "NONE", "All instances" : "FORCE_ONE", "At least one instance" : "FORCE_ALL"]
    
    override public func setCustomControl(visible: Bool) {
        
        values = defaultValues.keys.array
        values += scriptData.getAllEvents().map({ $0.name })
        
        if visible {
            if popUpButton == nil {
                //add popupbutton
                popUpButton = NSPopUpButton(frame: attributeValueControlFrame, pullsDown: false)
                popUpButton.autoresizingMask = NSAutoresizingMaskOptions.ViewWidthSizable
                popUpButton.target = self
                popUpButton.action = "selected:"
                cell.addSubview(popUpButton)
            } else {
                popUpButton.hidden = false
            }
            
            updatePopUpMenuContent()
            
            for value in values {
                if currentValue.lowercaseString == value.lowercaseString {
                    popUpButton.selectItemWithTitle(value)
                }
            }
        } else {
            if popUpButton != nil {
                popUpButton.hidden = true
            }
        }
    }
    
    func selected(item : NSMenuItem) {
        if let defaultValue = defaultValues[item.title] {
            currentValue = defaultValue
        } else {
            currentValue = item.title
        }
        self.cell.updateScript()
    }
    
    public var values : [String] = []
    
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