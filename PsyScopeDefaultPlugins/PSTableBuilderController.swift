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
    
    func docMocChanged(notification : NSNotification) {
        //hide window if entry has been deleted
        var changed = notification.userInfo
        let keys_to_check : [NSString] = [NSInsertedObjectsKey, NSUpdatedObjectsKey, NSDeletedObjectsKey, NSRefreshedObjectsKey, NSInvalidatedObjectsKey, NSInvalidatedAllObjectsKey]
        var updated_objects : [LayoutObject] = []
        for key in keys_to_check {
            var objects_set = changed![key] as! NSSet?
            if let os = objects_set {
                var objects = os.allObjects
                for object in objects {
                    //check for changes with these here objects
                }
            }
        }
        
        if tableEntry.deleted ||
            tableEntry.layoutObject == nil {
                //object has been deleted, so need to close window
                tableBuilder.closeWindow()
                
        }
    }
    
    var factorTable : PSFactorTable!
    
    var tableView : NSTableView!
    
    
    @IBAction func addFactor(sender : AnyObject) {
        if factorTable == nil {
            factorTable = PSFactorTable(superView: view)
            tableView = factorTable.tableView
            tableView.setDelegate(self)
            tableView.setDataSource(self)
        } else {
            factorTable.addFactor()
        }
        reloadData()
    }
    
    @IBAction func addLevel(sender : AnyObject) {
        factorTable.addLevel()
        reloadData()
    }
    
    func reloadData() {
        tableView.reloadData()
    }
    
    
    func numberOfRowsInTableView(tableView: NSTableView!) -> Int {
        if factorTable != nil {
            return factorTable.rows()
        }
        return 0
    }
    
    func tableView(tableView: NSTableView!, objectValueForTableColumn tableColumn: NSTableColumn!, row: Int) -> AnyObject! {
        return ""
    }
    
    func tableView(tableView: NSTableView!, heightOfRow row: Int) -> CGFloat {
        return PSDefaultConstants.TableBuilder.rowHeight
    }
    
    func tableView(tableView: NSTableView!, setObjectValue object: AnyObject!, forTableColumn tableColumn: NSTableColumn!, row: Int) {
        
    }
}
