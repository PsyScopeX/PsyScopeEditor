//
//  PSPort.swift
//  PsyScopeEditor scree
//
//  Created by James on 30/09/2014.
//

import Foundation


//parses a port entry as an object - has a layer which updates it's coordinates automatically


public class PSPort : Hashable, Equatable {
    
    //port parameters
    var shape : PSPortShape {
        didSet { updateIfNotParsing() }
    }
    var height : PSPortMeasurement {
        didSet { updateIfNotParsing() }
    }
    var width : PSPortMeasurement {
        didSet { updateIfNotParsing() }
    }
    var border : Int {
        didSet { updateIfNotParsing() }
    }
    var alignmentPoint : PSAlignmentPoint {
        didSet { updateIfNotParsing() }
    }
    var x : PSPortMeasurement {
        didSet { updateIfNotParsing() }
    }
    var y : PSPortMeasurement {
        didSet { updateIfNotParsing() }
    }
    
    //flag to determine if currently parsing
    var parsing = false
    
    //positions
    var positions : [PSPosition] = []
    
    //display
    var layer : CAShapeLayer = CAShapeLayer()
    var highlighted : Bool = false
    
    //script connections
    var entry : Entry
    var scriptData : PSScriptData
    var portScript : PSPortScript
    
    
    init(entry : Entry, scriptData : PSScriptData, portScript : PSPortScript) {
        self.entry = entry
        self.scriptData = scriptData
        self.positions = []
        self.portScript = portScript
        
        parsing = true
        self.shape = .Rectangle
        self.height = .Pixels(150)
        self.width = .Pixels(150)
        self.border = 1
        self.alignmentPoint = .Auto
        self.x = PSPortMeasurement.Centre
        self.y = PSPortMeasurement.Centre
        parsing = false
        
        if let pointsSubEntry = scriptData.getSubEntry("Points", entry: entry) {
            let pointsSubEntryStringList = PSStringList(entry: pointsSubEntry, scriptData: scriptData)
            for positions_entry in pointsSubEntryStringList.stringListLiteralsOnly {
                if let pos_entry = scriptData.getBaseEntry(positions_entry) {
                    let position = PSPosition(parent_port: self, entry: pos_entry, scriptData: scriptData)
                    positions.append(position)
                }
            }
        }
        
        parseCurrentValue()
    }
    
    func delete() {
        layer.removeFromSuperlayer()
        scriptData.deleteBaseEntry(entry)
    }

    func parseCurrentValue() {
        parsing = true
        let value = self.currentValue
        
        
        var components = value.componentsSeparatedByString(" ") as [String]
        
        if components.count >= 1 {
            x = PSPortMeasurement.fromString(components[0], type: .LeftRight)
        }
        
        if components.count >= 2 {
            width = PSPortMeasurement.fromString(components[1], type: .PixelsPercentOnly)
        }
        
        if components.count >= 3 {
            y = PSPortMeasurement.fromString(components[2], type: .TopBottom)
        }
        
        if components.count >= 4 {
            height = PSPortMeasurement.fromString(components[3], type: .PixelsPercentOnly)
        }
        
        if components.count >= 5 {
            if let i = Int(components[4]) {
                border = i
            }
        }
        parsing = false
    }
    
    func addPosition(name : String) -> PSPosition? {
        //first check if entry name is free
        let pointsSubEntry = PSStringList(entry: scriptData.getOrCreateSubEntry("Points", entry: entry, isProperty: true), scriptData: scriptData)
        if scriptData.getBaseEntry(name) == nil && pointsSubEntry.appendAsString(name) {
            let new_entry = scriptData.getOrCreateBaseEntry(name, type: PSType.Position)
            let new_position = PSPosition(parent_port: self, entry: new_entry, scriptData: scriptData)
            positions.append(new_position)
            new_position.updateEntryValue()
            return new_position
        }
        return nil
    }
    
    var name : NSString {
        get { return entry.name }
        set {
            //updates entry as well as in ports entry
            scriptData.renameEntry(entry, nameSuggestion: newValue as String)
        }
    }
    
    //MARK: Hashable / Equatable
    public var hashValue: Int { return entry.hashValue }
    
    var currentValue : String {
        get { return entry.currentValue }
        set { entry.currentValue = newValue }
    }
    
    func updateIfNotParsing() {
        if (!parsing) { updateEntryValue() }
    }
    
