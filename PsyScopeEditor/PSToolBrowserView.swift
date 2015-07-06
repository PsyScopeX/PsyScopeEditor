//
//  PSToolBrowserView.swift
//  PsyScopeEditor
//
//  Created by James on 14/07/2014.
//

import Cocoa

class PSToolBrowserViewDelegate : NSObject, NSTableViewDelegate {
    
    @IBOutlet var objectTableView : PSToolBrowserView!
    @IBOutlet var arrayController : NSArrayController!
    
    var tableCellViewIdentifier = "PSToolBrowserViewItem"
    var content : [PSExtension] = []
    var pluginProvider : PSPluginProvider!
    
    func setup(pluginProvider : PSPluginProvider) {
        self.pluginProvider = pluginProvider
        let nib = NSNib(nibNamed: "ToolBrowserViewItem", bundle: NSBundle(forClass:self.dynamicType))
        objectTableView.registerNib(nib!, forIdentifier: tableCellViewIdentifier)
        refresh()
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let new_view  = objectTableView.makeViewWithIdentifier(tableCellViewIdentifier, owner: self) as! PSToolBrowserViewItem
        return new_view
    }
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return PSConstants.Spacing.objectTableViewRowHeight
    }
    

    
    func refresh() {
        //get only tools that should appear in side bar (bug sometimes they are not there)
        _ = pluginProvider.toolPlugins
        
     
        content = pluginProvider.extensions.filter({
            (tool : PSExtension) -> Bool in
            return tool.appearsInToolMenu.boolValue
        })
        
     
        arrayController.content = content
        objectTableView.reloadData()
      
    }
    
}


class PSToolBrowserView: NSTableView {

    
    
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
        let selectedRow : NSTableCellView = self.viewAtColumn(0, row: clickedRow, makeIfNecessary: false) as! NSTableCellView
        
        let psextension = selectedRow.objectValue as! PSExtension
        
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
