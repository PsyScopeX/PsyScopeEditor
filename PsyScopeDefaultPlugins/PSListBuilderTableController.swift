//
//  PSListBuilderTableController.swift
//  PsyScopeEditor
//
//  Created by James on 19/09/2014.
//

import Cocoa



class PSListBuilderTableController: NSObject, NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate, NSMenuDelegate, PSTableHeaderViewDelegate, PSListTableViewDelegate {
    
    @IBOutlet var listTableView : PSListTableView!
    @IBOutlet var listBuilder : PSListBuilderWindowController!
    @IBOutlet var weightsCheckButton : NSButton!
    
    var scriptData : PSScriptData!
    var listEntry : Entry!
    var attributePicker : PSAttributePicker?
    var list : PSList! = nil
    var nameColumn : NSTableColumn!
    var initialized : Bool = false
    var lastClickedRow : Int = -1
    var lastClickedCol : Int = -1
    var editingHeader : Bool = false
    var listColumns : [NSTableColumn] = []
    var lastCellEditedCoords : (col: Int, row: Int) = (-1, -1)
    var itemTextFields : [NSTextField : Int] = [:]
    var weightsTextFields : [NSTextField : Int] = [:]
    var weights : [Int]?
    
    //MARK: Initialization
    
    override func awakeFromNib() {
        if initialized { return }
        initialized = true //awakeFromNib gets called when setting the owner of new listbuildercells
        listTableView.doubleAction = "doubleClickInTableView:"
        listTableView.target = self
        nameColumn = listTableView.tableColumns.first! as NSTableColumn
        scriptData = listBuilder.scriptData
        listEntry = listBuilder.entry
        
        //setup list entry correctly
        PSList.initializeEntry(listEntry, scriptData: scriptData)
        update()
                
    }
    
    //MARK: Update
    
    func update() {
        
        //remove existing columns
        for ac in listColumns { listTableView.removeTableColumn(ac) }
        listColumns = []
        
        //setup list
        list = PSList(scriptData: scriptData, listEntry: listEntry)
        
        //close if no good
        if list == nil {
            listBuilder.close()
            return
        }
        
        self.weights = list.weightsColumn
        if self.weights != nil {
            weightsCheckButton.state = 1
            let weightsTableColumn = NSTableColumn(identifier: "Weights")
            weightsTableColumn.title = "Weights"
            self.listTableView.addTableColumn(weightsTableColumn)
            listColumns.append(weightsTableColumn)
        } else {
            weightsCheckButton.state = 0
            
        }
        
        //add columns for each field
        for field in list.fields { self.addNewColumn(field) }
        
        //clear array holding textFields for each item
        itemTextFields = [:]
        weightsTextFields = [:]
        
        //reload the data
        self.listTableView.reloadData()
        
        //set the highlighted cell
        if let lce = lastCellEdited { lce.highLight(true) }
    }
    
    
    func addNewColumn(field : PSField) {
        
        let new_column = PSListBuilderColumn(identifier: "\(listColumns.count + 1)", column_field: field)
        let new_header = PSFieldHeaderCell()
        new_header.editable = true
        new_header.usesSingleLineMode = true
        new_header.scrollable = false
        new_header.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        new_column.headerCell = new_header
        listColumns.append(new_column)
        self.listTableView.addTableColumn(new_column)
        
        let header_cell = new_column.headerCell as NSTableHeaderCell
        header_cell.title = field.entry.name
        new_column.headerCell = header_cell
    }
    
    //MARK: Editable headers
    
    func doubleClickInTableView(sender : AnyObject) {
        let row = listTableView.clickedRow
        let col = listTableView.clickedColumn
        
        resetHeaders()
        
        if(row == -1 && col >= 1) {
            
            lastClickedRow = row
            lastClickedCol = col
            let tc = listTableView.tableColumns[col] as NSTableColumn
            let hv = listTableView.headerView!;
            let hc = tc.headerCell as! PSFieldHeaderCell
            //hc.controller = self
            //hc.col = col
            let editor = listTableView.window!.fieldEditor(true, forObject: listTableView)
            hc.highlighted = true
            hc.selectWithFrame(hv.headerRectOfColumn(col), inView: hv, editor: editor!, delegate: self, start: 0, length: hc.stringValue.characters.count)
            editor?.backgroundColor = NSColor.whiteColor()
            editor?.drawsBackground = true
            editingHeader = true
        }
    }
    
