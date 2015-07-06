//
//  PSListBuilderTableController.swift
//  PsyScopeEditor
//
//  Created by James on 19/09/2014.
//

import Cocoa



class PSListBuilderTableController: NSObject, NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate, NSMenuDelegate, PSTableHeaderViewDelegate, PSListTableViewDelegate {
    
    @IBOutlet var listTableView : PSListTableView!
    @IBOutlet var listBuilder : PSListBuilder!
    var scriptData : PSScriptData!
    var listEntry : Entry!
    var attributePicker : PSAttributePicker?
    var list : PSList! = nil
    var nameColumn : NSTableColumn!
    var initialized : Bool = false
    
    var registeredForChanges : Bool = false {
        willSet {
            if newValue != registeredForChanges {
                if newValue {
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: "docMocChanged:", name: NSManagedObjectContextObjectsDidChangeNotification, object: scriptData.docMoc)
                } else {
                    NSNotificationCenter.defaultCenter().removeObserver(self)
                }
            }
        }
    }

    override func awakeFromNib() {
        if initialized { return }
        initialized = true //awakeFromNib gets called when setting the owner of new listbuildercells
        listTableView.doubleAction = "doubleClickInTableView:"
        listTableView.target = self
        nameColumn = listTableView.tableColumns.first! as NSTableColumn
        scriptData = listBuilder.scriptData
        listEntry = listBuilder.listEntry
        PSList.initializeEntry(listEntry, scriptData: scriptData)
        update()
                
    }
    
    func resetHeaders() {
        //already editingheader so need to cancel that...
        if editingHeader {
            let tc = listTableView.tableColumns[lastClickedCol] as NSTableColumn
            var hv = listTableView.headerView!;
            let hc = tc.headerCell as! PSFieldHeaderCell
            hc.highlighted = false
            let editor = listTableView.window!.fieldEditor(true, forObject: listTableView)
            hc.endEditing(editor!)
        }
    }
    
    func validateMenu(menu: NSMenu, tableColumn: NSTableColumn, col : Int) {
        for item in menu.itemArray as [NSMenuItem] {
            item.tag = col
        }
    }
    
    @IBAction func setTypeMenuAction(sender : NSMenuItem) {
        //open attribute picker to set the type
            attributePicker = PSAttributePickerType(attributePickedCallback: {
                (type : PSAttributeType, selected : Bool) -> () in
                
                if (selected) {
                    self.list.fields[sender.tag - 1].changeType(type)
                    self.listTableView.reloadData()
                }
    
            }, scriptData: scriptData)
     
            var view : NSView = listTableView.headerView!
            attributePicker!.showAttributeWindow(view)
    }
    
    @IBAction func removeFieldMenuAction(sender : NSMenuItem) {
        list.deleteColumn(sender.tag - 1)
    }
    
    @IBAction func removeRowMenuAction(sender : NSMenuItem) {
        list.deleteRow(sender.tag)
    }
    
    var lastClickedRow : Int = -1
    var lastClickedCol : Int = -1
    var editingHeader : Bool = false
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
        var editor = notification.object as! NSTextView
        var name = editor.string!
        
        if(lastClickedRow == -1 && lastClickedCol >= 1) {
            
            let fieldEntry = list.fields[lastClickedCol - 1].entry
            scriptData.renameEntry(fieldEntry, nameSuggestion: name)
            
            var tc = listTableView.tableColumns[lastClickedCol] as NSTableColumn
            var hv = listTableView.headerView!;
            var hc = tc.headerCell as! PSFieldHeaderCell
            hc.title = fieldEntry.name
            
            hc.highlighted = false
            hc.endEditing(editor)
            editingHeader = false
            
        }

    }
    
    
    func docMocChanged(notification : NSNotification) {
        update()
    }
 
    func update() {
        if listEntry.deleted ||
            listEntry.layoutObject == nil {
                //object has been deleted, so need to close window
                listBuilder.closeWindow()
        }
        
        
        
        for ac in addedColumns {
            listTableView.removeTableColumn(ac)
        }
        addedColumns = []
        list = PSList(scriptData: scriptData, listEntry: listEntry)
        if list == nil {
            listBuilder.closeWindow()
            return
        }
        for field in list.fields {
            self.addNewColumn(field)
        }
        itemTextFields = [:]
        self.listTableView.reloadData()
        if let lce = lastCellEdited {
            lce.highLight(true)
        }
    }
    
    func tableView(tableView: NSTableView, mouseDownInHeaderOfTableColumn tableColumn: NSTableColumn) {
        resetHeaders()
    }


    func clickMenuItem(sender : NSMenuItem) {
        var field = list.fields[listTableView.columnForMenu - 1]
        var item = field[listTableView.rowForMenu]
        if let s = scriptData.valueForMenuItem(sender, original: item) {
            field[listTableView.rowForMenu] = s
        } else {
            field[listTableView.rowForMenu] = "NULL"
        }
    }
    
    @IBAction func addNewItemButton(AnyObject) {
        list.addNewItem()
        listTableView.reloadData()
    }
    
    
    
    @IBAction func addNewFieldButton(sender : AnyObject) {
        
        var testName = "Field"
        var baseName = testName
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
        
        var new_field = self.list.addNewField(PSAttributeType(fullType: ""), interface: PSAttributeGeneric())
        scriptData.renameEntry(new_field.entry, nameSuggestion: testName)
        self.addNewColumn(new_field)
        self.listTableView.reloadData()
        
    }
    
    var addedColumns : [PSListBuilderColumn] = []
    func addNewColumn(field : PSField) {
        
        var new_column = PSListBuilderColumn(identifier: "\(addedColumns.count + 1)", column_field: field)
        var new_header = PSFieldHeaderCell()
        new_header.editable = true
        new_header.usesSingleLineMode = true
        new_header.scrollable = false
        new_header.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        new_column.headerCell = new_header
        addedColumns.append(new_column)
        self.listTableView.addTableColumn(new_column)
        
        var header_cell = new_column.headerCell as NSTableHeaderCell
        header_cell.title = field.entry.name
        new_column.headerCell = header_cell
        
        
    }
    
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
        var col = listTableView.tableColumns[col+1] as! PSListBuilderColumn
        self.list.deleteColumnByName(col.field.entry.name)
    }
    

    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        if list != nil {
            return list.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 30
    }
    
    var lastCellEditedCoords : (col: Int, row: Int) = (-1, -1)
    
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
    
    func keyDownMessage(theEvent: NSEvent) {
        var keyPressed = theEvent.keyCode
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
                var newCell = listTableView.viewAtColumn(1, row: 0, makeIfNecessary: true) as! PSListCellView
                lastCellEdited = newCell
            }
        }
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let c = tableColumn as? PSListBuilderColumn {
            var item = c.field[row]
            var att_interface : PSAttributeInterface
            
            if let f = c.field.interface {
                att_interface = f
            } else {
                att_interface = PSAttributeGeneric()
            }
            
            var attributeParameter = att_interface.attributeParameter() as! PSAttributeParameter
            var cell = PSListCellView(attributeParameter: attributeParameter, interface: att_interface, scriptData: scriptData)
            PSAttributeParameterBuilder(parameter: attributeParameter).setupTableCell(cell, currentValue: item)
            
            
            cell.row = row
            if let col = addedColumns.indexOf(c) {
                cell.col = col + 1
            } else {
                fatalError("Could not find column in the controller's array")
            }
            
            cell.updateScriptBlock = { () -> () in
                self.lastCellEdited = cell
                c.field[row] = cell.attributeParameter.currentValue
            }
            
            cell.firstResponderBlock = { self.lastCellEdited = cell }
            return cell
        } else {
            var view = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: self) as! NSTableCellView
            view.textField!.delegate = self
            view.textField!.stringValue = list.nameForRow(row)
            view.textField!.frame = view.frame
            itemTextFields[view.textField!] = row
            return view
        }
    }
    
    func tableView(tableView: NSTableView, selectionIndexesForProposedSelection proposedSelectionIndexes: NSIndexSet) -> NSIndexSet {
        return NSIndexSet(index: -1)
    }
    
    func tableView(tableView: NSTableView, clickedRow: NSInteger, clickedCol: NSInteger) {
        print(clickedRow.description + " " + clickedCol.description)
    }
    
    var itemTextFields : [NSTextField : Int] = [:]
    
    func control(control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        if let tf = control as? NSTextField {
            if let row = itemTextFields[tf] {
                list.setName(tf.stringValue, forRow: row)
            }
        }
        return true
    }
    
    

    
   



}
