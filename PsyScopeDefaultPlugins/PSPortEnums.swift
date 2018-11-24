//
//  PSPortEnums.swift
//  PsyScopeEditor
//
//  Created by James on 07/04/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation


enum PSPortShape : String {
    case Rectangle = "RECTANGULAR"
    case Rounded = "ROUNDED"
    case Oval = "OVAL"
}

enum PSPositionAlignment : String {
    case Top = "TOP"
    case Left = "LEFT"
    case Center = "CENTER"
    case Bottom = "BOTTOM"
    case Right = "RIGHT"
    
    static func fromString(_ string : String) -> PSPositionAlignment {
        if string.caseInsensitiveCompare("Top") == ComparisonResult.orderedSame {
            return .Top
        } else if string.caseInsensitiveCompare("Left") == ComparisonResult.orderedSame {
            return .Left
        } else if string.caseInsensitiveCompare("Center") == ComparisonResult.orderedSame {
            return .Center
        } else if string.caseInsensitiveCompare("Bottom") == ComparisonResult.orderedSame {
            return .Bottom
        } else if string.caseInsensitiveCompare("Right") == ComparisonResult.orderedSame {
            return .Right
        } else {
            return .Center
        }
    }
}

enum PSAlignmentPoint {
    case auto
    case center
    case specified(Int,Int)
}

enum PSValidMeasurements {
    case leftRight
    case topBottom
    case pixelsPercentOnly
}

enum PSPortMeasurement {
    case Pixels(Int)
    case percentage(Int)
    case centre
    case top
    case left
    case right
    case bottom
    
    func percent(_ res : Int) -> Int {
        switch(self) {
        case let .Pixels(val):
            let x = 100 * val / res
            return x
        case let .percentage(val):
            return val
        case .centre:
            return 50
        case .top:
            return 0
        case .left:
            return 0
        case .right:
            return 100
        case .bottom:
            return 100
        }
    }
    
    func pixels(_ res : Int) -> Int {
        switch(self) {
        case let .Pixels(val):
            return val
        case let .percentage(val):
            let x = res * val / 100
            return x
        case .centre:
            return res / 2
        case .top:
            return 0
        case .left:
            return 0
        case .right:
            return res
        case .bottom:
            return res
        }
        
    }
    
    func toString() -> String {
        switch(self) {
        case let .Pixels(val):
            return "\(val)"
        case let .percentage(val):
            return "\(val)%"
        case .centre:
            return "Center"
        case .top:
            return "Top"
        case .left:
            return "Left"
        case .right:
            return "Right"
        case .bottom:
            return "Bottom"
        }
    }
    
    func transposeByPixels(_ pixels : Int, res : Int) -> PSPortMeasurement {
        
        let newPixels = self.pixels(res) + pixels
        let newValue = PSPortMeasurement.Pixels(newPixels)
        
        switch(self) {
        case .percentage(_):
            return PSPortMeasurement.percentage(newValue.percent(res))
        default:
            return newValue
        }
    }
    
    func sameWithNewValue(_ integerValue : Int) -> PSPortMeasurement {
        switch(self) {
        case .Pixels(_):
            return PSPortMeasurement.Pixels(integerValue)
        case .percentage(_):
            return PSPortMeasurement.percentage(integerValue)
        default:
            return self
        }
    }
    
    static func fromString(_ string : String, type : PSValidMeasurements) -> PSPortMeasurement {
        if let percent = string.range(of: "%") {
            let val = string.replacingCharacters(in: percent, with: "")
            if let _ = Int(val) {
                return PSPortMeasurement.percentage(Int(val)!)
            } else {
                return PSPortMeasurement.percentage(0)
            }
        } else if string.caseInsensitiveCompare("Center") == .orderedSame {
            if type == .leftRight || type == .topBottom {
                return PSPortMeasurement.centre
            }
        } else if string.caseInsensitiveCompare("Left") == .orderedSame {
            if type == .leftRight {
                return PSPortMeasurement.left
            }
        } else if string.caseInsensitiveCompare("Right") == .orderedSame {
            if type == .leftRight {
                return PSPortMeasurement.right
            }
        } else if string.caseInsensitiveCompare("Top") == .orderedSame {
            if type == .topBottom {
                return PSPortMeasurement.top
            }
        } else if string.caseInsensitiveCompare("Bottom") == .orderedSame {
            if type == .topBottom {
                return PSPortMeasurement.bottom
            }
        } else if let i = Int(string) {
            return PSPortMeasurement.Pixels(i)
        } else {
            return PSPortMeasurement.centre
        }
        
        
        return PSPortMeasurement.centre
    }
    
    static func measurementForItemTitle(_ button : NSPopUpButton, textField : NSTextField) -> PSPortMeasurement {
        
        var title = ""
        var val = 0
        if let i = Int(textField.stringValue) {
            val = i
        }
        if let si = button.selectedItem {
            title = si.title
        }
        
        switch (title) {
        case "Pixels":
            return PSPortMeasurement.Pixels(val)
        case "Percent":
            return PSPortMeasurement.percentage(val)
        case "Center":
            return PSPortMeasurement.centre
        case "Left":
            return PSPortMeasurement.left
        case "Right":
            return PSPortMeasurement.right
        case "Top":
            return PSPortMeasurement.top
        case "Bottom":
            return PSPortMeasurement.bottom
        case "Left":
            return PSPortMeasurement.left
        case "Right":
            return PSPortMeasurement.right
        default:
            return PSPortMeasurement.centre
        }
    }
    
    
}
