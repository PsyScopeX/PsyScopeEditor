//
//  PSToolBrowserView.swift
//  PsyScopeEditor
//
//  Created by James on 14/07/2014.
//

import Cocoa

class PSToolBrowserView: NSOutlineView {

    
    
    var dragSession : NSDraggingSession?
    var pasteBoardType : String { return PSConstants.PSEventBrowserView.pasteboardType }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.registerForDraggedTypes([pasteBoardType, NSPasteboardTypeString])
        self.setDraggingSourceOperationMask(.Move, forLocal: true)
    }
    

    override func mouseDown(theEvent: NSEvent) {
        
        let localLocation = self.convertPoint(theEvent.locationInWindow, fromView: nil)
        let clickedRow = self.rowAtPoint(localLocation)

        //select row that was clicked
        self.selectRowIndexes(NSIndexSet(index: clickedRow), byExtendingSelection: false)
        guard let selectedRow : NSTableCellView = self.viewAtColumn(0, row: clickedRow, makeIfNecessary: false) as? NSTableCellView, psextension = selectedRow.objectValue as? PSExtension else {
            return
        }
        
  
        
        let imageBounds = NSRect(origin: localLocation, size: NSSize(width: PSConstants.Spacing.iconSize, height: PSConstants.Spacing.iconSize))
        
        let pbItem = NSPasteboardItem()
        pbItem.setString(psextension.type, forType: PSConstants.PSToolBrowserView.pasteboardType)
        
        
        let dragItem = NSDraggingItem(pasteboardWriter: pbItem)
        dragItem.setDraggingFrame(imageBounds, contents: psextension.icon)
        dragSession = self.beginDraggingSessionWithItems([dragItem], event: theEvent, source: self)
    }
    
    override func draggingSession(session: NSDraggingSession, sourceOperationMaskForDraggingContext context: NSDraggingContext) -> NSDragOperation {
        return NSDragOperation.Link
    }
    
}
