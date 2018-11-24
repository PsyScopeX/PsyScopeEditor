//
//  PSTemplateTableRowView.swift
//  PsyScopeEditor
//
//  Created by James on 14/01/2015.
//

import Foundation

class PSTemplateTableRowView : NSTableRowView {
    override func drawSelection(in dirtyRect: NSRect) {
        let selectionRect = self.bounds
        NSColor.red.setStroke() //LucaL changed color
     
        NSColor(cgColor: PSConstants.BasicDefaultColors.backgroundColor)!.setFill()//LucaL changed color
       // NSColor(calibratedWhite: 0.82, alpha: 1.0).setFill()
        let selectionPath = NSBezierPath(rect: selectionRect)
 
        selectionPath.fill()
        selectionPath.stroke()
    }
    
    override func drawBackground(in dirtyRect: NSRect) {
       
   //NSColor(CGColor: PSConstants.BasicDefaultColors.backgroundColorLowAlpha).set() // this to change the background
        
        self.backgroundColor.set()
        __NSRectFill(self.bounds)
        
        if (_mouseInside) {
            let selectionRect = self.bounds

           NSColor(calibratedWhite: 0.9, alpha: 1.0).setStroke()
            
NSColor(cgColor: PSConstants.BasicDefaultColors.backgroundColorLowAlpha)!.setFill()//LucaL changed color
            
            //NSColor(calibratedWhite: 0.9, alpha: 1.0).setFill()
            let selectionPath = NSBezierPath(rect: selectionRect)
            
            selectionPath.fill()
            selectionPath.stroke()
        }
    }
    
    var _trackingArea : NSTrackingArea!
    var _mouseInside : Bool = false
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if _trackingArea == nil {
            _trackingArea = NSTrackingArea(rect: self.bounds, options: [NSTrackingArea.Options.mouseEnteredAndExited, NSTrackingArea.Options.activeInActiveApp], owner: self, userInfo: nil)
            self.addTrackingArea(_trackingArea)
        }
    }
    
    override func mouseEntered(with theEvent: NSEvent) {
        _mouseInside = true
        if let view = self.view(atColumn: 0) as? PSHighLightOnMouseHoverProtocol {
            view.highLight(true)
        }
        self.needsDisplay = true
    }
    
    override func mouseExited(with theEvent: NSEvent) {
        _mouseInside = false
        if let view = self.view(atColumn: 0) as? PSHighLightOnMouseHoverProtocol {
            view.highLight(false)
        }
        self.needsDisplay = true
    }
}

