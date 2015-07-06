//
//  PSAttributesBrowserTableView.swift
//  PsyScopeEditor
//
//  Created by James on 30/10/2014.
//

import Foundation

@objc protocol PSEditMenuDelegate {
    func deleteObject(sender : AnyObject)
    func copyObject(sender : AnyObject)
    func pasteObject(sender : AnyObject)
}

class PSTableView : NSTableView {
    
    @IBOutlet var editDelegate : PSAttributesBrowser!
    
    override func validateProposedFirstResponder(responder: NSResponder, forEvent event: NSEvent?) -> Bool {
        return true
    }
    
    override var acceptsFirstResponder: Bool { get { return true } }
    
    func delete(sender : AnyObject) {
        editDelegate.deleteObject(sender)
    }
    
    func copy(sender : AnyObject) {
        editDelegate.copyObject(sender)
    }
    
    func paste(sender : AnyObject) {
        editDelegate.pasteObject(sender)
    }
}