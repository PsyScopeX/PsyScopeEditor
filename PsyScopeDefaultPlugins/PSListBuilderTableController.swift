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
    @IBOutlet var weightsColumn : NSTableColumn!
    @IBOutlet var itemsColumn : NSTableColumn!
    
    var scriptData : PSScriptData!
    var listEntry : Entry!
    var attributePicker : PSAttributePicker?
    var list : PSList! = nil
    var nameColumn : NSTableColumn!
    var initialized : Bool = false
    var editingHeader : Bool = false
    var listColumns : [NSTableColumn] = []
    var lastDoubleClickCoords : (col: Int, row: Int) = (-1, -1)
    var lastCellEditedCoords : (col: Int, row: Int) = (-1, -1)
    var itemTextFields : [NSTextField : Int] = [:]
    var weightsTextFields : [NSTextField : Int] = [:]
    
    //MARK: Initialization
    
    override func awakeFromNib() {
        if initialized { return }
        initialized = true //awakeFromNib gets called when setting the owner of new listbuildercells
        listTableView.doubleAction = "doubleClickInTableView:"
        listTableView.target = self
        nameColumn = listTableView.tableColumns.first! as NSTableColumn
        scriptData = listBuilder.scriptData
        listEntry = listBuilder.entry
        update()
    }
    
    //MARK: Update
    
    func update() {
        
        //remove existing columns
        for ac in listColumns { listTableView.removeTableColumn(ac) }
        listColumns = []
        
        //setup list
        list = PSList(scriptData: scriptData, listEntry: listEntry)
        

        if list.hasWeights {
            weightsCheckButton.state = 1
            weightsColumn.isHidden = false
        } else {
            weightsCheckButton.state = 0
            weightsColumn.isHidden = true
        }
        
        //add columns for each field
        for field in list.fields { self.addNewColumn(field) }
        
        //clear array holding textFields for each item and weights columns
        itemTextFields = [:]
        weightsTextFields = [:]
        
        //reload the data
        self.listTableView.reloadData()
        
        //set the highlighted cell
        if let lce = lastCellEdited { lce.highLight(true) }
    }
    
    
    func addNewColumn(_ field : PSField) {
        
        let new_column = PSListBuilderColumn(identifier: "\(listColumns.count + 1)", column_field: field)
        let new_header = PSFieldHeaderCell()
        new_header.isEditable = true
        new_header.usesSingleLineMode = true
        new_header.isScrollable = false
        new_header.lineBreakMode = NSLineBreakMode.byTruncatingTail
        new_column.headerCell = new_header
        listColumns.append(new_column)
        self.listTableView.addTableColumn(new_column)
        
        let header_cell = new_column.headerCell as NSTableHeaderCell
        header_cell.title = field.entry.name
        new_column.headerCell = header_cell
    }
    
    //MARK: Editable headers
    
    func doubleClickInTableView(_ sender : AnyObject) {
        let row = listTableView.clickedRow
        let col = listTableView.clickedColumn
        
        resetHeaders()
        
        //row must be -1 or it's not a header
        if(row == -1 && col >= 1) {
            
            lastDoubleClickCoords = (col, row)
            let tc = listTableView.tableColumns[col] as NSTableColumn
            let hv = listTableView.headerView!;
            let hc = tc.headerCell as! PSFieldHeaderCell
            //hc.controller = self
            //hc.col = col
            let editor = listTableView.window!.fieldEditor(true, for: listTableView)
            hc.isHighlighted = true
            hc.select(withFrame: hv.headerRect(ofColumn: col), in: hv, editor: editor!, delegate: self, start: 0, length: hc.stringValue.characters.count)
            editor?.backgroundColor = NSColor.white
            editor?.drawsBackground = true
            editingHeader = true
        }
    }
    
    func textDidEndEditing(_ notification: Notification) {
        let editor = notification.object as! NSTextView
        let name = editor.string!
        
        if(lastDoubleClickCoords.row == -1 && lastDoubleClickCoords.col >= 2) {
            
            let fieldEntry = list.fields[lastDoubleClickCoords.col - 2].entry
            scriptData.renameEntry(fieldEntry, nameSuggestion: name)
            
            let tc = listTableView.tableColumns[lastDoubleClickCoords.col] as NSTableColumn
            _ = listTableView.headerView!;
            let hc = tc.headerCell as! PSFieldHeaderCell
            hc.title = fieldEntry.name
            
            hc.isHighlighted = false
            hc.endEditing(editor)
            editingHeader = false
            
        }
        
    }
    
    func resetHeaders() {
        //already editingheader so need to cancel that...
        if editingHeader {
            let tc = listTableView.tableColumns[lastDoubleClickCoords.col] as NSTableColumn
            _ = listTableView.headerView!;
            let hc = tc.headerCell as! PSFieldHeaderCell
            hc.isHighlighted = false
            let editor = listTableView.window!.fieldEditor(true, for: listTableView)
            hc.endEditing(editor!)
        }
    }
    
    //MARK: Item / Weights text field edit delegate
    
    func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        if let tf = control as? NSTextField {
            if let row = itemTextFields[tf] {
                list.setItemName(tf.stringValue, forRow: row)
            } else if let row = weightsTextFields[tf] {
                list.setWeightsValueForRow(tf.stringValue, row: row)
            }
        }
        return true
    }
    
    //MARK: Item menu
    
    func clickMenuItem(_ sender : NSMenuItem) {
        let field = list.fields[listTableView.columnForMenu - 1]
        let item = field[listTableView.rowForMenu]
        if let s = scriptData.valueForMenuItem(sender, original: item, originalFullType : field.type) {
            field[listTableView.rowForMenu] = s
        } else {
            field[listTableView.rowForMenu] = "NULL"
        }
    }
    
    func validateMenu(_ menu: NSMenu, tableColumn: NSTableColumn, col : Int) {
        for item in menu.items as [NSMenuItem] {
            item.tag = col
        }
    }
    
    //MARK: Item menu actions
    
    @IBAction func setTypeMenuAction(_ sender : NSMenuItem) {
        //open attribute picker to set the type
            attributePicker = PSAttributePickerType(attributePickedCallback: {
                (type : PSAttributeType, selected : Bool) -> () in
                
                if (selected) {
                    self.list.fields[sender.tag - 2].changeType(type)
                    self.listTableView.reloadData()
                }
    
            }, scriptData: scriptData)
     
            let view : NSView = listTableView.headerView!
            attributePicker!.showAttributeWindow(view)
    }
    
    @IBAction func removeFieldMenuAction(_ sender : NSMenuItem) {
        list.removeField(sender.tag - 2)
    }
    
    @IBAction func removeRowMenuAction(_ sender : NSMenuItem) {
        list.removeRow(sender.tag)
    }
    

    //MARK: TableView
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return list != nil ? list.count : 0
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return PSAttributeParameter.defaultHeight
    }
    
    func tableView(_ tableView: NSTableView, mouseDownInHeaderOf tableColumn: NSTableColumn) {
        resetHeaders()
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let listBuilderColumn = tableColumn as? PSListBuilderColumn else {
            
            //column is for item names or weights
            
            let identifier = tableColumn!.identifier
            let view = tableView.make(withIdentifier: identifier, owner: self) as! NSTableCellView
            view.textField!.delegate = self

            if identifier == weightsColumn.identifier {
                view.textField!.stringValue = String(list.weightForRow(row))
                weightsTextFields[view.textField!] = row
            } else {
                view.textField!.stringValue = list.nameForRow(row)
                itemTextFields[view.textField!] = row
                
            }
            return view
        }
        
        let validIndex = row > 0 && row < listBuilderColumn.field.count
        let item = validIndex ? listBuilderColumn.field[row] : ""
        var att_interface : PSAttributeInterface
        
        if let f = listBuilderColumn.field.interface {
            att_interface = f
        } else {
            att_interface = PSAttributeGeneric()
        }
        
        let attributeParameter = att_interface.attributeParameter() as! PSAttributeParameter
        let cell = PSListCellView(attributeParameter: attributeParameter, interface: att_interface, scriptData: scriptData)
        PSAttributeParameterBuilder(parameter: attributeParameter).setupTableCell(cell, currentValue: item, type: listBuilderColumn.field.type)
        
        
        cell.row = row
        if let col = listColumns.index(of: listBuilderColumn) {
            cell.col = col + 1
        } else {
            fatalError("Could not find column in the controller's array")
        }
        
        cell.updateScriptBlock = { () -> () in
            listBuilderColumn.field[row] = PSConvertListElementToStringElement(cell.attributeParameter.currentValue).stringValue()
        }
        
        cell.firstResponderBlock = { self.lastCellEdited = cell }
        return cell
    }
    
    func tableView(_ tableView: NSTableView, selectionIndexesForProposedSelection proposedSelectionIndexes: IndexSet) -> IndexSet {
        return IndexSet(integer: -1)
    }

    //MARK: New Item/Field/Weights Buttons
    
    @IBAction func addNewItemButton(_: AnyObject) {
        list.addNewItem()
        listTableView.reloadData()
    }
    
    
    
    @IBAction func addNewFieldButton(_ sender : AnyObject) {
        
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
            list.weightsColumn = [Int](repeating: 1, count: numberOfRows)
        } else {
            list.weightsColumn = nil
        }
    }

    
    //MARK: Cell editing
    
    var lastCellEdited : PSListCellView? {
        get {
            if lastCellEditedCoords.col > -1 && lastCellEditedCoords.row > -1 {
                let view: AnyObject? = listTableView.view(atColumn: lastCellEditedCoords.col + 1, row: lastCellEditedCoords.row, makeIfNecessary: true)
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
    
    func keyDownMessage(_ theEvent: NSEvent) {
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
                if let nc = listTableView.view(atColumn: col, row: row, makeIfNecessary: true) as? PSListCellView {
                    lastCellEdited = nc
                    if (tabbedView) {
                        nc.activate()
                    }
                }
            }
        } else {
            if listTableView.numberOfColumns > 1 && listTableView.numberOfRows > 0 {
                if let newCell = listTableView.view(atColumn: 1, row: 0, makeIfNecessary: true) as?PSListCellView {
                    lastCellEdited = newCell
                }
            }
        }
    }
    

}
