//
//  PSAttributePickerCell.swift
//  PsyScopeEditor
//
//  Created by James on 22/09/2014.
//  Copyright (c) 2014 James. All rights reserved.
//

import Cocoa

class PSAttributePickerCell: NSView {
    
    @IBOutlet var button : NSButton!
    
    var attribute : PSAttributeInterface! = nil
    var selectAttributeFunction : ((PSAttributeInterface,Bool) -> ())?
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        
        // Drawing code here.
    }
    
    var labelValue : String {
        get {
            return button.title
        }
        set {
            button.title = newValue
        }
    }
    
    var objectValue : AnyObject {
        get {
            return labelValue
        }
        
        set {
            labelValue = newValue as String
        }
    }
    
    
    @IBAction func clickedLabel(AnyObject) {
        if let cf = selectAttributeFunction {
            cf(attribute,button.state == 1)
        }
    }
    
}