//
//  PSDocumentController.swift
//  PsyScopeEditor
//
//  Created by James on 17/10/2014.
//

import Cocoa

class PSDocumentController: NSDocumentController {
    
    override func openUntitledDocumentAndDisplay(displayDocument: Bool) throws -> AnyObject {

        //this returns the document
        let document = try super.openUntitledDocumentAndDisplay(displayDocument)
  
        //to perform the initial set up of the script etc
        if let d = document as? Document {
            d.setupInitialState()
        }
        
        return document
    }
    
}
