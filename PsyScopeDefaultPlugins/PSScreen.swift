//
//  PSScreen.swift
//  PsyScopeEditor
//
//  Created by James on 28/09/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

func DisplayCallback(_ :CGDirectDisplayID, _: CGDisplayChangeSummaryFlags,_: UnsafeMutableRawPointer) -> Void {
    //reset caches
    PSScreen.cached = false
    NotificationCenter.default.post(name: Notification.Name(rawValue: PSScreenChangeNotification), object: nil)
}

let PSScreenChangeNotification = "PSScreenChangeNotification"

class PSScreen {
    static var registered : Bool = false
    static var cached : Bool = false
    
    //cached variables
    static var _screens : [NSScreen] = []
    static var _effectiveResolution : NSRect = NSZeroRect
    
    class func ensureSetup() {
        
        //make sure that we can detect any changes in the display config
        if !registered {
            CGDisplayRegisterReconfigurationCallback(DisplayCallback as! CGDisplayReconfigurationCallBack, nil)
            registered = true
        }
        
  
        if cached { return }
        

        _screens = NSScreen.screens;
        
        var leftMost : CGFloat = 0
        var rightMost : CGFloat = 0
        var upMost : CGFloat = 0
        var downMost : CGFloat = 0
        

        
        
        for screen in _screens {
            let frame = screen.frame
            
            leftMost = min(leftMost, frame.origin.x)
            rightMost = max(rightMost, frame.origin.x + frame.width)
            upMost = min(upMost, frame.origin.y)
            downMost = max(downMost, frame.origin.y + frame.height)
            
  
            

        }
        
        _effectiveResolution = NSRect(x: leftMost, y: upMost, width: rightMost - leftMost, height: downMost - upMost)
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
    
    class func getScreenAndLocationOfPoint(_ point : CGPoint) -> (screenIndex : Int, location : CGPoint) {
        
        ensureSetup()
        
        for (index, screen) in _screens.enumerated() {
            let cgframe = NSRectToCGRect(screen.frame)
            
            if cgframe.contains(point) {
                let locationInScreen = CGPoint(x: point.x + cgframe.origin.x, y: point.y + cgframe.origin.y)
                return (index, locationInScreen)
            }
        }
        
        return (-1, CGPoint.zero)
    }
}

func PSScreenRes() -> CGRect {
    return CGRect.zero
}

