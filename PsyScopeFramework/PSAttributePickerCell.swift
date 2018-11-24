//
//  PSAttributePickerCell.swift
//  PsyScopeEditor
//
//  Cell used in the attribute picker

import Cocoa

class PSAttributePickerCell: NSView {
    
    @IBOutlet var button : NSButton!
    var clickCallback : ((Int,Bool)->())? = nil
    var row : Int = -1
    
    func setup(_ labelValue : String, row : Int, clickCallback : @escaping ((Int,Bool)->())) {
        button.title = labelValue
        self.row = row
        self.clickCallback = clickCallback
    }

    
    @IBAction func clickedLabel(_: AnyObject) {
        if let clickCallback = clickCallback {
            clickCallback(row,button.state == 1)
        }
    }
    
}
