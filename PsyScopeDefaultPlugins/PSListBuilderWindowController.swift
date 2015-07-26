//
//  PSListBuilder.swift
//  PsyScopeEditor
//
//  Created by James on 17/09/2014.
//


import Cocoa

class PSListBuilderWindowController: PSEntryWindowController {
    
    @IBOutlet var controller : PSListBuilderTableController!
    
    override func docMocChanged(notification : NSNotification) {
        super.docMocChanged(notification)
        controller.docMocChanged(notification)
    }
}
