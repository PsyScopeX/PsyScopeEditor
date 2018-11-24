//
//  PSPortBuilderWindow.swift
//  PsyScopeEditor
//
//  Created by James on 12/06/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

//to allow menu events to trigger on relevent things
class PSPortBuilderWindow : NSWindow, NSWindowDelegate {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.delegate = self
    }
    
    var controller : PSPortBuilderController!
    
    @objc func delete(_ sender: AnyObject?) {
        controller.deleteCurrentlySelectedItem()
    }

    
    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        let theAction = menuItem.action
        
        if (theAction == #selector(PSPortBuilderWindow.delete(_:))) {
            return controller.itemIsCurrentlySelected()
        }
        
        return super.validateMenuItem(menuItem)
    }
    
    override func keyDown(with theEvent: NSEvent) {
        if theEvent.charactersIgnoringModifiers! == String(Character(UnicodeScalar(NSEvent.SpecialKey.delete.rawValue)!)) {
            controller.deleteCurrentlySelectedItem()
            return
        }
        
        super.keyDown(with: theEvent)
    }
    
    func windowDidResize(_ notification: Notification) {
        if controller != nil {controller.refreshDisplay() }
    }
}
