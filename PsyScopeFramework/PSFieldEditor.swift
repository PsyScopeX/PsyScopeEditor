//
//  PSFieldEditor.swift
//  PsyScopeEditor
//
//  Created by James on 06/08/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

public class PSFieldEditor : NSTextView {
    var scriptData : PSScriptData!
    
    override public func menuForEvent(event: NSEvent) -> NSMenu? {
        return self.menu
    }
    
    override public var menu : NSMenu? {
        get {
            if let entryValueTextField = self.delegate as? PSEntryValueTextField {
                return scriptData.getVaryByMenu(entryValueTextField, action: "menuItemClicked:")
            } else {
                fatalError("Incorrect field editor used - should only be for PSEveryValueTextField and subclasses")
            }
        }
        
        set {
            
        }
    }
    
    public func setup(scriptData : PSScriptData) {
        self.scriptData = scriptData
    }
    
    func optionPressed(menuItem : NSMenuItem) {
        Swift.print(menuItem.title)
    }
}