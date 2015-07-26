//
//  PSVariableSelector.swift
//  PsyScopeEditor
//
//  Created by James on 12/06/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSVariableSelector : NSObject {
    
    @IBOutlet var mainWindowController : PSMainWindowController!
    @IBOutlet var popupButton : NSPopUpButton!
    @IBOutlet var iconItem : NSMenuItem!
    var scriptData : PSScriptData!
    var variableNames : [String] = []
    

    
    func update() {
        for variableName in variableNames {
            popupButton.removeItemWithTitle(variableName)
        }
        
        variableNames = mainWindowController.scriptData.getBaseEntriesOfType("Variable").map({ $0.name })
        
        if variableNames.count > 0 {
            popupButton.enabled = true
            popupButton.addItemsWithTitles(variableNames)
        } else {
            popupButton.enabled = false
        }
    }
    
    @IBAction func itemSelected(button : NSPopUpButton) {
        mainWindowController.selectionController.selectObjectForEntryNamed(popupButton.selectedItem!.title)
    }
}