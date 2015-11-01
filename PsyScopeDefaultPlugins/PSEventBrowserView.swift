//
//  PSEventBrowserView.swift
//  PsyScopeEditor
//
//  Created by James on 29/10/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

class PSEventBrowserView: NSTableView {
    
    
    
    var dragSession : NSDraggingSession?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //self.registerForDraggedTypes([pasteBoardType, NSPasteboardTypeString])
        self.setDraggingSourceOperationMask(.Move, forLocal: true)
    }
    
    
    override func mouseDown(theEvent: NSEvent) {
        
        let localLocation = self.convertPoint(theEvent.locationInWindow, fromView: nil)
        let clickedRow = self.rowAtPoint(localLocation)
        
        //select row that was clicked
        self.selectRowIndexes(NSIndexSet(index: clickedRow), byExtendingSelection: false)
        let selectedRow : NSTableCellView = self.viewAtColumn(0, row: clickedRow, makeIfNecessary: false) as! NSTableCellView
        
        let psextension = selectedRow.objectValue as! PSExtension
        
        let imageBounds = NSRect(origin: localLocation, size: NSSize(width: PSConstants.Spacing.iconSize, height: PSConstants.Spacing.iconSize))
        
        let pbItem = NSPasteboardItem()
        pbItem.setString(psextension.type, forType: PSConstants.PSEventBrowserView.pasteboardType)
        
        
        let dragItem = NSDraggingItem(pasteboardWriter: pbItem)
        dragItem.setDraggingFrame(imageBounds, contents: psextension.icon)
        dragSession = self.beginDraggingSessionWithItems([dragItem], event: theEvent, source: self)
    }
    
    override func draggingSession(session: NSDraggingSession, sourceOperationMaskForDraggingContext context: NSDraggingContext) -> NSDragOperation {
        return NSDragOperation.Link
    }
    
}