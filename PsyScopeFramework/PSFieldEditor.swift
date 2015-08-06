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
        return scriptData.getVaryByMenu(self, action: "optionPressed:")
    }
    
    override public var menu : NSMenu? {
        get {
            return scriptData.getVaryByMenu(self, action: "optionPressed:")
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