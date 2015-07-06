//
//  PSDocumentController.swift
//  PsyScopeEditor
//
//  Created by James on 17/10/2014.
//

import Cocoa

class PSDocumentController: NSDocumentController {
    override func openUntitledDocumentAndDisplay(displayDocument: Bool) throws -> AnyObject {
        var outError: NSError! = NSError(domain: "Migrator", code: 0, userInfo: nil)
        //this returns the document
        var document : AnyObject?
        do {
            document = try super.openUntitledDocumentAndDisplay(displayDocument)
        } catch var error as NSError {
            outError = error
            document = nil
        }
        
        //to perform the initial set up of the script etc
        if let d = document as? Document {
            d.setupInitialState()
        }
        if let value = document {
            return value
        }
        throw outError
    }
    
}
