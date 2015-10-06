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

//this contains a layer, which has the screen layers (representing the screen layout) as well as the ports and positions
@objc class PSPortPreviewView: NSView {

    var controller : PSPortBuilderController!
    var previousClickedLayers : [CALayer] = []
    var clickedLayer : PSPortClickedLayer?
    var dragged : Bool = false
    var highlightedIndex : Int = 0
    var fullScreen : Bool = false
    var mainLayer : CALayer? //the main layer where coordinates make sense....
    var screenLayers : [CALayer] = []  //blueish rectangles representing the screen layout
    var centreOffset : CGPoint = CGPointZero
    var portScript : PSPortScript!
    
    var entireScreenPortLayer : CALayer? //holds the layer for the port for the entire screen (if it exists)
    
    override func awakeFromNib() {
        portScript = controller.portScript
        self.layer = CALayer()
        self.mainLayer = CALayer()
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.lightGrayColor().CGColor
        self.layer?.addSublayer(mainLayer!)
        
        resetDisplayToScreensOnly()
    }
    
    override var flipped : Bool { get { return true }}
    
    //MARK: Refresh methods
    
    
    //removes all layers except the screen layers (e.g. all ports and positions)
    func resetDisplayToScreensOnly() {
        guard let mainLayer = mainLayer else { fatalError("No layer detected") }
        let subLayers : [CALayer] = mainLayer.sublayers == nil ? [] : mainLayer.sublayers!
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        //remove existing layers
        for layer in subLayers {
            layer.removeFromSuperlayer()
        }
        
        //add the screen layers
        updateScreenLayers()
        
        CATransaction.commit()
    }
    
    //sets the layer to match the size of the screen(s) / and fit into the view
    func updateScreenLayers() {
        
        guard let mainLayer = mainLayer else { fatalError("No layer detected") }
        
        //format the main bg layer
        mainLayer.backgroundColor = NSColor.lightGrayColor().CGColor
        
        //get the effective size of the screens and their origin
        let effectiveResolution = PSScreen.getEffectiveResolution()
        let effectiveOrigin = effectiveResolution.origin
        
        //Swift.print("EffectiveRes:  \(effectiveResolution)  EffectiveOrig: \(effectiveOrigin)")
        
        //get the size of the view in which to position the layers
        
        let viewSize = self.bounds.size
        let viewWidth : CGFloat = viewSize.width
        let viewHeight : CGFloat = viewSize.height
        
        
        
        //to resize the layers to fit within the mainLayer, find the ratio to fit them in
        let ratio1 = viewWidth / (effectiveResolution.width)
        let ratio2 = viewHeight / (effectiveResolution.height)
        let ratio = min(ratio1, ratio2)
        
        if ratio == ratio1 {
            //width used to create ratio, so can centre height
            let heightOfScreenInViewCoords = (ratio1 * effectiveResolution.height)
            let offset = (heightOfScreenInViewCoords - viewHeight) / CGFloat(2)
            centreOffset = CGPoint(x: 0, y: heightOfScreenInViewCoords - offset)
            
        } else {
            //height used to create ratio, so can centre width
            
            let widthOfScreenInViewCoords = (ratio2 * effectiveResolution.width)
            let offset = (widthOfScreenInViewCoords - viewWidth) / CGFloat(2)
            centreOffset = CGPoint(x: 0 - offset, y: viewHeight)
        }
        
        Swift.print("Centre offset \(centreOffset) ER: \(effectiveResolution)")
        Swift.print("View size: \(viewSize), ratio \(ratio)")
        
        //transform the layers scale
        
        //var transform = CATransform3DMakeScale(ratio, 0 - ratio, 1.0)
        var transform = CATransform3DMakeTranslation(centreOffset.x, centreOffset.y, 0)
        transform = CATransform3DScale(transform, ratio, 0 - ratio, 1.0)
        mainLayer.bounds = self.bounds
        mainLayer.transform = transform
        mainLayer.anchorPoint = CGPointZero
        mainLayer.position = CGPointZero
        
        
        //add the layers representing screens
        for screen in PSScreen.getScreens() {
            let screenLayer = CALayer()
            screenLayer.backgroundColor = PSConstants.BasicDefaultColors.backgroundColor
            screenLayer.anchorPoint = CGPoint(x: 0.0, y: 0.0)
            
        
            screenLayer.bounds = NSRectToCGRect(screen.frame)
            
            
            //screens come in with flipped y coords
            let position = CGPoint(x: screen.frame.origin.x - effectiveOrigin.x, y: effectiveResolution.height - (screen.frame.origin.y + screen.frame.height))
            
            //Swift.print("Screen:  \(screen.frame)  Position: \(position)")
            screenLayer.position = position
            screenLayers.append(screenLayer)
            mainLayer.addSublayer(screenLayer)
        }
        
        
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
            //Swift.print("View: \(click_point)")
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
        guard let mainLayer = mainLayer else { fatalError("No layer detected") }
    
        let viewCoordsPoint = mainLayer.convertPoint(point, fromLayer: nil)
        let convertedPoint = CGPoint(x: viewCoordsPoint.x + centreOffset.x, y: viewCoordsPoint.y + centreOffset.y)
        Swift.print("Converted \(convertedPoint)")
        
        //cycle through each screen
        for screenLayer in screenLayers {
            if screenLayer.sublayers != nil {
                for eachLayer in screenLayer.sublayers! {
                    
                    if eachLayer !== self.entireScreenPortLayer {
                        
                        let pointInScreenLayer = eachLayer.convertPoint(convertedPoint, fromLayer: screenLayer)
                        if eachLayer.containsPoint(pointInScreenLayer) {
                            return_val.append(eachLayer )
                        }
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
            updateScreenLayers()
            fullScreen = true
            self.becomeFirstResponder()
        }
    }
    
    func leaveFullScreen() {
        if (fullScreen) {
            exitFullScreenModeWithOptions([:])
            Swift.print(self.window)
            updateScreenLayers()
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
    
 
    
    
    //MARK: For Adding new port layers
    func addNewPort(port : PSPort) {
        addLayerAtTop(port.layer)
    }
    
    func addNewPosition(position : PSPosition) {
        addLayerAtTop(position.layer)
    }
    
    func addLayerAtTop(layer : CALayer) {
        guard let mainLayer = mainLayer, sublayers = mainLayer.sublayers else { fatalError("No layer detected") }
        mainLayer.insertSublayer(layer, atIndex: UInt32(sublayers.count))
    }
    
    //MARK: To set a layer as being the entire screen port (immovable etc)
    
    func setEntireScreenPort(port : PSPort?) {
        entireScreenPortLayer = port?.layer
    }
}
