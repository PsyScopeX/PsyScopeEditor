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
    
    func show(_ view : NSView) {
        self.view = view
        portPopover.show(relativeTo: view.bounds, of: view, preferredEdge: NSRectEdge.minY)
    }
    
    var shown : Bool {
        return portPopover.isShown
    }
    
    func updatePopoverControls(_ port : PSPort) {
        portNameText.stringValue = port.name as String
        
        switch (port.height) {
        case let .percentage(perc):
            heightText.stringValue = "\(perc)"
            heightPopup.selectItem(withTitle: "Percent")
            heightInc.integerValue = perc
            break
        case let .Pixels(pix):
            heightText.stringValue = "\(pix)"
            heightPopup.selectItem(withTitle: "Pixels")
            heightInc.integerValue = pix
            break
        case .bottom:
            heightPopup.selectItem(withTitle: "Bottom")
        case .top:
            heightPopup.selectItem(withTitle: "Top")
        case .left:
            heightPopup.selectItem(withTitle: "Left")
        case .right:
            heightPopup.selectItem(withTitle: "Right")
        case .centre:
            heightPopup.selectItem(withTitle: "Center")
            break
        }
        
        
        
        switch (port.width) {
        case let .percentage(perc):
            widthText.stringValue = "\(perc)"
            widthPopup.selectItem(withTitle: "Percent")
            widthInc.integerValue = perc
            break
        case let .Pixels(pix):
            widthText.stringValue = "\(pix)"
            widthPopup.selectItem(withTitle: "Pixels")
            widthInc.integerValue = pix
            break
        case .bottom:
            widthPopup.selectItem(withTitle: "Bottom")
        case .top:
            widthPopup.selectItem(withTitle: "Top")
        case .left:
            widthPopup.selectItem(withTitle: "Left")
        case .right:
            widthPopup.selectItem(withTitle: "Right")
        case .centre:
            widthPopup.selectItem(withTitle: "Center")
        }
        
        switch (port.x) {
        case let .percentage(perc):
            xText.stringValue = "\(perc)"
            xPopup.selectItem(withTitle: "Percent")
            xInc.integerValue = perc
            break
        case let .Pixels(pix):
            xText.stringValue = "\(pix)"
            xPopup.selectItem(withTitle: "Pixels")
            xInc.integerValue = pix
            break
        case .bottom:
            xPopup.selectItem(withTitle: "Bottom")
        case .top:
            xPopup.selectItem(withTitle: "Top")
        case .left:
            xPopup.selectItem(withTitle: "Left")
        case .right:
            xPopup.selectItem(withTitle: "Right")
        case .centre:
            xPopup.selectItem(withTitle: "Center")
        }
        
        switch (port.y) {
        case let .percentage(perc):
            yText.stringValue = "\(perc)"
            yPopup.selectItem(withTitle: "Percent")
            yInc.integerValue = perc
            break
        case let .Pixels(pix):
            yText.stringValue = "\(pix)"
            yPopup.selectItem(withTitle: "Pixels")
            yInc.integerValue = pix
            break
        case .bottom:
            yPopup.selectItem(withTitle: "Bottom")
        case .top:
            yPopup.selectItem(withTitle: "Top")
        case .left:
            yPopup.selectItem(withTitle: "Left")
        case .right:
            yPopup.selectItem(withTitle: "Right")
        case .centre:
            yPopup.selectItem(withTitle: "Center")
        }
        
        switch (port.shape) {
        case .Rectangle:
            shapePopup.selectItem(withTitle: "Rectangle")
        case .Oval:
            shapePopup.selectItem(withTitle: "Oval")
        case .Rounded:
            shapePopup.selectItem(withTitle: "Rounded Corners")
        }
        
        borderText.stringValue = "\(port.border)"
        borderInc.integerValue = port.border
        
        switch (port.alignmentPoint) {
            
        case .specified(let x, let y):
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
    
    func hideControls(_ button : NSPopUpButton, controls : [NSView]) {
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
            c.isHidden = hidden
        }
    }
    
    @IBAction func shapePopOver(_ menuItem : NSMenuItem) {
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
    
    @IBAction func measurePopOver(_ button : NSPopUpButton) {
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
                selectedPort.alignmentPoint = PSAlignmentPoint.auto
            case "Center":
                selectedPort.alignmentPoint = PSAlignmentPoint.center
            case "Specify":
                let x = hotspotXText.integerValue
                let y = hotspotYText.integerValue
                selectedPort.alignmentPoint = PSAlignmentPoint.specified(x, y)
            default:
                selectedPort.alignmentPoint = PSAlignmentPoint.auto
            }
            
            
        default:
            break
        }
    }
    
    @IBAction func stepperDidChange(_ stepper : NSStepper) {
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
    
    func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
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
            selectedPort.alignmentPoint = PSAlignmentPoint.specified(x, y)
        case hotspotXText:
            let y = hotspotYText.integerValue
            let x = hotspotXText.integerValue
            selectedPort.alignmentPoint = PSAlignmentPoint.specified(x, y)
        case portNameText:
            selectedPort.name = portNameText.stringValue
        default:
            break
            
        }
        return true
    }
}
