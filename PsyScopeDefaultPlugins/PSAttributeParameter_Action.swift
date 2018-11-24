//
//  PSActionParamter_Action.swift
//  PsyScopeEditor
//
//  Created by James on 04/02/2015.
//

import Foundation

class PSAttributeParameter_Action : PSAttributeParameter {
    var popUpButton : NSPopUpButton!
    
    override func setCustomControl(_ visible: Bool) {
        
        if visible {
            if popUpButton == nil {
                //add popupbutton
                _ = cell.frame.width - PSDefaultConstants.ActionsBuilder.controlsLeftMargin - PSDefaultConstants.ActionsBuilder.controlsRightMargin
                popUpButton = NSPopUpButton(frame: attributeValueControlFrame, pullsDown: false)
                popUpButton.autoresizingMask = NSAutoresizingMaskOptions.viewWidthSizable
                popUpButton.target = self
                popUpButton.action = "actionSelected:"
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
    
    func actionSelected(_ item : NSMenuItem) {
        currentValue = PSGetFirstEntryElementForStringOrNull(item.title)
        self.cell.updateScript()
    }
    
    func noneSelected(_ item : NSMenuItem) {
        currentValue = .null
        self.cell.updateScript()
    }
        
    func updatePopUpMenuContent() {
        //get actions
        
        let new_menu = NSMenu()
        let new_item = NSMenuItem(title: "No Specific Action", action: "noneSelected:", keyEquivalent: "")
        new_item.target = self
        new_item.action = "noneSelected:"
        new_menu.addItem(new_item)
        for (name, _) in scriptData.pluginProvider.actionPlugins as [String : PSActionInterface] {
            let new_item = NSMenuItem(title: name, action: "actionSelected:", keyEquivalent: "")
            new_item.target = self
            new_item.action = "actionSelected:"
            new_menu.addItem(new_item)
        }
        
        popUpButton.menu = new_menu
    }
}
