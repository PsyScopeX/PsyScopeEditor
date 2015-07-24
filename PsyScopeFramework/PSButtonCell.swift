//
//  PSButtonCell.swift
//  PsyScopeEditor
//
//  Created by James on 28/05/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

public class PSButtonCell : NSView {
    public var action : ((sender : NSButton) -> ())?
    @IBAction public func buttonPress(sender : NSButton) {
        if let a = action {
            a(sender: sender as NSButton)
        }
    }
}