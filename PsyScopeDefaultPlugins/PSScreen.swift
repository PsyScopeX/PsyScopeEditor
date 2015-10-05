//
//  PSScreen.swift
//  PsyScopeEditor
//
//  Created by James on 28/09/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

func DisplayCallback(_ :CGDirectDisplayID, _: CGDisplayChangeSummaryFlags,_: UnsafeMutablePointer<Void>) -> Void {
    //reset caches
    PSScreen.cached = false
}

class PSScreen {
    static var registered : Bool = false
    static var cached : Bool = false
    
    //cached variables
    static var _screens : [NSScreen] = []
    static var _effectiveResolution : NSRect = NSZeroRect
    
    class func ensureSetup() {
        
        //make sure that we can detect any changes in the display config
        if !registered {
            CGDisplayRegisterReconfigurationCallback(DisplayCallback, nil)
            registered = true
        }
        
  
        if cached { return }
        
        

        
        //get screens, get the layout, compute the effective height and width
        guard let screens = NSScreen.screens() else {
            fatalError("Could not detect any screens")
        }
        
        _screens = screens;
        
        var width : CGFloat = 0
        var height : CGFloat = 0
        
        var originX : CGFloat = 0
        var originY : CGFloat = 0
        
        
        for screen in screens {
            let frame = screen.frame
            
            if frame.origin.x < 0 {
                width = max(width, frame.width - frame.origin.x)
            } else {
                width = max(width, frame.width + frame.origin.x)
            }
            
            
            if frame.origin.y < 0 {
                height = max(height, frame.height - frame.origin.y)
            } else {
                height = max(height, frame.height + frame.origin.y)
            }
            
            originX = min(originX, frame.origin.x)
            originY = min(originY, frame.origin.y)
        }
        
        _effectiveResolution = NSRect(x: originX, y: originY, width: width, height: height)
        cached = true

        
    }
    
    class func getEffectiveResolution() -> NSRect {
        ensureSetup()
        return _effectiveResolution
    }
    
    class func getScreens() -> [NSScreen] {
        ensureSetup()
        return _screens
    }
    
    class func getScreenAndLocationOfPoint(point : CGPoint) -> (screenIndex : Int, location : CGPoint) {
        
        ensureSetup()
        
        for (index, screen) in _screens.enumerate() {
            let cgframe = NSRectToCGRect(screen.frame)
            
            if CGRectContainsPoint(cgframe, point) {
                let locationInScreen = CGPoint(x: point.x + cgframe.origin.x, y: point.y + cgframe.origin.y)
                return (index, locationInScreen)
            }
        }
        
        return (-1, CGPointZero)
    }
}

func PSScreenRes() -> CGRect {
    return CGRectZero
}

