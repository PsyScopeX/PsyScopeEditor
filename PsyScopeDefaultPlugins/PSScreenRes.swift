//
//  PSScreenRes.swift
//  PsyScopeEditor
//
//  Created by James on 02/06/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

func PSScreenRes() -> NSRect {
    return NSScreen.mainScreen()!.frame
    //TODO notifications if resolution changes
    //https://developer.apple.com/library/mac/documentation/GraphicsImaging/Conceptual/QuartzDisplayServicesConceptual/Articles/Notification.html#//apple_ref/doc/uid/TP40004235-SW1
}