    func updateEntryValue() {
        // x width y height border
        var new_value = x.toString()
        new_value += " "
        new_value += width.toString()
        new_value += " "
        new_value += y.toString()
        new_value += " "
        new_value += height.toString()
        new_value += " "
        new_value += "\(border)"
        currentValue = new_value
    }
    
    func setHighlight(on : Bool) {
        highlighted = on
        if (on) {
            //format for selected port
            layer.fillColor = PSConstants.BasicDefaultColors.foregroundColorLowAlpha // luca added to fill the color of the selected port darker blue, as in the default interface
            layer.strokeColor =  NSColor.whiteColor().CGColor // luca trying to use the same convention as in the main interface: selected objects have white border
            
            //bring to front
            if let superlayer = layer.superlayer, sublayers = superlayer.sublayers {
                layer.removeFromSuperlayer()
                superlayer.insertSublayer(layer, atIndex: UInt32(sublayers.count))
            }
        } else {
            //format for unselected port
            layer.strokeColor = NSColor.lightGrayColor().CGColor // this is the default color of the border. Light gray by popular demand
            layer.fillColor = NSColor.clearColor().CGColor
        }
        
        layer.borderWidth = 0
    }
    
    func updateLayer() {
        
        //the port uses line rather than border to display the border.
        if (border > 0) {
            layer.lineWidth = CGFloat(border)// luca to show the right border size
            layer.lineDashPattern = nil
        } else { // consider the case in which borders are 0
            layer.lineWidth = CGFloat(3)// luca to show a fake border size of a borderless port
            layer.lineDashPattern = [8,8]//luca reducing the dash stroke size
        }
        
        setHighlight(highlighted) //set correct border color
        
        //get the resolution of the screen
        let res = PSScreen.getEffectiveResolution()
        
        //get the height and width of the port
        let cgwidth : CGFloat = CGFloat(width.pixels(Int(res.width)))
        let cgheight : CGFloat = CGFloat(height.pixels(Int(res.height)))
        
        
        //get the anchor for the position
        var anchorX : CGFloat
        var anchorY : CGFloat
        
        switch(alignmentPoint) {
        case .Center:
            anchorX = 0.5
            anchorY = 0.5
        case .Auto:
            
            switch(x) {
            case .Left:
                anchorX = 0
                break
            case .Right:
                anchorX = 1
                break
            default:
                anchorX = 0.5
                break
            }
            
            switch(y) {
            case .Top:
                anchorY = 1
                break
            case .Bottom:
                anchorY = 0
                break
            default:
                anchorY = 0.5
                break
            }
            
        case .Specified(let x, let y):
            anchorX = CGFloat(x) / cgwidth
            anchorY = 1 - (CGFloat(y) / cgheight)
        }
        
        //compute the offset implied by the anchor
        let anchorOffsetX : CGFloat = anchorX * cgwidth
        let anchorOffsetY : CGFloat = anchorY * cgheight
        
        //compute the offset due to the border
        let borderOffset : CGFloat = CGFloat(border) / 2
        
        //the actual layers point will be top left corner
        layer.anchorPoint = CGPoint(x: 0, y: 0)
        
        //the final geomtry for the port layer
        let loc_x = CGFloat(x.pixels(Int(res.width))) - anchorOffsetX - borderOffset
        let loc_y = CGFloat(y.pixels(Int(res.height))) - anchorOffsetY - borderOffset
        layer.bounds = CGRect(origin: NSZeroPoint, size: CGSizeMake(cgwidth + CGFloat(border), cgheight + CGFloat(border)))
        layer.position = CGPoint(x: loc_x, y: loc_y)
        
        //print("Layer bounds: \(layer.bounds) \nLayer positn: \(layer.position)")
        
        
        //create the line for the border
        let path = CGPathCreateMutable();
        CGPathMoveToPoint(path, nil, 0, 0);
        CGPathAddLineToPoint(path, nil, 0, layer.bounds.height);
        CGPathAddLineToPoint(path, nil, layer.bounds.width, layer.bounds.height);
        CGPathAddLineToPoint(path, nil, layer.bounds.width, 0);
        CGPathCloseSubpath(path);
        layer.path = path;
        

        //update the sub positions
        for pos in positions {
            pos.updateLayer()
        }
    }
}

public func ==(lhs: PSPort, rhs: PSPort) -> Bool {
    return lhs.hashValue == rhs.hashValue
}
