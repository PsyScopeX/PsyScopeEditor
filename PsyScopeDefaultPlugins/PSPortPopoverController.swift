//
//  PSPortPopoverController.swift
//  PsyScopeEditor
//
//  Created by James on 02/06/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSPortPopoverController : NSObject {
    //Main controller
    var portBuilderController : PSPortBuilderController!
    
    //Popover
    @IBOutlet var portPopover : NSPopover!
    
    //Port popover controls
    @IBOutlet var portNameText : NSTextField!
    @IBOutlet var shapePopup : NSPopUpButton!
    @IBOutlet var heightText : NSTextField!
    @IBOutlet var widthText : NSTextField!
    @IBOutlet var yText : NSTextField!
    @IBOutlet var xText : NSTextField!
    @IBOutlet var borderText : NSTextField!
    @IBOutlet var hotspotPopup : NSPopUpButton!
    @IBOutlet var hotspotYText : NSTextField!
    @IBOutlet var hotspotXText : NSTextField!
    @IBOutlet var yPopup : NSPopUpButton!
    @IBOutlet var xPopup : NSPopUpButton!
    @IBOutlet var heightPopup : NSPopUpButton!
    @IBOutlet var widthPopup : NSPopUpButton!
    @IBOutlet var heightInc : NSStepper!
    @IBOutlet var widthInc : NSStepper!
    @IBOutlet var yInc : NSStepper!
    @IBOutlet var xInc : NSStepper!
    @IBOutlet var borderInc : NSStepper!
    
    var selectedPort : PSPort {
        get {
            return portBuilderController.selectedPort!
        }
    }
    
    var view : NSView! = nil
    
    func close() {
        portPopover.close()
    }
    
    func show(view : NSView) {
        self.view = view
        portPopover.showRelativeToRect(view.bounds, ofView: view, preferredEdge: NSRectEdge.MinY)
    }
    
    var shown : Bool {
        return portPopover.shown
    }
    
    func updatePopoverControls(port : PSPort) {
        portNameText.stringValue = port.name as String
        
        switch (port.height) {
        case let .Percentage(perc):
            heightText.stringValue = "\(perc)"
            heightPopup.selectItemWithTitle("Percent")
            heightInc.integerValue = perc
            break
        case let .Pixels(pix):
            heightText.stringValue = "\(pix)"
            heightPopup.selectItemWithTitle("Pixels")
            heightInc.integerValue = pix
            break
        case .Bottom:
            heightPopup.selectItemWithTitle("Bottom")
        case .Top:
            heightPopup.selectItemWithTitle("Top")
        case .Left:
            heightPopup.selectItemWithTitle("Left")
        case .Right:
            heightPopup.selectItemWithTitle("Right")
        case .Centre:
            heightPopup.selectItemWithTitle("Center")
            break
        }
        
        
        
        switch (port.width) {
        case let .Percentage(perc):
            widthText.stringValue = "\(perc)"
            widthPopup.selectItemWithTitle("Percent")
            widthInc.integerValue = perc
            break
        case let .Pixels(pix):
            widthText.stringValue = "\(pix)"
            widthPopup.selectItemWithTitle("Pixels")
            widthInc.integerValue = pix
            break
        case .Bottom:
            widthPopup.selectItemWithTitle("Bottom")
        case .Top:
            widthPopup.selectItemWithTitle("Top")
        case .Left:
            widthPopup.selectItemWithTitle("Left")
        case .Right:
            widthPopup.selectItemWithTitle("Right")
        case .Centre:
            widthPopup.selectItemWithTitle("Center")
        }
        
        switch (port.x) {
        case let .Percentage(perc):
            xText.stringValue = "\(perc)"
            xPopup.selectItemWithTitle("Percent")
            xInc.integerValue = perc
            break
        case let .Pixels(pix):
            xText.stringValue = "\(pix)"
            xPopup.selectItemWithTitle("Pixels")
            xInc.integerValue = pix
            break
        case .Bottom:
            xPopup.selectItemWithTitle("Bottom")
        case .Top:
            xPopup.selectItemWithTitle("Top")
        case .Left:
            xPopup.selectItemWithTitle("Left")
        case .Right:
            xPopup.selectItemWithTitle("Right")
        case .Centre:
            xPopup.selectItemWithTitle("Center")
        }
        
        switch (port.y) {
        case let .Percentage(perc):
            yText.stringValue = "\(perc)"
            yPopup.selectItemWithTitle("Percent")
            yInc.integerValue = perc
            break
        case let .Pixels(pix):
            yText.stringValue = "\(pix)"
            yPopup.selectItemWithTitle("Pixels")
            yInc.integerValue = pix
            break
        case .Bottom:
            yPopup.selectItemWithTitle("Bottom")
        case .Top:
            yPopup.selectItemWithTitle("Top")
        case .Left:
            yPopup.selectItemWithTitle("Left")
        case .Right:
            yPopup.selectItemWithTitle("Right")
        case .Centre:
            yPopup.selectItemWithTitle("Center")
        }
        
        switch (port.shape) {
        case .Rectangle:
            shapePopup.selectItemWithTitle("Rectangle")
        case .Oval:
            shapePopup.selectItemWithTitle("Oval")
        case .Rounded:
            shapePopup.selectItemWithTitle("Rounded Corners")
        }
        
        borderText.stringValue = "\(port.border)"
        borderInc.integerValue = port.border
        
        switch (port.alignmentPoint) {
            
        case .Specified(let x, let y):
            hotspotXText.stringValue = "\(x)"
            hotspotYText.stringValue = "\(y)"
        default:
            hotspotXText.stringValue = "0"
            hotspotYText.stringValue = "0"
        }
        
        hideControls(hotspotPopup, controls: [hotspotXText, hotspotYText])
        hideControls(xPopup, controls: [xInc, xText])
        hideControls(yPopup, controls: [yInc, yText])
        hideControls(widthPopup, controls: [widthInc, widthText])
        hideControls(heightPopup, controls: [heightInc, heightText])
    }
    
    func hideControls(button : NSPopUpButton, controls : [NSView]) {
        var title = ""
        if let si = button.selectedItem {
            title = si.title
        }
        
        var hidden = true
        switch (title) {
        case "Specify":
            hidden = false
        case "Pixels":
            hidden = false
        case "Percent":
            hidden = false
        default:
            hidden = true
            break
        }
        
        for c in controls {
            c.hidden = hidden
        }
    }
    
    @IBAction func shapePopOver(menuItem : NSMenuItem) {
        let selected = menuItem.title
        
        var shape : PSPortShape
        
        switch (selected) {
            
        case "Oval":
            shape = .Oval
        case "Rounded Corners":
            shape = .Rounded
        default:
            shape = .Rectangle
        }
        
        selectedPort.shape = shape
    }
    
    @IBAction func measurePopOver(button : NSPopUpButton) {
        _ = button.selectedItem!.title
        
        switch (button) {
        case self.heightPopup:
            hideControls(heightPopup, controls: [heightInc, heightText])
            selectedPort.height = PSPortMeasurement.measurementForItemTitle(heightPopup, textField: self.heightText)
        case self.widthPopup:
            hideControls(widthPopup, controls: [widthInc, widthText])
            selectedPort.width = PSPortMeasurement.measurementForItemTitle(widthPopup, textField: self.widthText)
        case self.xPopup:
            hideControls(xPopup,controls: [xInc,xText])
            selectedPort.x = PSPortMeasurement.measurementForItemTitle(xPopup, textField: self.xText)
        case self.yPopup:
            hideControls(yPopup,controls: [yInc,yText])
            selectedPort.y = PSPortMeasurement.measurementForItemTitle(yPopup, textField: self.yText)
        case self.hotspotPopup:
            hideControls(hotspotPopup, controls: [hotspotXText, hotspotYText])
            var title = ""
            
            if let si = hotspotPopup.selectedItem {
                title = si.title
            }
            
            switch (title) {
            case "Auto":
                selectedPort.alignmentPoint = PSAlignmentPoint.Auto
            case "Center":
                selectedPort.alignmentPoint = PSAlignmentPoint.Center
            case "Specify":
                let x = hotspotXText.integerValue
                let y = hotspotYText.integerValue
                selectedPort.alignmentPoint = PSAlignmentPoint.Specified(x, y)
            default:
                selectedPort.alignmentPoint = PSAlignmentPoint.Auto
            }
            
            
        default:
            break
        }
    }
    
    @IBAction func stepperDidChange(stepper : NSStepper) {
        switch (stepper) {
        case heightInc:
            selectedPort.height = selectedPort.height.sameWithNewValue(heightInc.integerValue)
        case widthInc:
            selectedPort.width = selectedPort.width.sameWithNewValue(widthInc.integerValue)
        case yInc :
            selectedPort.y = selectedPort.y.sameWithNewValue(yInc.integerValue)
            break
        case xInc :
            selectedPort.x = selectedPort.x.sameWithNewValue(xInc.integerValue)
            break
        case borderInc:
            selectedPort.border = borderInc.integerValue
        default:
            break
            
        }
    }
    
    func control(control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        switch (control) {
        case heightText:
            selectedPort.height = selectedPort.height.sameWithNewValue(Int(heightText.stringValue)!)
        case widthText:
            selectedPort.width = selectedPort.width.sameWithNewValue(Int(widthText.stringValue)!)
        case yText :
            selectedPort.y = selectedPort.y.sameWithNewValue(Int(yText.stringValue)!)
            break
        case xText :
            selectedPort.x = selectedPort.x.sameWithNewValue(Int(xText.stringValue)!)
            break
        case borderText:
            selectedPort.border = Int(borderText.stringValue)!
        case hotspotYText:
            let y = hotspotYText.integerValue
            let x = hotspotXText.integerValue
            selectedPort.alignmentPoint = PSAlignmentPoint.Specified(x, y)
        case hotspotXText:
            let y = hotspotYText.integerValue
            let x = hotspotXText.integerValue
            selectedPort.alignmentPoint = PSAlignmentPoint.Specified(x, y)
        case portNameText:
            selectedPort.name = portNameText.stringValue
        default:
            break
            
        }
        return true
    }
}