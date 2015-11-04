//
//  PSTableHeaderView.swift
//  PsyScopeEditor
//
//  Created by James on 16/02/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

@objc protocol PSTableHeaderViewDelegate {
    func validateMenu(menu : NSMenu,  tableColumn:NSTableColumn, col : Int)
}


class PSTableHeaderView : NSTableHeaderView  {
    @IBOutlet weak var delegate : AnyObject?
    
    override func menuForEvent(event: NSEvent) -> NSMenu? {
        let columnForMenu = self.columnAtPoint(self.convertPoint(event.locationInWindow, fromView: nil))
        var tableColumn : NSTableColumn? = nil
        if columnForMenu >= 1 {
            tableColumn = self.tableView!.tableColumns[columnForMenu]
        } else {
            return nil
        }
        let menu = self.menu!
        self.delegate?.validateMenu(menu, tableColumn: tableColumn!, col: columnForMenu)
        return menu
    }
}