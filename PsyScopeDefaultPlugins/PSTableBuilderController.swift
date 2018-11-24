//
//  PSTableBuilderController.swift
//  PsyScopeEditor
//
//  Created by James on 29/10/2014.
//

import Foundation


class PSTableBuilderController : NSObject, NSTableViewDataSource, NSTableViewDelegate {
    
    @IBOutlet var tableBuilder : PSTableBuilder!
    @IBOutlet var view : NSView!
    
    var tableEntry : Entry!
    var scriptData : PSScriptData!
    var initialized : Bool = false
    
    override func awakeFromNib() {
        if initialized { return }
        initialized = true //awakeFromNib gets called when setting the owner of new cells
        
        scriptData = tableBuilder.scriptData
        tableEntry = tableBuilder.tableEntry
    }
    
    func docMocChanged(_ notification : Notification) {
        //hide window if entry has been deleted
        if tableEntry.isDeleted ||
            tableEntry.layoutObject == nil {
                //object has been deleted, so need to close window
                tableBuilder.closeWindow()
        }
    }
    
    var factorTable : PSFactorTable!
    
    var tableView : NSTableView!
    
    
    @IBAction func addFactor(_ sender : AnyObject) {
        if factorTable == nil {
            factorTable = PSFactorTable(superView: view)
            tableView = factorTable.tableView
            tableView.delegate = self
            tableView.dataSource = self
        } else {
            factorTable.addFactor()
        }
        reloadData()
    }
    
    @IBAction func addLevel(_ sender : AnyObject) {
        factorTable.addLevel()
        reloadData()
    }
    
    func reloadData() {
        tableView.reloadData()
    }
    
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if factorTable != nil {
            return factorTable.rows()
        }
        return 0
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return ""
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return PSDefaultConstants.TableBuilder.rowHeight
    }
    
    func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        
    }
}
