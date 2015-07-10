//
//  PSButtonTableViewCell.swift
//  PsyScopeEditor
//
//  Created by James on 01/06/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSButtonTableViewCell : NSTableCellView {
    @IBOutlet var button : NSButton!
    var row : Int!
    var buttonClickBlock : ((Int) -> ())!
    
    @IBAction func buttonClick(_: AnyObject) {
        buttonClickBlock(row)
    }
}