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
    override func rightMouseDown(with theEvent: NSEvent) {
        let localLocation = self.convert(theEvent.locationInWindow, from: nil)
        let clickedRow = self.row(at: localLocation)
        let clickedCol = self.column(at: localLocation)
        self.selectRowIndexes(IndexSet(integer: clickedRow), byExtendingSelection: false)
        if let view = self.view(atColumn: clickedCol, row: clickedRow, makeIfNecessary: false) {
            
            let item: AnyObject! = self.item(atRow: clickedRow) as AnyObject
            
            if let _ = item as? PSPort {
                portController.rightClickedPort(view)
            } else if let _ = item as? PSPosition {
                portController.rightClickedPosition(view)
            }
        }
    }
    
    override func keyDown(with theEvent: NSEvent) {
        if theEvent.charactersIgnoringModifiers! == String(Character(UnicodeScalar(NSEvent.SpecialKey.delete.rawValue)!)) {
            portController.deleteCurrentlySelectedItem()
            return
        }
        super.keyDown(with: theEvent)
    }
}
