//
//  PSListBuilder.swift
//  PsyScopeEditor
//
//  Created by James on 17/09/2014.
//


import Cocoa

class PSListBuilderWindowController: PSEntryWindowController {
    
    @IBOutlet var controller : PSListBuilderTableController!
    
    override func docMocChanged(_ notification : Notification) {
        super.docMocChanged(notification)
        controller.update()
    }
}
