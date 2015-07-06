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
    override func menuForEvent(event: NSEvent) -> NSMenu? {
        // what row are we at?
        let row = self.rowAtPoint(self.convertPoint(event.locationInWindow, fromView: nil))
        if (row != -1) {
            self.selectRowIndexes(NSIndexSet(index: row), byExtendingSelection: false)
            return super.menuForEvent(event)
        }
        return nil
    }
}