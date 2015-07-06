//
//  PSPortPreviewView.swift
//  PsyScopeEditor
//
//  Created by James on 24/09/2014.
//

import Cocoa

struct PSPortClickedLayer {
    var clickedLayer : CALayer = CALayer()
    var mouseDownPoint : NSPoint = NSPoint()
    var originalPosition : NSPoint = NSPoint()
}

@objc class PSPortPreviewView: NSView {

    var controller : PSPortBuilderController!
    var previousClickedLayers : [CALayer] = []
    var clickedLayer : PSPortClickedLayer?
    var dragged : Bool = false
    var highlightedIndex : Int = 0
    var fullScreen : Bool = false
    var screenLayer : CALayer!
    var entireScreenPortLayer : CALayer!
    
    override func awakeFromNib() {
        self.layer = CALayer()
        self.screenLayer = CALayer()
        self.wantsLayer = true
        self.layer?.addSublayer(screenLayer)
        self.layer!.backgroundColor = NSColor.lightGrayColor().CGColor
        self.screenLayer.backgroundColor = PSConstants.BasicDefaultColors.backgroundColor
        self.screenLayer.anchorPoint = CGPoint(x: 0.0, y: 0.5)
        resizeScreenLayer()
    }
    
    //sets the layer to match the size of the screen / and fit into the view
    func resizeScreenLayer() {
        let res = PSScreenRes()
        self.screenLayer.bounds = CGRect(origin: NSZeroPoint, size: CGSizeMake(CGFloat(res.width), CGFloat(res.height)))
        let view_size = self.layer!.bounds.size
        let view_width : CGFloat = view_size.width
        let view_height : CGFloat = view_size.height
        self.screenLayer.position = CGPoint(x: 0, y: view_height / 2)
        let ratio = (view_width / res.width)
        screenLayer.transform = CATransform3DMakeScale(ratio, ratio, 1.0)
    }
    
    //MARK: Key events
    
    override func keyDown(theEvent: NSEvent) {
        if theEvent.charactersIgnoringModifiers == String(Character(UnicodeScalar(NSDeleteCharacter))) {
            if !controller.deleteCurrentlySelectedItem() {
                if (fullScreen) { leaveFullScreen() }
            }
            return
        }
        if (fullScreen) { leaveFullScreen() }
    }
    
    //MARK: Mouse events
    
    override func mouseDown(theEvent: NSEvent) {
        dragged = false
        clickedLayer = nil
        
        //get clicked layers
        let click_point = self.convertPoint(theEvent.locationInWindow, fromView: nil)
        let hit_layers = hitLayers(NSPointToCGPoint(click_point))

        //determine if currently selected layer is clicked
        if highlightedIndex > -1 && highlightedIndex < previousClickedLayers.count {
            let currentlySelectedLayer = previousClickedLayers[highlightedIndex]
            if hit_layers.contains(currentlySelectedLayer) {
                //yes
                clickedLayer = PSPortClickedLayer(clickedLayer: currentlySelectedLayer, mouseDownPoint: theEvent.locationInWindow, originalPosition: currentlySelectedLayer.position)
            }
        } else {
            if hit_layers.count > 0 {
                //new layer
                previousClickedLayers = hit_layers
                highlightedIndex = 0
                let newSelectedLayer = previousClickedLayers[highlightedIndex]
                clickedLayer = PSPortClickedLayer(clickedLayer: newSelectedLayer, mouseDownPoint: theEvent.locationInWindow, originalPosition: newSelectedLayer.position)
                controller.selectLayer(newSelectedLayer)
            }
        }
        
    }
    
    override func mouseDragged(theEvent: NSEvent) {
        dragged = true
        
        if let clickedLayer = clickedLayer {
            let displacement = theEvent.locationInWindow.minusPoint(clickedLayer.mouseDownPoint)
            //displacement.y = 0 - displacement.y
            
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            
     
            let new_position = clickedLayer.originalPosition.plusPoint(displacement)
            clickedLayer.clickedLayer.position = new_position
            
            CATransaction.commit()
        }
    }
    
    override func mouseUp(theEvent: NSEvent) {
        if !dragged {
            let click_point = self.convertPoint(theEvent.locationInWindow, fromView: nil)
            Swift.print("View: \(click_point)")
            let hit_layers = hitLayers(NSPointToCGPoint(click_point))
            
            var same = true
            for nl in hit_layers {
                var found = false
                for nl2 in previousClickedLayers {
                    if nl == nl2 {
                        found = true
                        break
                    }
                }
                if !found {
                    same = false
                    break
                }
            }
            
            if hit_layers.count != previousClickedLayers.count {
                same = false
            }
            
            if (same) {
                //switch index (unelss nothing selected)
                if previousClickedLayers.count > 0 {
                    let new_index = highlightedIndex + 1
                    highlightedIndex = new_index % previousClickedLayers.count
                }
            } else {
                previousClickedLayers = hit_layers
                highlightedIndex = 0
                
            }
            
            if highlightedIndex < previousClickedLayers.count {
                let selected_layer : CALayer = previousClickedLayers[highlightedIndex]
                controller.selectLayer(selected_layer)
            }
        } else if let clickedLayer = clickedLayer {
            controller.updatePositionFromLayer(clickedLayer.clickedLayer, originalPosition: clickedLayer.originalPosition)
        }
        
        clickedLayer = nil
        dragged = false
    }
    
    func hitLayers(point : CGPoint) -> [CALayer] {
        var return_val : [CALayer] = []
        var point2 = screenLayer.convertPoint(point, fromLayer: layer)
        if screenLayer.sublayers != nil {
            for eachLayer in screenLayer.sublayers! {
                
                if eachLayer !== self.entireScreenPortLayer {
                
                    var point3 = eachLayer.convertPoint(point2, fromLayer: screenLayer)
                    if eachLayer.containsPoint(point3) {
                        return_val.append(eachLayer as! CALayer)
                    }
                }
            }
        }
        return return_val
    }
    
    //MARK: Full screen methods
    
    func goFullScreen() {
        if (!fullScreen) {
            enterFullScreenMode(self.window!.screen!, withOptions: nil)
            Swift.print(self.window)
            resizeScreenLayer()
            fullScreen = true
            self.becomeFirstResponder()
        }
    }
    
    func leaveFullScreen() {
        if (fullScreen) {
            exitFullScreenModeWithOptions([:])
            Swift.print(self.window)
            resizeScreenLayer()
            fullScreen = false
            Swift.print(self.window)
        }
    }
    
    
    //MARK: First responder overrides
    
    override var acceptsFirstResponder: Bool { get { return true } }
    
    override func acceptsFirstMouse(theEvent: NSEvent?) -> Bool {
        Swift.print("Accepts first mouse")
        return true
    }
}
