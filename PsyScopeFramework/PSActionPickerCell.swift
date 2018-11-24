//
//  PSActionPickerCell.swift
//  PsyScopeEditor
//
//  Created by James on 15/11/2014.
//


import Cocoa

class PSActionPickerCell: NSView {
    
    @IBOutlet var label : NSTextField!
    
    var clickCallback : ((PSActionPickerAction)->())? = nil
    var action : PSActionPickerAction!
    
    func setup(_ action : PSActionPickerAction, clickCallback : @escaping ((PSActionPickerAction)->())) {
        label.stringValue = action.userFriendlyName
        self.action = action
        self.clickCallback = clickCallback
    }
    
    
    @IBAction func clickedLabel(_: AnyObject) {
        if let clickCallback = clickCallback {
            clickCallback(action)
        }
    }
    
}
