//
//  PSEntryValueTextField.swift
//  PsyScopeEditor
//
//  Created by James on 06/08/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

public class PSEntryValueTextField : NSTextField, PSFieldEditorProtocol, NSTextViewDelegate {
    public func textView(view: NSTextView, menu: NSMenu, forEvent event: NSEvent, atIndex charIndex: Int) -> NSMenu? {
        if let view = view as? PSFieldEditor {
            return view.menu
        }
        
        return nil
    }
}