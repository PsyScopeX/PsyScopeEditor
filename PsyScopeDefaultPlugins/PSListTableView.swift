//
//  PSListTableView.swift
//  PsyScopeEditor
//
//  Created by James on 16/02/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

@objc protocol PSListTableViewDelegate : class {
    optional func tableView(_ tableView : NSTableView, clickedRow : NSInteger, clickedCol : NSInteger)
    func keyDownMessage(_ theEvent : NSEvent)
}

class PSListTableView : NSTableView {

    @IBOutlet var extendedDelegate : PSListTableViewDelegate! = nil
    var columnForMenu : Int = -1
    var rowForMenu : Int = -1
    override func menu(for event: NSEvent) -> NSMenu? {
        let point = self.convert(event.locationInWindow, from: nil)
        columnForMenu = self.column(at: point)
        rowForMenu = self.row(at: point)
        if columnForMenu == 0 {
            for item in self.menu!.items {
                item.tag = rowForMenu
            }
            return self.menu
        } else {
            let theDelegate = self.delegate as! PSListBuilderTableController
            return theDelegate.scriptData.getVaryByMenu(theDelegate, action: "clickMenuItem:")
        }
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        let location = self.convert(theEvent.locationInWindow, from: nil)
        let clickedRow = self.row(at: location)
        let clickedCol = self.column(at: location)
        super.mouseDown(with: theEvent)
        if clickedRow != -1 && clickedCol != -1 {
            self.extendedDelegate.tableView?(self, clickedRow: clickedRow, clickedCol: clickedCol)
        }
    }
    

    override func validateProposedFirstResponder(_ responder: NSResponder, for event: NSEvent?) -> Bool {
        return true
    }
    
    override func keyDown(with theEvent: NSEvent) {
        self.extendedDelegate.keyDownMessage(theEvent)
    }
    
}

