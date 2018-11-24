//
//  PSEventTableCellView.swift
//  PsyScopeEditor
//
//  Created by James on 14/01/2015.
//

import Foundation

class PSEventTableCellView : NSTableCellView, PSHighLightOnMouseHoverProtocol {
    var event : PSTemplateEvent?
    @IBOutlet var deleteButton : NSButton!
    var deleteAction : ((PSTemplateEvent) -> ())?
    override var objectValue : AnyObject? {
        get {
            return event
        }
        
        set {
            if let event = newValue as? PSTemplateEvent,
                eventEntry = event.entry,
                layoutObject = eventEntry.layoutObject,
                icon = layoutObject.icon {
                self.event = event
                self.imageView!.image = (icon as! NSImage)
                self.textField!.stringValue = eventEntry.name
            } else {
                self.event = nil
            }
        }
    }
    
    func highLight(_ on: Bool) {
        deleteButton.isHidden = !on
    }
    
    func activate() {} // for PSHighLightOnMouseHoverProtocol (but not needed)

    
    @IBAction func deleteButton(_ sender : NSButton) {
        if let da = deleteAction {
            if let e = event {
                da(e)
            }
        }
    }
    
}
