//
//  PSGroupValueCell.swift
//  PsyScopeEditor
//
//  Created by James on 25/05/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSGroupValueCellView : NSTableCellView {
    @IBOutlet var button : NSButton!
    var row : Int!
    var buttonClickedBlock : ((Int)->())!
    
    @IBAction func buttonClicked(_: AnyObject) {
        buttonClickedBlock(row)
    }
}