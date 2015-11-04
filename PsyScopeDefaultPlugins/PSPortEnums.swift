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
    
    static func fromString(string : String) -> PSPositionAlignment {
        if string.caseInsensitiveCompare("Top") == NSComparisonResult.OrderedSame {
            return .Top
        } else if string.caseInsensitiveCompare("Left") == NSComparisonResult.OrderedSame {
            return .Left
        } else if string.caseInsensitiveCompare("Center") == NSComparisonResult.OrderedSame {
            return .Center
        } else if string.caseInsensitiveCompare("Bottom") == NSComparisonResult.OrderedSame {
            return .Bottom
        } else if string.caseInsensitiveCompare("Right") == NSComparisonResult.OrderedSame {
            return .Right
        } else {
            return .Center
        }
    }
}

enum PSAlignmentPoint {
    case Auto
    case Center
    case Specified(Int,Int)
}

enum PSValidMeasurements {
    case LeftRight
    case TopBottom
    case PixelsPercentOnly
}

enum PSPortMeasurement {
    case Pixels(Int)
    case Percentage(Int)
    case Centre
    case Top
    case Left
    case Right
    case Bottom
    
    func percent(res : Int) -> Int {
        switch(self) {
        case let .Pixels(val):
            let x = 100 * val / res
            return x
        case let .Percentage(val):
            return val
        case Centre:
            return 50
        case Top:
            return 0
        case Left:
            return 0
        case Right:
            return 100
        case Bottom:
            return 100
        }
    }
    
    func pixels(res : Int) -> Int {
        switch(self) {
        case let .Pixels(val):
            return val
        case let .Percentage(val):
            let x = res * val / 100
            return x
        case Centre:
            return res / 2
        case Top:
            return 0
        case Left:
            return 0
        case Right:
            return res
        case Bottom:
            return res
        }
        
    }
    
    func toString() -> String {
        switch(self) {
        case let .Pixels(val):
            return "\(val)"
        case let .Percentage(val):
            return "\(val)%"
        case Centre:
            return "Center"
        case Top:
            return "Top"
        case Left:
            return "Left"
        case Right:
            return "Right"
        case Bottom:
            return "Bottom"
        }
    }
    
    func transposeByPixels(pixels : Int, res : Int) -> PSPortMeasurement {
        
        let newPixels = self.pixels(res) + pixels
        let newValue = PSPortMeasurement.Pixels(newPixels)
        
        switch(self) {
        case .Percentage(_):
            return PSPortMeasurement.Percentage(newValue.percent(res))
        default:
            return newValue
        }
    }
    
    func sameWithNewValue(integerValue : Int) -> PSPortMeasurement {
        switch(self) {
        case .Pixels(_):
            return PSPortMeasurement.Pixels(integerValue)
        case .Percentage(_):
            return PSPortMeasurement.Percentage(integerValue)
        default:
            return self
        }
    }
    
    static func fromString(string : String, type : PSValidMeasurements) -> PSPortMeasurement {
        if let percent = string.rangeOfString("%") {
            let val = string.stringByReplacingCharactersInRange(percent, withString: "")
            if let _ = Int(val) {
                return PSPortMeasurement.Percentage(Int(val)!)
            } else {
                return PSPortMeasurement.Percentage(0)
            }
        } else if string.caseInsensitiveCompare("Center") == .OrderedSame {
            if type == .LeftRight || type == .TopBottom {
                return PSPortMeasurement.Centre
            }
        } else if string.caseInsensitiveCompare("Left") == .OrderedSame {
            if type == .LeftRight {
                return PSPortMeasurement.Left
            }
        } else if string.caseInsensitiveCompare("Right") == .OrderedSame {
            if type == .LeftRight {
                return PSPortMeasurement.Right
            }
        } else if string.caseInsensitiveCompare("Top") == .OrderedSame {
            if type == .TopBottom {
                return PSPortMeasurement.Top
            }
        } else if string.caseInsensitiveCompare("Bottom") == .OrderedSame {
            if type == .TopBottom {
                return PSPortMeasurement.Bottom
            }
        } else if let i = Int(string) {
            return PSPortMeasurement.Pixels(i)
        } else {
            return PSPortMeasurement.Centre
        }
        
        
        return PSPortMeasurement.Centre
    }
    
    static func measurementForItemTitle(button : NSPopUpButton, textField : NSTextField) -> PSPortMeasurement {
        
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
            return PSPortMeasurement.Percentage(val)
        case "Center":
            return PSPortMeasurement.Centre
        case "Left":
            return PSPortMeasurement.Left
        case "Right":
            return PSPortMeasurement.Right
        case "Top":
            return PSPortMeasurement.Top
        case "Bottom":
            return PSPortMeasurement.Bottom
        case "Left":
            return PSPortMeasurement.Left
        case "Right":
            return PSPortMeasurement.Right
        default:
            return PSPortMeasurement.Centre
        }
    }
    
    
}
