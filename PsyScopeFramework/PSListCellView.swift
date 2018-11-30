//
//  PSListCellView.swift
//  PsyScopeEditor
//
//  Created by James on 13/04/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

//adds highlighting + optional block to trigger when a subview becomes first responder
public class PSListCellView : PSAttributeCellView, PSHighLightOnMouseHoverProtocol {
    public var firstResponderBlock : (()->())?
    public var col : Int = -1
    public var row : Int = -1
    public var highlighted = false
    
    public func highLight(_ on: Bool) {
        highlighted = on
        self.needsDisplay = true
    }
    
    override open func draw(_ dirtyRect: NSRect) {
        if highlighted {
            
            let selectionRect = self.bounds
            
            NSColor(calibratedWhite: 0.9, alpha: 1.0).setStroke()
            
            NSColor(cgColor: PSConstants.BasicDefaultColors.backgroundColorLowAlpha)!.setFill()
            let selectionPath = NSBezierPath(rect: selectionRect)
            selectionPath.fill()
            selectionPath.stroke()
        }
        super.draw(dirtyRect)
    }
}
