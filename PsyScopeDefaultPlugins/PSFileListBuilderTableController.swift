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
    var weightsColumn : Bool = false
    override func awakeFromNib() {
        previewTableView.doubleAction = "doubleClickInTableView:"
        previewTableView.target = self
    }
    

    
    func refresh(_ latestPreviewData : [[String]], columnNames : [String], weightsColumn : Bool) {
        self.weightsColumn = weightsColumn
        
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
    
    func addNewColumn(_ name : String) {
        let identifier = "\(previewTableView.tableColumns.count + 1)"
        let new_column = NSTableColumn(identifier: identifier)
        let new_header = PSFieldHeaderCell()
        new_header.isEditable = true
        new_header.usesSingleLineMode = true
        new_header.isScrollable = false
        new_header.lineBreakMode = NSLineBreakMode.byTruncatingTail
        new_column.headerCell = new_header
        
        //make weights bold so they seem editable
        if weightsColumn && identifier == "1" {
            let cell = new_column.dataCell as! NSCell
            cell.font = NSFont.boldSystemFont(ofSize: 12)
        }
        
        
        previewTableView.addTableColumn(new_column)
        tableColumns.append(new_column)
        let header_cell = new_column.headerCell as NSTableHeaderCell
        header_cell.title = name
        new_column.headerCell = header_cell
    }
    
    //MARK: Preview Tableview
    func numberOfRows(in tableView: NSTableView) -> Int {
        return previewData.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        let index = Int(tableColumn!.identifier)! - 1
        
        if row < previewData.count {
            let rowData = previewData[row]
            if index < rowData.count {
                return rowData[index]
            }
        }
        return "NULL"
    }
    
    func tableView(_ tableView: NSTableView, shouldEdit tableColumn: NSTableColumn?, row: Int) -> Bool {
        if weightsColumn && tableColumn?.identifier == "1" {
            return true
        } else {
            return false
        }
    }
    
    func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        controller.setWeightsValue(object as! String, row: row)
    }
    
    @IBAction func singleClickEdit(_:AnyObject) {
        let validRow = previewTableView.clickedRow < previewData.count && previewTableView.clickedRow > -1
        
        if validRow && weightsColumn && previewTableView.clickedColumn == 0 {
            previewTableView.editColumn(previewTableView.clickedColumn, row: previewTableView.clickedRow, with: nil, select: true)
        }

    }
    
    //MARK: Header editing
    
    func doubleClickInTableView(_ sender : AnyObject) {
        let row = previewTableView.clickedRow
        let col = previewTableView.clickedColumn
        
        resetHeaders()
        
        if(row == -1 && col >= 0) {
            let tc = previewTableView.tableColumns[col] as NSTableColumn
            let hv = previewTableView.headerView!;
            let hc = tc.headerCell as! PSFieldHeaderCell
            let editor = previewTableView.window!.fieldEditor(true, for: previewTableView)
            hc.isHighlighted = true
            hc.select(withFrame: hv.headerRect(ofColumn: col), in: hv, editor: editor!, delegate: self, start: 0, length: hc.stringValue.characters.count)
            editor?.backgroundColor = NSColor.white
            editor?.drawsBackground = true
            editingHeader = col
        }
    }
    
    func resetHeaders() {
        //already editingheader so need to cancel that...
        if let eh = editingHeader {
            let tc = previewTableView.tableColumns[eh] as NSTableColumn
            let hc = tc.headerCell as! PSFieldHeaderCell
            hc.isHighlighted = false
            let editor = previewTableView.window!.fieldEditor(true, for: previewTableView)
            hc.endEditing(editor!)
        }
    }
    
    func textDidEndEditing(_ notification: Notification) {
        let editor = notification.object as! NSTextView
        let name = editor.string!
        
        if let eh = editingHeader {
            
            controller.fileList.setColumn(name, columnIndex: eh + 1)
            
            let tc = previewTableView.tableColumns[eh] as NSTableColumn
            let hc = tc.headerCell as! PSFieldHeaderCell
            hc.title = name
            
            hc.isHighlighted = false
            hc.endEditing(editor)
            editingHeader = nil
        }
    }
    
}
