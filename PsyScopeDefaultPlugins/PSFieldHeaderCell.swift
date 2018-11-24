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
    func textDidEndEditing(_ notification: Notification) {
        let editor = notification.object as! NSTextView
        self.title = editor.string
        self.isHighlighted = false
        self.endEditing(editor)
    }
    
    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        if (self.isHighlighted) {
            self.drawFocusRingMask(withFrame: cellFrame, in: controlView.superview!)
        }
        super.draw(withFrame: cellFrame, in: controlView)
    }
    
    override func drawFocusRingMask(withFrame cellFrame: NSRect, in controlView: NSView) {
        controlView.lockFocus()
        NSFocusRingPlacement.only.set()
        NSBezierPath(rect: cellFrame).fill()
        controlView.unlockFocus()
    }
}
