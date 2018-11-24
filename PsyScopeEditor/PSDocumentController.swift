//
//  PSDocumentController.swift
//  PsyScopeEditor
//
//  Created by James on 17/10/2014.
//

import Cocoa

class PSDocumentController: NSDocumentController {
    
    override func openUntitledDocumentAndDisplay(_ displayDocument: Bool) throws -> NSDocument {
        print("openUntitledDocumentAndDisplay")
        let document = try super.openUntitledDocumentAndDisplay(displayDocument)
        if let d = document as? Document {
            d.setupInitialState()
        }
        return document
        
    }
    
    override func openDocument(withContentsOf url: URL, display displayDocument: Bool, completionHandler: @escaping (NSDocument?, Bool, Error?) -> Void) {
        print("Open document with contents of url")
        super.openDocument(withContentsOf: url, display: displayDocument, completionHandler: completionHandler)
    }
}
