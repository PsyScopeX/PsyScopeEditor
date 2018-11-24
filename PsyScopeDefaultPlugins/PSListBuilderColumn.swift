//
//  PSListBuilderCell.swift
//  PsyScopeEditor
//
//  Created by James on 19/09/2014.
//

import Cocoa

class PSListBuilderColumn : NSTableColumn {
    var field : PSField
    
    init(identifier : NSUserInterfaceItemIdentifier, column_field : PSField) {
        self.field = column_field
        super.init(identifier: identifier)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
