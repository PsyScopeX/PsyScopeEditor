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
                popUpButton.autoresizingMask = NSView.AutoresizingMask.width
                popUpButton.target = self
                popUpButton.action = #selector(PSAttributeParameter_Action.actionSelected(_:))
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
    
    @objc func actionSelected(_ item : NSMenuItem) {
        currentValue = PSGetFirstEntryElementForStringOrNull(item.title)
        self.cell.updateScript()
    }
    
    @objc func noneSelected(_ item : NSMenuItem) {
        currentValue = .null
        self.cell.updateScript()
    }
        
    func updatePopUpMenuContent() {
        //get actions
        
        let new_menu = NSMenu()
        let new_item = NSMenuItem(title: "No Specific Action", action: #selector(PSAttributeParameter_Action.noneSelected(_:)), keyEquivalent: "")
        new_item.target = self
        new_item.action = #selector(PSAttributeParameter_Action.noneSelected(_:))
        new_menu.addItem(new_item)
        for (name, _) in scriptData.pluginProvider.actionPlugins as [String : PSActionInterface] {
            let new_item = NSMenuItem(title: name, action: #selector(PSAttributeParameter_Action.actionSelected(_:)), keyEquivalent: "")
            new_item.target = self
            new_item.action = #selector(PSAttributeParameter_Action.actionSelected(_:))
            new_menu.addItem(new_item)
        }
        
        popUpButton.menu = new_menu
    }
}
