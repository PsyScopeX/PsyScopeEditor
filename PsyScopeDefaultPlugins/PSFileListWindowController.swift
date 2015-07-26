//
//  PSFileListBuilder.swift
//  PsyScopeEditor
//
//  Created by James on 27/05/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSFileListWindowController: PSEntryWindowController {
    
    @IBOutlet var controller : PSFileListBuilderController!
    

    override func docMocChanged(notification : NSNotification) {
        super.docMocChanged(notification)
        controller.refreshControls()
    }
    
            
}