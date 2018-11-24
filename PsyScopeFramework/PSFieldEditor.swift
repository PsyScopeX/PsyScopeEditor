//
//  PSFieldEditor.swift
//  PsyScopeEditor
//
//  Created by James on 06/08/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

open class PSFieldEditor : NSTextView {
    var scriptData : PSScriptData!
    
    override open func menu(for event: NSEvent) -> NSMenu? {
        return self.menu
    }
    
    override open var menu : NSMenu? {
        get {
            if let entryValueTextField = self.delegate as? PSEntryValueTextField {
                return scriptData.getVaryByMenu(entryValueTextField, action: "menuItemClicked:")
            } else {
                fatalError("Incorrect field editor used - should only be for PSEntryValueTextField and subclasses")
            }
        }
        
        set {
            
        }
    }
    
    open func setup(_ scriptData : PSScriptData) {
        self.scriptData = scriptData
    }
    
    func optionPressed(_ menuItem : NSMenuItem) {
        Swift.print(menuItem.title)
    }
}
