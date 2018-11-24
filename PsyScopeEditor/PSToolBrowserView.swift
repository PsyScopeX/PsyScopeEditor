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
        
        self.registerForDraggedTypes(convertToNSPasteboardPasteboardTypeArray([pasteBoardType, convertFromNSPasteboardPasteboardType(NSPasteboard.PasteboardType.string)]))
        self.setDraggingSourceOperationMask(.move, forLocal: true)
    }
    

    override func mouseDown(with theEvent: NSEvent) {
        
        let localLocation = self.convert(theEvent.locationInWindow, from: nil)
        let clickedRow = self.row(at: localLocation)

        //select row that was clicked
        self.selectRowIndexes(IndexSet(integer: clickedRow), byExtendingSelection: false)
        guard let selectedRow : NSTableCellView = self.view(atColumn: 0, row: clickedRow, makeIfNecessary: false) as? NSTableCellView, let psextension = selectedRow.objectValue as? PSExtension else {
            return
        }
        
  
        
        let imageBounds = NSRect(origin: localLocation, size: NSSize(width: PSConstants.Spacing.iconSize, height: PSConstants.Spacing.iconSize))
        
        let pbItem = NSPasteboardItem()
        pbItem.setString(psextension.type, forType: convertToNSPasteboardPasteboardType(PSConstants.PSToolBrowserView.pasteboardType))
        
        
        let dragItem = NSDraggingItem(pasteboardWriter: pbItem)
        dragItem.setDraggingFrame(imageBounds, contents: psextension.icon)
        dragSession = self.beginDraggingSession(with: [dragItem], event: theEvent, source: self)
    }
    
    override func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
        return NSDragOperation.link
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSPasteboardPasteboardTypeArray(_ input: [String]) -> [NSPasteboard.PasteboardType] {
	return input.map { key in NSPasteboard.PasteboardType(key) }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSPasteboardPasteboardType(_ input: NSPasteboard.PasteboardType) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSPasteboardPasteboardType(_ input: String) -> NSPasteboard.PasteboardType {
	return NSPasteboard.PasteboardType(rawValue: input)
}
