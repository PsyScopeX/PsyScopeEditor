//
//  PSVariableSelector.swift
//  PsyScopeEditor
//
//  Created by James on 12/06/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation
/*
 * PSVariableSelector: Loaded in Document.xib. Controls a popupButton that allows the selection of variables (as they do not appear on LayoutBoard)
 * Button appears in LayoutBoard Window (blue x)
 */
class PSVariableSelector : NSObject {
    
    //MARK: Outlets
    
    @IBOutlet var mainWindowController : PSMainWindowController!
    @IBOutlet var popupButton : NSPopUpButton!
    @IBOutlet var iconItem : NSMenuItem!
    
    //MARK: Variables
    
    var scriptData : PSScriptData!
    var variableNames : [String] = []
    
    //MARK: Update
    
    func update() {  // Triggered by PSSelectionController
        
        for variableName in variableNames {
            popupButton.removeItem(withTitle: variableName)
        }
        
        variableNames = mainWindowController.scriptData.getBaseEntriesOfType(PSType.Variable).map({ $0.name })
        
        if variableNames.count > 0 {
            popupButton.isEnabled = true
            popupButton.addItems(withTitles: variableNames)
        } else {
            popupButton.isEnabled = false
        }
    }
    
    //MARK: Actions
    
    @IBAction func itemSelected(_ button : NSPopUpButton) {
        mainWindowController.selectionController.selectObjectForEntryNamed(popupButton.selectedItem!.title)
    }
}
