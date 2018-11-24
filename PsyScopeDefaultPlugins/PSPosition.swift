//
//  PSPosition.swift
//  PsyScopeEditor
//
//  Created by James on 02/06/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

open class PSPosition : Hashable, Equatable {
    
    init(parent_port: PSPort, entry : Entry, scriptData : PSScriptData) {
        self.port = parent_port
        self.entry = entry
        self.scriptData = scriptData
        
        //defaults
        x = PSPortMeasurement.percentage(50)
        y = PSPortMeasurement.percentage(50)
        xRelative = true
        yRelative = true
        xAlign = .Center // changed from centre
        yAlign = .Center // changed from centre

        
        parseCurrentValue()
    }
    
    var layer : CAShapeLayer = CAShapeLayer()
    var highlighted : Bool = false
    let port : PSPort
    var relativeToPort : Bool = true
    let entry : Entry
    let scriptData : PSScriptData
    
    fileprivate var currentValue : String {
        get { return entry.currentValue }
        set { entry.currentValue = newValue }
    }
    
    func delete() {
        layer.removeFromSuperlayer()
        scriptData.deleteBaseEntry(entry)
    }

    
    var x : PSPortMeasurement { didSet { updateIfNotParsing() } }
    var y : PSPortMeasurement { didSet { updateIfNotParsing() } }
    var xRelative : Bool { didSet { updateIfNotParsing() } }
    var yRelative : Bool { didSet { updateIfNotParsing() } }
    var xAlign : PSPositionAlignment { didSet { updateIfNotParsing() } }
    var yAlign : PSPositionAlignment { didSet { updateIfNotParsing() } }
    
    var name : NSString {
        get { return entry.name as! NSString }
        set {
            //updates entry as well as in ports entry
            scriptData.renameEntry(entry, nameSuggestion: newValue as String)
        }
    }
    
    //MARK: Hashable / Equatable
    open var hashValue: Int { return entry.hashValue }
    
    var parsing = false
    
    func parseCurrentValue() {
        parsing = true
        //x relative align y relative align  //TODO parsing checks and defaults for errors
        let value = currentValue
        var components = value.components(separatedBy: " ") as [String]
        
        if components.count >= 1 {
            x = PSPortMeasurement.fromString(components[0], type: .leftRight)
        }
        
        if components.count >= 2 {
            xRelative = components[1].caseInsensitiveCompare("Screen") != ComparisonResult.orderedSame
        }
        
        if components.count >= 3 {
            xAlign = PSPositionAlignment.fromString(components[2])
        }
        
        if components.count >= 4 {
            y = PSPortMeasurement.fromString(components[3], type: .topBottom)
        }
        
        if components.count >= 5 {
            yRelative = components[4].caseInsensitiveCompare("Screen") != ComparisonResult.orderedSame
        }
        
        if components.count >= 6 {
            yAlign = PSPositionAlignment.fromString(components[5])
        }
        parsing = false
    }
    
    func updateIfNotParsing() {
        if (!parsing) { updateEntryValue() }
    }
    
    func updateEntryValue() {
        //x relative align y relative align
        var new_value = x.toString()
        new_value += " "
        new_value += xRelative ? "Port" : "Screen"
        new_value += " "
        new_value += xAlign.rawValue
        new_value += " "
        new_value += y.toString()
        new_value += " "
        new_value += yRelative ? "Port" : "Screen"
        new_value += " "
        new_value += yAlign.rawValue
        
        currentValue = new_value
    }
    
    func setHighlight(_ on : Bool) {
        highlighted = on
        if (on) {
            layer.strokeColor = NSColor.yellow.cgColor // luca commented because this value has to come from the border property of the port
            
            let super_layer : CALayer = layer.superlayer!
            
            if let sl = super_layer.sublayers {
                //bring to front
                layer.removeFromSuperlayer()
                let index : UInt32 = UInt32(sl.count)
                super_layer.insertSublayer(layer, at: index)
            }
        } else {
            layer.strokeColor = NSColor.red.cgColor // this is the default color
        }
        
        layer.borderWidth = 0
        layer.fillColor = NSColor.clear.cgColor
    }
    
    func updateLayer() {
        layer.borderColor = NSColor.black.cgColor
        layer.borderWidth = CGFloat(3)
        
        layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        var loc_x : CGFloat
        var loc_y : CGFloat
        let res = PSScreenRes()
        if (relativeToPort) {
            //first need to find ports top left corner
            let top_left = port.layer.position
            let port_width = port.width.pixels(Int(res.width))
            let port_height = port.height.pixels(Int(res.height))
            loc_x = top_left.x + CGFloat(x.pixels(port_width))
            loc_y = top_left.y - CGFloat(y.pixels(port_height))
        } else {
            loc_x = CGFloat(x.pixels(Int(res.width)))
            loc_y = res.height - CGFloat(y.pixels(Int(res.height)))
        }
        layer.bounds = CGRect(origin: NSZeroPoint, size: CGSize(width: CGFloat(10), height: CGFloat(10)))
        layer.position = CGPoint(x: loc_x, y: loc_y)
    }
    
}

public func ==(lhs: PSPosition, rhs: PSPosition) -> Bool {
    return lhs.hashValue == rhs.hashValue
}


