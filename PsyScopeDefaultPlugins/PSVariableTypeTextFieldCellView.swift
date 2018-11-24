//
//  PSVariableTypeTextFieldCellView.swift
//  PsyScopeEditor
//
//  Created by James on 22/04/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation


class PSVariableTypeTextFieldCellView : NSTableCellView, NSTextFieldDelegate {

    var item : PSVariableNamedType? //stores the item it's representing
    
    func control(_ control: NSControl, textShouldBeginEditing fieldEditor: NSText) -> Bool {
        if item != nil {
            return true
        }
        
        NSBeep()
        return false
    }
    
    func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        if let item = item, let tf = textField {
            if tf.stringValue == "" {
                return false
            }
            
            
            item.name = tf.stringValue
        }
        return true
    }
}
