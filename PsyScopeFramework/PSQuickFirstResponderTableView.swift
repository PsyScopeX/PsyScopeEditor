//
//  PSQuickFirstResponderTableView.swift
//  PsyScopeEditor
//
//  Created by James on 23/06/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

open class PSQuickFirstResponderTableView : NSTableView {
    
    override open func validateProposedFirstResponder(_ responder: NSResponder,
        for event: NSEvent?) -> Bool {
            return true
    }
}
