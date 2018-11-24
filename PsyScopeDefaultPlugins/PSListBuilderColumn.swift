//
//  PSListBuilderCell.swift
//  PsyScopeEditor
//
//  Created by James on 19/09/2014.
//

import Cocoa

class PSListBuilderColumn : NSTableColumn {
    var field : PSField
    
    init(identifier : String, column_field : PSField) {
        self.field = column_field
        super.init(identifier: convertToNSUserInterfaceItemIdentifier(identifier))
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSUserInterfaceItemIdentifier(_ input: String) -> NSUserInterfaceItemIdentifier {
	return NSUserInterfaceItemIdentifier(rawValue: input)
}