    func textDidEndEditing(notification: NSNotification) {
        let editor = notification.object as! NSTextView
        let name = editor.string!
        
        if(lastClickedRow == -1 && lastClickedCol >= 1) {
            
            let fieldEntry = list.fields[lastClickedCol - 1].entry
            scriptData.renameEntry(fieldEntry, nameSuggestion: name)
            
            let tc = listTableView.tableColumns[lastClickedCol] as NSTableColumn
            _ = listTableView.headerView!;
            let hc = tc.headerCell as! PSFieldHeaderCell
            hc.title = fieldEntry.name
            
            hc.highlighted = false
            hc.endEditing(editor)
            editingHeader = false
            
        }
        
    }
    
    func resetHeaders() {
        //already editingheader so need to cancel that...
        if editingHeader {
            let tc = listTableView.tableColumns[lastClickedCol] as NSTableColumn
            _ = listTableView.headerView!;
            let hc = tc.headerCell as! PSFieldHeaderCell
            hc.highlighted = false
            let editor = listTableView.window!.fieldEditor(true, forObject: listTableView)
            hc.endEditing(editor!)
        }
    }
    
    //MARK: Item / Weights text field edit delegate
    
    func control(control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        if let tf = control as? NSTextField {
            if let row = itemTextFields[tf] {
                list.setName(tf.stringValue, forRow: row)
            } else if let row = weightsTextFields[tf] {
                print("Edit weight")
            }
        }
        return true
    }
    
    //MARK: Item menu
    
    func clickMenuItem(sender : NSMenuItem) {
        let field = list.fields[listTableView.columnForMenu - 1]
        let item = field[listTableView.rowForMenu]
        if let s = scriptData.valueForMenuItem(sender, original: item) {
            field[listTableView.rowForMenu] = s
        } else {
            field[listTableView.rowForMenu] = "NULL"
        }
    }
    
    func validateMenu(menu: NSMenu, tableColumn: NSTableColumn, col : Int) {
        for item in menu.itemArray as [NSMenuItem] {
            item.tag = col
        }
    }
    
    //MARK: Item menu actions
    
    @IBAction func setTypeMenuAction(sender : NSMenuItem) {
        //open attribute picker to set the type
            attributePicker = PSAttributePickerType(attributePickedCallback: {
                (type : PSAttributeType, selected : Bool) -> () in
                
                if (selected) {
                    self.list.fields[sender.tag - 1].changeType(type)
                    self.listTableView.reloadData()
                }
    
            }, scriptData: scriptData)
     
            let view : NSView = listTableView.headerView!
            attributePicker!.showAttributeWindow(view)
    }
    
    @IBAction func removeFieldMenuAction(sender : NSMenuItem) {
        list.deleteColumn(sender.tag - 1)
    }
    
    @IBAction func removeRowMenuAction(sender : NSMenuItem) {
        list.deleteRow(sender.tag)
    }
    

