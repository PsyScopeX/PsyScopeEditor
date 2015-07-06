//
//  PSVaryByButton.swift
//  PsyScopeEditor
//
//  Created by James on 26/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

public let PSVaryByButtonImage = NSImage(contentsOfFile: NSBundle(forClass:PSVaryByButton.self).pathForResource("search-icon", ofType: "png")!)

public class PSVaryByButton : NSButton {
    
    override init(frame : NSRect) {
        var newFrame = frame
        newFrame.size = CGSizeMake(22, 22)
        super.init(frame: newFrame)
        self.bordered = true
        self.bezelStyle = .TexturedSquareBezelStyle
        self.needsDisplay = true
        self.setButtonType(NSButtonType.MomentaryChangeButton)
        self.image = PSVaryByButtonImage!.copy() as? NSImage
        self.image!.size = NSMakeSize(17, 17)
        self.title = ""
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func mouseDown(theEvent: NSEvent) {
        if let m = self.menu {
            let cell = self.cell as? PSVaryByButtonCell
            if theEvent.type == .LeftMouseDown {
                cell?.menu = m
            } else {
                cell?.menu = nil
            }
        }
        
        super.mouseDown(theEvent)
    }
    
    public override class func cellClass() -> AnyClass {
        return PSVaryByButtonCell.self
    }
    
}

public class PSVaryByButtonCell : NSButtonCell {
    public override func trackMouse(theEvent: NSEvent, inRect cellFrame: NSRect, ofView controlView: NSView, untilMouseUp: Bool) -> Bool {
        if (theEvent.type == .LeftMouseDown && self.menu != nil) {
            
            let point = NSMakePoint(NSMidX(cellFrame), NSMidY(cellFrame))
            let result = controlView.convertPoint(point, toView: nil)
            let newEvent = NSEvent.mouseEventWithType(theEvent.type,
                location: result,
                modifierFlags: theEvent.modifierFlags,
                timestamp: theEvent.timestamp,
                windowNumber: theEvent.windowNumber,
                context: theEvent.context,
                eventNumber: theEvent.eventNumber,
                clickCount: theEvent.clickCount,
                pressure: theEvent.pressure)
            NSMenu.popUpContextMenu(self.menu!,withEvent: newEvent!,forView: controlView)
            return true
        }
        return super.trackMouse(theEvent,inRect: cellFrame,ofView: controlView,untilMouseUp: untilMouseUp)
    }
}