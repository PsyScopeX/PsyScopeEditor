//
//  PSAttributeParameter_Event.swift
//  PsyScopeEditor
//
//  Created by James on 02/02/2015.
//

import Foundation

public class PSAttributeParameter_Event : PSAttributeParameter {
    
    var popUpButton : NSPopUpButton!
    
    override public func setCustomControl(visible: Bool) {
        //add popupbutton
        if visible {
            if popUpButton == nil {
                popUpButton = NSPopUpButton(frame: attributeValueControlFrame, pullsDown: false)
                popUpButton.autoresizingMask = NSAutoresizingMaskOptions.ViewWidthSizable
                popUpButton.target = self
                popUpButton.action = "eventSelected:"
                cell.addSubview(popUpButton)
            } else {
                popUpButton.hidden = false
            }
                        updatePopUpMenuContent()
            popUpButton.selectItemWithTitle(currentValue)
        } else {
            if popUpButton != nil {
                popUpButton.hidden = true
            }
        }
    }
    
    
    func eventSelected(item : NSMenuItem) {
        currentValue = item.title
        self.cell.updateScript()
    }
    
    func noneSelected(item : NSMenuItem) {
        currentValue = "NULL"
        self.cell.updateScript()
    }
    
    func updatePopUpMenuContent() {
        
        //start condition events - needs to be updated everytime new event is added, whence in its own routine
        let events = scriptData.getAllEvents()
        
        let new_menu = NSMenu()
        let new_item = NSMenuItem(title: "No Specific Event", action: "noneSelected:", keyEquivalent: "")
        new_item.target = self
        new_item.action = "noneSelected:"
        new_menu.addItem(new_item)
        for event in events {
            let new_item = NSMenuItem(title: event.name, action: "eventSelected:", keyEquivalent: "")
            new_item.target = self
            new_item.action = "eventSelected:"
            new_menu.addItem(new_item)
        }
        
        
        popUpButton.menu = new_menu
    }
}