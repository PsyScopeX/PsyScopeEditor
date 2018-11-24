//
//  PSButtonCell.swift
//  PsyScopeEditor
//
//  Created by James on 28/05/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

open class PSButtonCell : NSView {
    open var action : ((sender : NSButton) -> ())?
    @IBAction open func buttonPress(_ sender : NSButton) {
        if let a = action {
            a(sender: sender as NSButton)
        }
    }
}
