//
//  PSAttributesBrowserTableView.swift
//  PsyScopeEditor
//
//  Created by James on 30/10/2014.
//

import Foundation

@objc protocol PSEditMenuDelegate {
    func deleteObject(_ sender : AnyObject)
    func copyObject(_ sender : AnyObject)
    func pasteObject(_ sender : AnyObject)
}

class PSTableView : NSTableView {
    
    @IBOutlet var editDelegate : PSAttributesBrowser!
    
    override func validateProposedFirstResponder(_ responder: NSResponder, for event: NSEvent?) -> Bool {
        return true
    }
    
    override var acceptsFirstResponder: Bool { get { return true } }
    
    func delete(_ sender : AnyObject) {
        editDelegate.deleteObject(sender)
    }
    
    func copy(_ sender : AnyObject) {
        editDelegate.copyObject(sender)
    }
    
    func paste(_ sender : AnyObject) {
        editDelegate.pasteObject(sender)
    }
}