    //MARK: TableView
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return list != nil ? list.count : 0
    }
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 30
    }
    
    func tableView(tableView: NSTableView, mouseDownInHeaderOfTableColumn tableColumn: NSTableColumn) {
        resetHeaders()
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let listBuilderColumn = tableColumn as? PSListBuilderColumn else {
            
            let view = tableView.makeViewWithIdentifier("PlainTextField", owner: self) as! NSTableCellView
            view.textField!.delegate = self
            view.textField!.frame = view.frame
            
            //column is for item names or weights
            if tableColumn!.identifier == "Weights"  {
                view.textField!.stringValue = String(self.weights![row])
                weightsTextFields[view.textField!] = row
            } else {
                view.textField!.stringValue = list.nameForRow(row)
                itemTextFields[view.textField!] = row
                
            }
            return view
        }
        

        let item = listBuilderColumn.field[row]
        var att_interface : PSAttributeInterface
        
        if let f = listBuilderColumn.field.interface {
            att_interface = f
        } else {
            att_interface = PSAttributeGeneric()
        }
        
        let attributeParameter = att_interface.attributeParameter() as! PSAttributeParameter
        let cell = PSListCellView(attributeParameter: attributeParameter, interface: att_interface, scriptData: scriptData)
        PSAttributeParameterBuilder(parameter: attributeParameter).setupTableCell(cell, currentValue: item)
        
        
        cell.row = row
        if let col = listColumns.indexOf(listBuilderColumn) {
            cell.col = col + 1
        } else {
            fatalError("Could not find column in the controller's array")
        }
        
        cell.updateScriptBlock = { () -> () in
            self.lastCellEdited = cell
            listBuilderColumn.field[row] = cell.attributeParameter.currentValue
        }
        
        cell.firstResponderBlock = { self.lastCellEdited = cell }
        return cell
    }
    
    func tableView(tableView: NSTableView, selectionIndexesForProposedSelection proposedSelectionIndexes: NSIndexSet) -> NSIndexSet {
        return NSIndexSet(index: -1)
    }

    //MARK: New Item/Field/Weights Buttons
    
    @IBAction func addNewItemButton(_: AnyObject) {
        list.addNewItem()
        listTableView.reloadData()
    }
    
    
    
    @IBAction func addNewFieldButton(sender : AnyObject) {
        
        var testName = "Field"
        let baseName = testName
        var run :Int = 1
        var isFree = false
        repeat {
            isFree = true
            if (run > 1) { testName = baseName + "\(run)" }
            for field in self.list.fields {
                if field.entry.name == testName {
                    isFree = false
                    break
                }
            }
            run++
        } while (!isFree)
        
        let new_field = self.list.addNewField(PSAttributeType(fullType: ""), interface: PSAttributeGeneric())
        scriptData.renameEntry(new_field.entry, nameSuggestion: testName)
        self.addNewColumn(new_field)
        self.listTableView.reloadData()
        
    }
    
    @IBAction func weightsCheckButtonClicked(_:AnyObject) {
        if weightsCheckButton.state == 1 {
            let numberOfRows = list != nil ? list.count : 0
            list.weightsColumn = [Int](count:numberOfRows, repeatedValue: 1)
        } else {
            list.weightsColumn = nil
        }
    }
    
    //MARK: Deleteing
    
    
    func deleteRow(name : String) {
        self.list.deleteRowByName(name)
        self.listTableView.reloadData()
    }
    
    func deleteColumnByName(name : String) {
        for tableColumn in listTableView.tableColumns  {
            if let tc = tableColumn as? PSListBuilderColumn {
                if name == tc.field.entry.name {
                    self.listTableView.removeTableColumn(tc)
                    self.list.deleteColumnByName(name)
                    self.listTableView.reloadData()
                }
            }
        }
    }
    
    func deleteColumn(col : Int) {
        let col = listTableView.tableColumns[col+1] as! PSListBuilderColumn
        self.list.deleteColumnByName(col.field.entry.name)
    }
    
    //MARK: Cell editing
    
    var lastCellEdited : PSListCellView? {
        get {
            if lastCellEditedCoords.col > -1 && lastCellEditedCoords.row > -1 {
                let view: AnyObject? = listTableView.viewAtColumn(lastCellEditedCoords.col, row: lastCellEditedCoords.row, makeIfNecessary: true)
                if let listCellView = view as? PSListCellView {
                    return listCellView
                }
            }
            return nil
        }
        
        set {
            if let lastCell = lastCellEdited {
                lastCell.highLight(false)
            }
            
            if let nc = newValue {
                nc.highLight(true)
                lastCellEditedCoords.col = nc.col
                lastCellEditedCoords.row = nc.row
            } else {
                lastCellEditedCoords.col = -1
                lastCellEditedCoords.row = -1
            }
        }
    }
    
    //MARK: Keyboard shortcuts
    
    func keyDownMessage(theEvent: NSEvent) {
        let keyPressed = theEvent.keyCode
        //println(keyPressed.description)
        if let lastCell = lastCellEdited {
            
            var col = lastCell.col
            var row = lastCell.row
            var switchView = false
            var tabbedView = false
            switch(keyPressed) {
            case 123: //left
                switchView = true
                col--
                break
            case 124: //right
                switchView = true
                col++
                break
            case 125: //down
                switchView = true
                row++
                break
            case 126: //up
                switchView = true
                row--
                break
            case 48: //tab - only needed at end of rows
                tabbedView = true
                if col == (listTableView.numberOfColumns - 1) {
                    col = 1
                    if row == (listTableView.numberOfRows - 1) {
                        row = 0
                    } else {
                        row++
                    }
                }
                break
                
            case 36: //return
                lastCell.activate()
            default:
                break
                
            }
            
            if (switchView || tabbedView) && col >= 1 && row >= 0 && col < listTableView.numberOfColumns && row < listTableView.numberOfRows {
                if let nc = listTableView.viewAtColumn(col, row: row, makeIfNecessary: true) as? PSListCellView {
                    lastCellEdited = nc
                    if (tabbedView) {
                        nc.activate()
                    }
                }
            }
        } else {
            if listTableView.numberOfColumns > 1 && listTableView.numberOfRows > 0 {
                let newCell = listTableView.viewAtColumn(1, row: 0, makeIfNecessary: true) as! PSListCellView
                lastCellEdited = newCell
            }
        }
    }
    

}
