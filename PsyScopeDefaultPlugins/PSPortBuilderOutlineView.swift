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
        var localLocation = self.convertPoint(theEvent.locationInWindow, fromView: nil)
        var clickedRow = self.rowAtPoint(localLocation)
        var clickedCol = self.columnAtPoint(localLocation)
        self.selectRowIndexes(NSIndexSet(index: clickedRow), byExtendingSelection: false)
        if let view = self.viewAtColumn(clickedCol, row: clickedRow, makeIfNecessary: false) {
            
            var item: AnyObject! = self.itemAtRow(clickedRow)
            
            if let i = item as? PSPort {
                portController.rightClickedPort(view)
            } else if let i = item as? PSPosition {
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