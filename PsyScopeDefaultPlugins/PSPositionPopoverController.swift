//
//  PSPositionPopoverController.swift
//  PsyScopeEditor
//
//  Created by James on 02/06/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSPositionPopoverController : NSObject {
    //Main controller
    var portBuilderController : PSPortBuilderController!
    
    //Popover
    @IBOutlet var positionPopover : NSPopover!
    
    //Position Popover controls
    @IBOutlet var positionNameText : NSTextField!
    @IBOutlet var posyInc : NSStepper!
    @IBOutlet var posxInc : NSStepper!
    @IBOutlet var posyText : NSTextField!
    @IBOutlet var posxText : NSTextField!
    @IBOutlet var posyPopup : NSPopUpButton!
    @IBOutlet var posxPopup : NSPopUpButton!
    
    var view : NSView! = nil
    
    var selectedPosition : PSPosition {
        get {
            return portBuilderController.selectedPosition!
        }
    }
    
    func close() {
        positionPopover.close()
    }
    
    func show(_ view : NSView) {
        self.view = view
        positionPopover.show(relativeTo: view.bounds, of: view, preferredEdge: NSRectEdge.minY)
    }
    
    var shown : Bool {
        return positionPopover.isShown
    }
    
    func updatePopoverControls(_ position : PSPosition) {
        positionNameText.stringValue = position.name as String
        
        switch (position.x) {
        case let .percentage(perc):
            posxText.stringValue = "\(perc)"
            posxPopup.selectItem(withTitle: "Percent")
            posxInc.integerValue = perc
            break
        case let .Pixels(pix):
            posxText.stringValue = "\(pix)"
            posxPopup.selectItem(withTitle: "Pixels")
            posxInc.integerValue = pix
            break
        default:
            break
        }
        
        switch (position.y) {
        case let .percentage(perc):
            posyText.stringValue = "\(perc)"
            posyPopup.selectItem(withTitle: "Percent")
            posyInc.integerValue = perc
            break
        case let .Pixels(pix):
            posyText.stringValue = "\(pix)"
            posyPopup.selectItem(withTitle: "Pixels")
            posyInc.integerValue = pix
            break
        default:
            break
        }
    }
    
    @IBAction func measurePopOver(_ button : NSPopUpButton) {
        switch (button) {
        case self.posxPopup:
            let new_x = PSPortMeasurement.measurementForItemTitle(posxPopup,textField: posxText)
            selectedPosition.x = new_x
        case self.posyPopup:
            let new_y = PSPortMeasurement.measurementForItemTitle(posyPopup,textField: posyText)
            selectedPosition.y = new_y
        default:
            break
        }
    }
    
    @IBAction func stepperDidChange(_ stepper : NSStepper) {
        switch (stepper) {
        case posyInc :
            selectedPosition.y = selectedPosition.y.sameWithNewValue(posyInc.integerValue)
            break
        case posxInc :
            selectedPosition.x = selectedPosition.x.sameWithNewValue(posxInc.integerValue)
            break
        default:
            break
            
        }
    }
    
    func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        switch (control) {
        case posyText :
            selectedPosition.y = selectedPosition.y.sameWithNewValue(Int(posyText.stringValue)!)
            break
        case posxText :
            selectedPosition.x = selectedPosition.x.sameWithNewValue(Int(posxText.stringValue)!)
            break
        case positionNameText:
            selectedPosition.name = positionNameText.stringValue
        default:
            break
            
        }
        return true
    }
}
