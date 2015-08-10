//
//  PSDocumentController.swift
//  PsyScopeEditor
//
//  Created by James on 17/10/2014.
//

import Cocoa

class PSDocumentController: NSDocumentController {
    
    override func openUntitledDocumentAndDisplay(displayDocument: Bool) throws -> NSDocument {
        print("openUntitledDocumentAndDisplay")
        let document = try super.openUntitledDocumentAndDisplay(displayDocument)
        if let d = document as? Document {
            d.setupInitialState()
        }
        return document
        
    }
    
    override func openDocumentWithContentsOfURL(url: NSURL, display displayDocument: Bool, completionHandler: (NSDocument?, Bool, NSError?) -> Void) {
        print("Open document with contents of url")
        try super.openDocumentWithContentsOfURL(url, display: displayDocument, completionHandler: completionHandler)
    }
}
