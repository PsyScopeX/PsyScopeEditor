//
//  PSDocumentController.swift
//  PsyScopeEditor
//
//  Created by James on 17/10/2014.
//

import Cocoa

class PSDocumentController: NSDocumentController {
    override func openUntitledDocumentAndDisplay(displayDocument: Bool) throws -> AnyObject {

        let document = try super.openUntitledDocumentAndDisplay(displayDocument)
        if let d = document as? Document {
            d.setupInitialState()
        }
        return document
        
    }
}
