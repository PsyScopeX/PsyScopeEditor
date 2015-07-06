//
//  PSWeightsToolTablePropertyController.swift
//  PsyScopeEditor
//
//  Created by James on 26/05/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSWeightsToolTablePropertyController : PSToolTablePropertyController {
    
    @IBOutlet var weightsColumn : NSTableColumn!
    
    override func tableView(tableView: NSTableView, shouldEditTableColumn tableColumn: NSTableColumn?, row: Int) -> Bool {
        if tableColumn!.identifier == weightsColumn.identifier {
            return true
        }
        return super.tableView(tableView,shouldEditTableColumn:tableColumn,row: row)
    }
    
    override func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        if tableColumn!.identifier == weightsColumn.identifier {
            return "1"
        }
        return super.tableView(tableView, objectValueForTableColumn: tableColumn, row: row)
    }
    
    func tableView(tableView: NSTableView, setObjectValue object: AnyObject?, forTableColumn tableColumn: NSTableColumn?, row: Int) {
        print(object)
    }
}