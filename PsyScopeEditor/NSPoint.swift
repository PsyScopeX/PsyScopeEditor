//
//  NSPoint.swift
//  PsyScopeEditor
//
//  Created by James on 16/09/2014.
//

import Foundation

extension NSPoint {
    func toString() -> String {
        return "\(self)"
    }
    
    func plusPoint(toBeAdded : NSPoint) -> NSPoint {
        return NSPoint(x: self.x + toBeAdded.x, y: self.y + toBeAdded.y)
    }
    
    func minusPoint(toBeMinused : NSPoint) -> NSPoint {
        return NSPoint(x: self.x - toBeMinused.x, y: self.y - toBeMinused.y)
    }
    
    static func fromScalar(scalar : Int) -> NSPoint {
        return NSPoint(x: scalar, y: scalar)
    }
}