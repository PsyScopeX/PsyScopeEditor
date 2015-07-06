//
//  PSTemplatePopupButtonController.swift
//  PsyScopeEditor
//
//  Created by James on 10/06/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSTemplatePopupButtonController : NSObject {
    
    @IBOutlet var templatesPopup : NSPopUpButton!
    @IBOutlet var controller : PSTemplateLayoutBoardController!
    
    func refreshTemplatePopUpButton() {
        var current_selection = templatesPopup.selectedItem?.title
        
        var objs = controller.scriptData.getBaseEntries()
        
        objs = objs.filter({ self.isTemplateEntry( $0 ) })
        
        var menu_items : [String] = []
        for template in objs {
            menu_items.append(template.name)
        }
        
        templatesPopup.removeAllItems()
        templatesPopup.addItemsWithTitles(menu_items)
        if controller.templateObject == nil {
            templatesPopup.addItemWithTitle("<No Template Selected>")
        }
        
        if let cs = current_selection {
            templatesPopup.selectItemWithTitle(cs)
        } else {
            templatesPopup.selectItemWithTitle("<No Template Selected>")
        }
    }
    
    func isTemplateEntry(entry : Entry) -> Bool {
        if let templates = controller.scriptData.getSubEntry("Events", entry: entry) {
            return true
        }
        
        if entry.type == "Template" {
            return true
        }
        
        return false
    }
    
    func updateSelection() {
        if controller.templateObject != nil && controller.templateObject.mainEntry != nil {
            templatesPopup.selectItemWithTitle(controller.templateObject.mainEntry.name)
        } else {
            templatesPopup.selectItemWithTitle("<No Template Selected>")
        }
    }
    
    @IBAction func templatesPopUpSelectionMade(sender : AnyObject) {
        var template_name = templatesPopup.selectedItem?.title
        print(template_name)
        //check if it exists
        if let a = controller.scriptData.getBaseEntry(template_name!) {
            controller.selectionInterface.selectEntry(a)
        } else {
            controller.selectionInterface.selectEntry(controller.selectionInterface.getSelectedEntry())
        }
    }

}