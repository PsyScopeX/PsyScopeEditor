//
//  PSFieldHeaderCell.swift
//  PsyScopeEditor
//
//  Created by James on 16/02/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSFieldHeaderCell : NSTableHeaderCell, NSTextViewDelegate {
    //var controller : PSListBuilderTableController!
    //var col : Int!
    func textDidEndEditing(notification: NSNotification) {
        let editor = notification.object as! NSTextView
        self.title = editor.string!
        self.highlighted = false
        self.endEditing(editor)
    }
    
    override func drawWithFrame(cellFrame: NSRect, inView controlView: NSView) {
        if (self.highlighted) {
            self.drawFocusRingMaskWithFrame(cellFrame, inView: controlView.superview!)
        }
        super.drawWithFrame(cellFrame, inView: controlView)
    }
    
    override func drawFocusRingMaskWithFrame(cellFrame: NSRect, inView controlView: NSView) {
        controlView.lockFocus()
        NSSetFocusRingStyle(NSFocusRingPlacement.Only)
        NSBezierPath(rect: cellFrame).fill()
        controlView.unlockFocus()
    }
}