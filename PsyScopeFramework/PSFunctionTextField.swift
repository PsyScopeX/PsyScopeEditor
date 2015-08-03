//
//  PSFunctionTextField.swift
//  PsyScopeEditor
//
//  Created by James on 03/08/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

public class PSFunctionTextField : NSTextField, NSTextViewDelegate {
    

    var scriptData : PSScriptData!
    var menuTarget : AnyObject!
    var menuAction : Selector!
    
    func setupContextMenu(target: AnyObject, action: Selector, scriptData: PSScriptData) {
        self.scriptData = scriptData
        menuTarget = target
        menuAction = action
    }
    
    override public var menu : NSMenu? {
        get {
            return scriptData.getVaryByMenu(menuTarget, action: menuAction)
        }
        set {
        }
    }
    
    public func textView(view: NSTextView, menu: NSMenu, forEvent event: NSEvent, atIndex charIndex: Int) -> NSMenu? {
        return self.menu
    }
}