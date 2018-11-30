//
//  PSEntryValueTextField.swift
//  PsyScopeEditor
//
//  Created by James on 06/08/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

@objc public class PSEntryValueTextField : NSTextField, NSTextViewDelegate {
    
    var controller : PSEntryValueController!
    
    open override func awakeFromNib() {
        if let delegate = self.delegate as? PSEntryValueControllerDelegate {
            controller = PSEntryValueController(mainControl: self, delegate: delegate)
        }
    }
    
    public func textView(_ view: NSTextView, menu: NSMenu, for event: NSEvent, at charIndex: Int) -> NSMenu? {
        if let view = view as? PSFieldEditor {
            return view.menu
        }
        
        return nil
    }
    
    
    @objc public func menuItemClicked(_ menuItem : NSMenuItem) {
        controller.varyByMenuCommandClicked(menuItem)
    }
    
    public var superStringValue : String {
        get {
            return super.stringValue
        }
        
        set {
            super.stringValue = newValue
        }
    }
}
