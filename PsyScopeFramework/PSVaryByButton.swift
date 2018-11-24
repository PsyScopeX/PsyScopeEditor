//
//  PSVaryByButton.swift
//  PsyScopeEditor
//
//  Created by James on 26/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

public let PSVaryByButtonImage = NSImage(contentsOfFile: Bundle(for:PSVaryByButton.self).path(forResource: "search-icon", ofType: "png")!)

open class PSVaryByButton : NSButton {
    
    override init(frame : NSRect) {
        var newFrame = frame
        newFrame.size = CGSize(width: 22, height: 22)
        super.init(frame: newFrame)
        self.isBordered = true
        self.bezelStyle = .texturedSquare
        self.needsDisplay = true
        self.setButtonType(NSButton.ButtonType.momentaryChange)
        self.image = PSVaryByButtonImage!.copy() as? NSImage
        self.image!.size = NSMakeSize(17, 17)
        self.title = ""
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func mouseDown(with theEvent: NSEvent) {
        if let m = self.menu {
            let cell = self.cell as? PSVaryByButtonCell
            if theEvent.type == .leftMouseDown {
                cell?.menu = m
            } else {
                cell?.menu = nil
            }
        }
        
        super.mouseDown(with: theEvent)
    }
    
    open override class var cellClass: AnyClass? {
        
        get{
            return PSVaryByButtonCell.self
        }
        set {
            
        }
    }
    
}

open class PSVaryByButtonCell : NSButtonCell {
    open override func trackMouse(with theEvent: NSEvent, in cellFrame: NSRect, of controlView: NSView, untilMouseUp: Bool) -> Bool {
        if (theEvent.type == .leftMouseDown && self.menu != nil) {
            
            let point = NSMakePoint(NSMidX(cellFrame), NSMidY(cellFrame))
            let result = controlView.convert(point, to: nil)
            let newEvent = NSEvent.mouseEvent(with: theEvent.type,
                location: result,
                modifierFlags: theEvent.modifierFlags,
                timestamp: theEvent.timestamp,
                windowNumber: theEvent.windowNumber,
                context: theEvent.context,
                eventNumber: theEvent.eventNumber,
                clickCount: theEvent.clickCount,
                pressure: theEvent.pressure)
            NSMenu.popUpContextMenu(self.menu!,with: newEvent!,for: controlView)
            return true
        }
        return super.trackMouse(with: theEvent,in: cellFrame,of: controlView,untilMouseUp: untilMouseUp)
    }
}
