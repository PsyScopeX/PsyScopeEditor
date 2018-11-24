//
//  PSClickableTableView.swift
//  PsyScopeEditor
//
//  Created by James on 19/11/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

open class PSClickableTableView : NSTableView {
    open override func mouseDown(with theEvent: NSEvent) {
        let globalLocation:NSPoint  = theEvent.locationInWindow
        let localLocation:NSPoint  = self.convert(globalLocation, from: nil)
        let clickedRow:Int = self.row(at: localLocation)
        
        super.mouseDown(with: theEvent)

        if (clickedRow != -1) {
            if let delegate = self.delegate as? PSClickableTableViewDelegate {
                delegate.tableView(self, didClickTableRow: clickedRow)
            }
        }
    }
}

public protocol PSClickableTableViewDelegate {
    func tableView(_ tableView : PSClickableTableView, didClickTableRow row: Int)
}

