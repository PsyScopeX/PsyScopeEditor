//
//  PSAttributeParameter_Variable.swift
//  PsyScopeEditor
//
//  Created by James on 06/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation


public class PSAttributeParameter_Variable : PSAttributeParameter {
    var popUpButton : NSPopUpButton!
    
    override public func setCustomControl(visible: Bool) {
        //add popupbutton
        if visible {
            if popUpButton == nil {
                popUpButton = NSPopUpButton(frame: attributeValueControlFrame, pullsDown: false)
                popUpButton.autoresizingMask = NSAutoresizingMaskOptions.ViewWidthSizable
                popUpButton.target = self
                popUpButton.action = "variableSelected:"
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
    
    
    func variableSelected(item : NSMenuItem) {
        currentValue = item.title
        self.cell.updateScript()
    }
    
    func noneSelected(item : NSMenuItem) {
        currentValue = "NULL"
        self.cell.updateScript()
    }
    
    func updatePopUpMenuContent() {
        
        //start condition events - needs to be updated everytime new event is added, whence in its own routine
        let vars = scriptData.getBaseEntriesOfType("Variable")
        
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