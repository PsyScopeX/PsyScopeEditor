//
//  PSQuickFirstResponderTableView.swift
//  PsyScopeEditor
//
//  Created by James on 23/06/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

public class PSQuickFirstResponderTableView : NSTableView {
    
    override public func validateProposedFirstResponder(responder: NSResponder,
        forEvent event: NSEvent?) -> Bool {
            return true
    }
}