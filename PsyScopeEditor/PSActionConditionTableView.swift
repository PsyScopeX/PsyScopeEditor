//
//  PSActionConditionTableView.swift
//  PsyScopeEditor
//
//  Created by James on 13/04/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

//cleans up selecting items...
class PSActionConditionTableView : NSTableView {
    override func menu(for event: NSEvent) -> NSMenu? {
        // what row are we at?
        let row = self.row(at: self.convert(event.locationInWindow, from: nil))
        if (row != -1) {
            self.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
            return super.menu(for: event)
        }
        return nil
    }
}
