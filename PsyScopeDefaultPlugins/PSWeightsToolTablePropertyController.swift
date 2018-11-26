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
    
    override func tableView(_ tableView: NSTableView, shouldEdit tableColumn: NSTableColumn?, row: Int) -> Bool {
        if tableColumn!.identifier == weightsColumn.identifier {
            return true
        }
        return super.tableView(tableView,shouldEdit:tableColumn,row: row)
    }
    
    override func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if tableColumn!.identifier == weightsColumn.identifier {
            return "1" as AnyObject
        }
        return super.tableView(tableView, objectValueFor: tableColumn, row: row)
    }
    
    func tableView(_ tableView: NSTableView, setObjectValue object: AnyObject?, forTableColumn tableColumn: NSTableColumn?, row: Int) {
        print(object)
    }
}
