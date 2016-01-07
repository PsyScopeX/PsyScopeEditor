//
//  NSPointExtensions.swift
//  PsyScopeEditor
//
//  Created by James on 07/01/2016.
//  Copyright © 2016 James. All rights reserved.
//

import Foundation

public extension NSPoint {
    public func toString() -> String {
        return "\(self)"
    }
    
    public static func fromScalar(scalar : Int) -> NSPoint {
        return NSPoint(x: scalar, y: scalar)
    }
}

public func +(left: NSPoint, right: NSPoint) -> NSPoint {
    return NSPoint(x: left.x + right.x, y: left.y + right.y)
}

public func -(left: NSPoint, right: NSPoint) -> NSPoint {
    return NSPoint(x: left.x - right.x, y: left.y - right.y)
}