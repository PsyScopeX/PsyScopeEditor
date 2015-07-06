//
//  PSAttributeParameter_CustomPopup.swift
//  PsyScopeEditor
//
//  Created by James on 06/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

//override values to tailor this to specific attributes
public class PSAttributeParameter_CustomPopup : PSAttributeParameter {
    var popUpButton : NSPopUpButton!
    
    override public func setCustomControl(visible: Bool) {
        
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
        currentValue = item.title.uppercaseString
        self.cell.updateScript()
    }
    
    public var values : [String] = []
    
    func updatePopUpMenuContent() {
        
        let new_menu = NSMenu()
        for sound in values {
            let new_item = NSMenuItem(title: sound, action: "selected:", keyEquivalent: "")
            new_item.target = self
            new_item.action = "selected:"
            new_menu.addItem(new_item)
        }
        popUpButton.menu = new_menu
    }
}