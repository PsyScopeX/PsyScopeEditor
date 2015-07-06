//
//  PSVariableTypeComboBoxTableCellView.swift
//  PsyScopeEditor
//
//  Created by James on 22/04/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSVariableTypeComboBoxTableCellView : NSTableCellView {
    @IBOutlet var comboBox : NSComboBox!
    var item : AnyObject? //stores the item it's representing

}