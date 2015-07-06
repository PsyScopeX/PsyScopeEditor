//
//  PSEventBrowserDelegate.swift
//  PsyScopeEditor
//
//  Created by James on 09/01/2015.
//

import Foundation

class PSEventBrowserViewDelegate : PSToolBrowserViewDelegate {

    override func refresh() {
        //get only tools that should appear in side bar
        var plugins = pluginProvider.eventPlugins
        
        //because sometimes they are not there when this call is made
        
        
        arrayController.content = pluginProvider.eventExtensions
        objectTableView.reloadData()
    }
}

class PSEventBrowserView: PSToolBrowserView {

    override var pasteBoardType : String { return PSConstants.PSEventBrowserView.pasteboardType }
    
    //needed to override just for PSExtension -> PSEventExtension
    override func mouseDown(theEvent: NSEvent) {
        
        var localLocation = self.convertPoint(theEvent.locationInWindow, fromView: nil)
        var clickedRow = self.rowAtPoint(localLocation)
        
        //select row that was clicked
        self.selectRowIndexes(NSIndexSet(index: clickedRow), byExtendingSelection: false)
        var selectedRow : NSTableCellView = self.viewAtColumn(0, row: clickedRow, makeIfNecessary: false) as! NSTableCellView
        
        var psextension = selectedRow.objectValue as! PSExtension
        
        var imageBounds = NSRect(origin: localLocation, size: NSSize(width: PSConstants.Spacing.iconSize, height: PSConstants.Spacing.iconSize))
        
        var pbItem = NSPasteboardItem()
        pbItem.setString(psextension.type, forType: PSConstants.PSEventBrowserView.pasteboardType)
        
        
        var dragItem = NSDraggingItem(pasteboardWriter: pbItem)
        dragItem.setDraggingFrame(imageBounds, contents: psextension.icon)
        dragSession = self.beginDraggingSessionWithItems([dragItem], event: theEvent, source: self)
    }
}