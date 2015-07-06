//
//  PSActionCell.swift
//  PsyScopeEditor
//
//  Created by James on 16/11/2014.
//  Copyright (c) 2014 James. All rights reserved.
//


import Cocoa

class PSActionCell: NSTableCellView {
    var action : PSActionInterface!
    
    func setup(action : PSActionInterface) {
        self.action = action
        self.textField?.stringValue = action.userFriendlyName()
    }

}