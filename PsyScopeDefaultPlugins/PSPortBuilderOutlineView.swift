//
//  PSPortBuilderOutlineView.swift
//  PsyScopeEditor
//
//  Created by James on 07/04/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSPortBuilderOutlineView : NSOutlineView {
    var portController : PSPortBuilderController!
    override func rightMouseDown(theEvent: NSEvent) {
        let localLocation = self.convertPoint(theEvent.locationInWindow, fromView: nil)
        let clickedRow = self.rowAtPoint(localLocation)
        let clickedCol = self.columnAtPoint(localLocation)
        self.selectRowIndexes(NSIndexSet(index: clickedRow), byExtendingSelection: false)
        if let view = self.viewAtColumn(clickedCol, row: clickedRow, makeIfNecessary: false) {
            
            let item: AnyObject! = self.itemAtRow(clickedRow)
            
            if let _ = item as? PSPort {
                portController.rightClickedPort(view)
            } else if let _ = item as? PSPosition {
                portController.rightClickedPosition(view)
            }
        }
    }
    
    override func keyDown(theEvent: NSEvent) {
        if theEvent.charactersIgnoringModifiers == String(Character(UnicodeScalar(NSDeleteCharacter))) {
            portController.deleteCurrentlySelectedItem()
            return
        }
        super.keyDown(theEvent)
    }
}