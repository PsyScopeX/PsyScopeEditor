//
//  PSWhiteNSView.swift
//  PsyScopeEditor
//
//  Created by James on 29/07/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

class PSWhiteNSView : NSView {
    /*- (void)drawRect:(NSRect)dirtyRect {
    // Fill in background Color
    CGContextRef context = (CGContextRef) [[NSGraphicsContext currentContext] graphicsPort];
    CGContextSetRGBFillColor(context, 0.227,0.251,0.337,0.8);
    CGContextFillRect(context, NSRectToCGRect(dirtyRect));
    }*/
    
    override func drawRect(dirtyRect: NSRect) {
        //bg colour
        if let context = NSGraphicsContext.currentContext() {
            CGContextSetRGBFillColor(context.CGContext, 1.0,1.0,1.0,0.8);
            CGContextFillRect(context.CGContext, NSRectToCGRect(dirtyRect));
        }
        
    }
}