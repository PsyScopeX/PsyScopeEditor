//
//  PSFunctionTextField.swift
//  PsyScopeEditor
//
//  Created by James on 03/08/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

open class PSFunctionTextField : NSTextField, NSTextViewDelegate {
    

    var controller : PSEntryValueController!
    var scriptData : PSScriptData!
    var menuTarget : AnyObject!
    var menuAction : Selector!
    
    func setupContextMenu(_ target: AnyObject, action: Selector, scriptData: PSScriptData, controller : PSEntryValueController) {
        self.scriptData = scriptData
        menuTarget = target
        menuAction = action
        self.controller = controller
    }
    
    open func update() {
        self.stringValue = controller.stringValue
    }
    
    override open var menu : NSMenu? {
        get {
            return scriptData.getVaryByMenu(menuTarget, action: menuAction)
        }
        set {
        }
    }
    
    open func textView(_ view: NSTextView, menu: NSMenu, for event: NSEvent, at charIndex: Int) -> NSMenu? {
        return self.menu
    }
}
