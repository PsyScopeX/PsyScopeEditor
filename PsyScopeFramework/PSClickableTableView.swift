//
//  PSClickableTableView.swift
//  PsyScopeEditor
//
//  Created by James on 19/11/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

public class PSClickableTableView : NSTableView {
    public override func mouseDown(theEvent: NSEvent) {
        let globalLocation:NSPoint  = theEvent.locationInWindow
        let localLocation:NSPoint  = self.convertPoint(globalLocation, fromView: nil)
        let clickedRow:Int = self.rowAtPoint(localLocation)
        
        super.mouseDown(theEvent)

        if (clickedRow != -1) {
            if let delegate = self.delegate() as? PSClickableTableViewDelegate {
                delegate.tableView(self, didClickTableRow: clickedRow)
            }
        }
    }
}

public protocol PSClickableTableViewDelegate {
    func tableView(tableView : PSClickableTableView, didClickTableRow row: Int)
}

