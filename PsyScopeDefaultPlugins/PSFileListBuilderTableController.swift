//
//  PSFileListBuilderTableController.swift
//  PsyScopeEditor
//
//  Created by James on 24/07/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

class PSFileListBuilderTableController : NSObject, NSTableViewDataSource, NSTableViewDelegate {
    
    @IBOutlet var controller : PSFileListBuilderController!
    @IBOutlet var previewTableView : NSTableView!
    var editingHeader : Int? = nil
    var tableColumns : [NSTableColumn] = []
    var previewData : [[String]] = []
    
    override func awakeFromNib() {
        previewTableView.doubleAction = "doubleClickInTableView:"
        previewTableView.target = self
    }
    

    
    func refresh(latestPreviewData : [[String]], columnNames : [String]) {
        
        while(previewTableView.tableColumns.count > 0) {
            previewTableView.removeTableColumn(previewTableView.tableColumns.last! as NSTableColumn)
        }
        
        tableColumns = []
        previewData = latestPreviewData
        
        for name in columnNames {
            self.addNewColumn(name)
        }
        
        previewTableView.reloadData()
    }
    
    func addNewColumn(name : String) {
        let identifier = "\(previewTableView.tableColumns.count + 1)"
        let new_column = NSTableColumn(identifier: identifier)
        let new_header = PSFieldHeaderCell()
        new_header.editable = true
        new_header.usesSingleLineMode = true
        new_header.scrollable = false
        new_header.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        new_column.headerCell = new_header
        
        previewTableView.addTableColumn(new_column)
        tableColumns.append(new_column)
        let header_cell = new_column.headerCell as NSTableHeaderCell
        header_cell.title = name
        new_column.headerCell = header_cell
    }
    
    //MARK: Preview Tableview
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return previewData.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        let index = Int(tableColumn!.identifier)! - 1
        
        if row < previewData.count {
            let rowData = previewData[row]
            if index < rowData.count {
                return rowData[index]
            }
        }
        return "NULL"
    }
    
    //MARK: Header editing
    
    func doubleClickInTableView(sender : AnyObject) {
        let row = previewTableView.clickedRow
        let col = previewTableView.clickedColumn
        
        resetHeaders()
        
        if(row == -1 && col >= 0) {
            let tc = previewTableView.tableColumns[col] as NSTableColumn
            let hv = previewTableView.headerView!;
            let hc = tc.headerCell as! PSFieldHeaderCell
            let editor = previewTableView.window!.fieldEditor(true, forObject: previewTableView)
            hc.highlighted = true
            hc.selectWithFrame(hv.headerRectOfColumn(col), inView: hv, editor: editor!, delegate: self, start: 0, length: hc.stringValue.characters.count)
            editor?.backgroundColor = NSColor.whiteColor()
            editor?.drawsBackground = true
            editingHeader = col
        }
    }
    
    func resetHeaders() {
        //already editingheader so need to cancel that...
        if let eh = editingHeader {
            let tc = previewTableView.tableColumns[eh] as NSTableColumn
            var hv = previewTableView.headerView!;
            let hc = tc.headerCell as! PSFieldHeaderCell
            hc.highlighted = false
            let editor = previewTableView.window!.fieldEditor(true, forObject: previewTableView)
            hc.endEditing(editor!)
        }
    }
    
    func textDidEndEditing(notification: NSNotification) {
        let editor = notification.object as! NSTextView
        let name = editor.string!
        
        if let eh = editingHeader {
            
            controller.fileList.setColumn(name, columnIndex: eh + 1)
            
            let tc = previewTableView.tableColumns[eh] as NSTableColumn
            var hv = previewTableView.headerView!;
            let hc = tc.headerCell as! PSFieldHeaderCell
            hc.title = name
            
            hc.highlighted = false
            hc.endEditing(editor)
            editingHeader = nil
        }
    }
    
}