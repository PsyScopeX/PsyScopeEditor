//
//  PSVariableOutlineViewCellView.swift
//  PsyScopeEditor
//
//  Created by James on 24/04/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSVariableOutlineViewCellView : NSTableCellView {
    
    var updateScriptBlock : (()->()) = { }
    var variableValue : PSVariableValues!
    
    override func controlTextDidEndEditing(_ obj: Notification) {
        variableValue.currentValue = self.textField!.stringValue
        updateScriptBlock()
    }
}
