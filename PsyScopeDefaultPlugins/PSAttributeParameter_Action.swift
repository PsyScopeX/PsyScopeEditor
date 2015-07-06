//
//  PSActionParamter_Action.swift
//  PsyScopeEditor
//
//  Created by James on 04/02/2015.
//

import Foundation

class PSAttributeParameter_Action : PSAttributeParameter {
    var popUpButton : NSPopUpButton!
    
    override func setCustomControl(visible: Bool) {
        
        if visible {
            if popUpButton == nil {
                //add popupbutton
                var width = cell.frame.width - PSDefaultConstants.ActionsBuilder.controlsLeftMargin - PSDefaultConstants.ActionsBuilder.controlsRightMargin
                popUpButton = NSPopUpButton(frame: attributeValueControlFrame, pullsDown: false)
                popUpButton.autoresizingMask = NSAutoresizingMaskOptions.ViewWidthSizable
                popUpButton.target = self
                popUpButton.action = "actionSelected:"
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
    
    func actionSelected(item : NSMenuItem) {
        currentValue = item.title
        self.cell.updateScript()
    }
    
    func noneSelected(item : NSMenuItem) {
        currentValue = "NULL"
        self.cell.updateScript()
    }
        
    func updatePopUpMenuContent() {
        //get actions
        
        var new_menu = NSMenu()
        var new_item = NSMenuItem(title: "No Specific Action", action: "noneSelected:", keyEquivalent: "")
        new_item.target = self
        new_item.action = "noneSelected:"
        new_menu.addItem(new_item)
        for (name, plugin) in scriptData.pluginProvider.actionPlugins as [String : PSActionInterface] {
            var new_item = NSMenuItem(title: name, action: "actionSelected:", keyEquivalent: "")
            new_item.target = self
            new_item.action = "actionSelected:"
            new_menu.addItem(new_item)
        }
        
        popUpButton.menu = new_menu
    }
}