//
//  PSConditionCell.swift
//  PsyScopeEditor
//
//  Created by James on 16/11/2014.
//  Copyright (c) 2014 James. All rights reserved.
//

import Cocoa

class PSConditionCell : NSTableCellView {
    var condition : PSActionInterface!
    
    func setup(condition : PSActionInterface) {
        self.condition = condition
        self.textField?.stringValue = condition.userFriendlyName()
    }
}