//
//  PSListTableView.swift
//  PsyScopeEditor
//
//  Created by James on 16/02/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

@objc protocol PSListTableViewDelegate : class {
    optional func tableView(tableView : NSTableView, clickedRow : NSInteger, clickedCol : NSInteger)
    func keyDownMessage(theEvent : NSEvent)
}

class PSListTableView : NSTableView {

    @IBOutlet var extendedDelegate : PSListTableViewDelegate! = nil
    var columnForMenu : Int = -1
    var rowForMenu : Int = -1
    override func menuForEvent(event: NSEvent) -> NSMenu? {
        let point = self.convertPoint(event.locationInWindow, fromView: nil)
        columnForMenu = self.columnAtPoint(point)
        rowForMenu = self.rowAtPoint(point)
        if columnForMenu == 0 {
            for item in self.menu!.itemArray {
                item.tag = rowForMenu
            }
            return self.menu
        } else {
            let theDelegate = self.delegate() as! PSListBuilderTableController
            return theDelegate.scriptData.getVaryByMenu(theDelegate, action: "clickMenuItem:")
        }
    }
    
    override func mouseDown(theEvent: NSEvent) {
        let location = self.convertPoint(theEvent.locationInWindow, fromView: nil)
        let clickedRow = self.rowAtPoint(location)
        let clickedCol = self.columnAtPoint(location)
        super.mouseDown(theEvent)
        if clickedRow != -1 && clickedCol != -1 {
            self.extendedDelegate.tableView?(self, clickedRow: clickedRow, clickedCol: clickedCol)
        }
    }
    

    override func validateProposedFirstResponder(responder: NSResponder, forEvent event: NSEvent?) -> Bool {
        return true
    }
    
    override func keyDown(theEvent: NSEvent) {
        self.extendedDelegate.keyDownMessage(theEvent)
    }
    
}

