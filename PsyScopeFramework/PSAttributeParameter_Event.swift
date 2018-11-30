//
//  PSAttributeParameter_Event.swift
//  PsyScopeEditor
//
//  Created by James on 02/02/2015.
//

import Foundation

public class PSAttributeParameter_Event : PSAttributeParameter {
    
    var popUpButton : NSPopUpButton!
    
    override public func setCustomControl(_ visible: Bool) {
        //add popupbutton
        if visible {
            if popUpButton == nil {
                popUpButton = NSPopUpButton(frame: attributeValueControlFrame, pullsDown: false)
                popUpButton.autoresizingMask = NSView.AutoresizingMask.width
                popUpButton.target = self
                popUpButton.action = #selector(PSAttributeParameter_Event.eventSelected(_:))
                cell.addSubview(popUpButton)
            } else {
                popUpButton.isHidden = false
            }
                        updatePopUpMenuContent()
            popUpButton.selectItem(withTitle: currentValue.stringValue())
        } else {
            if popUpButton != nil {
                popUpButton.isHidden = true
            }
        }
    }
    
    
    @objc func eventSelected(_ item : NSMenuItem) {
        currentValue = PSGetFirstEntryElementForStringOrNull(item.title)
        self.cell.updateScript()
    }
    
    @objc func noneSelected(_ item : NSMenuItem) {
        currentValue = .null
        self.cell.updateScript()
    }
    
    func updatePopUpMenuContent() {
        
        //start condition events - needs to be updated everytime new event is added, whence in its own routine
        let events = scriptData.getAllEvents()
        
        let new_menu = NSMenu()
        let new_item = NSMenuItem(title: "No Specific Event", action: #selector(PSAttributeParameter_Event.noneSelected(_:)), keyEquivalent: "")
        new_item.target = self
        new_item.action = #selector(PSAttributeParameter_Event.noneSelected(_:))
        new_menu.addItem(new_item)
        for event in events {
            let new_item = NSMenuItem(title: event.name, action: #selector(PSAttributeParameter_Event.eventSelected(_:)), keyEquivalent: "")
            new_item.target = self
            new_item.action = #selector(PSAttributeParameter_Event.eventSelected(_:))
            new_menu.addItem(new_item)
        }
        
        
        popUpButton.menu = new_menu
    }
}
