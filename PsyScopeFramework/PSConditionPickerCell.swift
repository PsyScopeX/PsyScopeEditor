//
//  PSConditionPickerCell.swift
//  PsyScopeEditor
//
//  Created by James on 16/11/2014.
//

import Cocoa

class PSConditionPickerCell: NSView {
    
    @IBOutlet var button : NSButton!
    @IBOutlet var imageView : NSImageView!
    
    var clickCallback : ((Int,Bool)->())? = nil
    var row : Int = -1
    
    func setup(_ title : String, image : NSImage, row : Int, clickCallback : @escaping ((Int,Bool)->())) {
        button.title = title
        self.row = row
        self.clickCallback = clickCallback
    }
    
    
    @IBAction func clickedLabel(_: AnyObject) {
        if let clickCallback = clickCallback {
            clickCallback(row,button.state.rawValue == 1)
        }
    }
    
}
