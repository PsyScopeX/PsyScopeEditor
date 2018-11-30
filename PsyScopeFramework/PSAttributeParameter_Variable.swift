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
    
    override public func setCustomControl(_ visible: Bool) {
        //add popupbutton
        if visible {
            if popUpButton == nil {
                popUpButton = NSPopUpButton(frame: attributeValueControlFrame, pullsDown: false)
                popUpButton.autoresizingMask = NSView.AutoresizingMask.width
                popUpButton.target = self
                popUpButton.action = #selector(PSAttributeParameter_Variable.variableSelected(_:))
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
    
    
    @objc func variableSelected(_ item : NSMenuItem) {
        currentValue = PSGetFirstEntryElementForStringOrNull(item.title)
        self.cell.updateScript()
    }
    
    @objc func noneSelected(_ item : NSMenuItem) {
        currentValue = .null
        self.cell.updateScript()
    }
    
    func updatePopUpMenuContent() {
        
        //start condition events - needs to be updated everytime new event is added, whence in its own routine
        let vars = scriptData.getBaseEntriesOfType(PSType.Variable)
        
        let new_menu = NSMenu()
        let new_item = NSMenuItem(title: "No Specific Variable", action: #selector(PSAttributeParameter_Variable.noneSelected(_:)), keyEquivalent: "")
        new_item.target = self
        new_item.action = #selector(PSAttributeParameter_Variable.noneSelected(_:))
        new_menu.addItem(new_item)
        for vari in vars {
            let new_item = NSMenuItem(title: vari.name, action: #selector(PSAttributeParameter_Variable.variableSelected(_:)), keyEquivalent: "")
            new_item.target = self
            new_item.action = #selector(PSAttributeParameter_Variable.variableSelected(_:))
            new_menu.addItem(new_item)
        }
        
        
        popUpButton.menu = new_menu
    }
}
