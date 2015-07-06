//
//  PSPortBuilderWindow.swift
//  PsyScopeEditor
//
//  Created by James on 12/06/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

//to allow menu events to trigger on relevent things
class PSPortBuilderWindow : NSWindow {
    
    var controller : PSPortBuilderController!
    
    func delete(sender: AnyObject?) {
        controller.deleteCurrentlySelectedItem()
    }

    
    override func validateMenuItem(menuItem: NSMenuItem) -> Bool {
        let theAction = menuItem.action
        
        if (theAction == Selector("delete:")) {
            return controller.itemIsCurrentlySelected()
        }
        
        return super.validateMenuItem(menuItem)
    }
    
    override func keyDown(theEvent: NSEvent) {
        if theEvent.charactersIgnoringModifiers == String(Character(UnicodeScalar(NSDeleteCharacter))) {
            controller.deleteCurrentlySelectedItem()
            return
        }
        
        super.keyDown(theEvent)
    }
}