//
//  PSAttributeParameter_Variable.swift
//  PsyScopeEditor
//
//  Created by James on 06/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation


open class PSAttributeParameter_Variable : PSAttributeParameter {
    var popUpButton : NSPopUpButton!
    
    override open func setCustomControl(_ visible: Bool) {
        //add popupbutton
        if visible {
            if popUpButton == nil {
                popUpButton = NSPopUpButton(frame: attributeValueControlFrame, pullsDown: false)
                popUpButton.autoresizingMask = NSAutoresizingMaskOptions.viewWidthSizable
                popUpButton.target = self
                popUpButton.action = "variableSelected:"
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
    
    
    func variableSelected(_ item : NSMenuItem) {
        currentValue = PSGetFirstEntryElementForStringOrNull(item.title)
        self.cell.updateScript()
    }
    
    func noneSelected(_ item : NSMenuItem) {
        currentValue = .null
        self.cell.updateScript()
    }
    
    func updatePopUpMenuContent() {
        
        //start condition events - needs to be updated everytime new event is added, whence in its own routine
        let vars = scriptData.getBaseEntriesOfType(PSType.Variable)
        
        let new_menu = NSMenu()
        let new_item = NSMenuItem(title: "No Specific Variable", action: "noneSelected:", keyEquivalent: "")
        new_item.target = self
        new_item.action = "noneSelected:"
        new_menu.addItem(new_item)
        for vari in vars {
            let new_item = NSMenuItem(title: vari.name, action: "variableSelected:", keyEquivalent: "")
            new_item.target = self
            new_item.action = "variableSelected:"
            new_menu.addItem(new_item)
        }
        
        
        popUpButton.menu = new_menu
    }
}
