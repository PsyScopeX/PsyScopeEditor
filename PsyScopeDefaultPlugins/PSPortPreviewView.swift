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
    var mainLayer : CALayer? //the main layer where coordinates match those used by psyscopex
    var screenLayers : [CALayer] = []  //blueish rectangles representing the screen layout
    
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
        var centreOffset : CGPoint = CGPointZero
        
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
            
        
            screenLayer.frame = NSRectToCGRect(screen.frame)

            let position = CGPoint(x: screen.frame.origin.x - effectiveOrigin.x, y: screen.frame.origin.y - effectiveOrigin.y)
            
            Swift.print("Screen:  \(screen.frame)  Position: \(position)")
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
        let clickPoint = convertMousePoint(theEvent.locationInWindow)
        let currentHitLayers = hitLayers(NSPointToCGPoint(clickPoint))

        //determine if there is a currently selected layer
        if highlightedIndex > -1 && highlightedIndex < previousClickedLayers.count {
            let currentlySelectedLayer = previousClickedLayers[highlightedIndex]
            
            //determine if currently selected layer is one of those that is clicked (nothing to do here if not - mouse up changes selection in this case)
            if currentHitLayers.contains(currentlySelectedLayer) {
                //yes
                clickedLayer = PSPortClickedLayer(clickedLayer: currentlySelectedLayer, mouseDownPoint: convertMousePoint(theEvent.locationInWindow), originalPosition: currentlySelectedLayer.position)
            }
        } else {
            //determine if any layers have been hit, if so highlight first
            if currentHitLayers.count > 0 {
                
                previousClickedLayers = currentHitLayers
                highlightedIndex = 0
                let newSelectedLayer = previousClickedLayers[highlightedIndex]
                clickedLayer = PSPortClickedLayer(clickedLayer: newSelectedLayer, mouseDownPoint: convertMousePoint(theEvent.locationInWindow), originalPosition: newSelectedLayer.position)
                controller.selectLayer(newSelectedLayer)
            }
        }
        
    }
    
    override func mouseDragged(theEvent: NSEvent) {

        dragged = true
        
        if let clickedLayer = clickedLayer {
            let displacement = convertMousePoint(theEvent.locationInWindow).minusPoint(clickedLayer.mouseDownPoint)
  
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            
            let new_position = clickedLayer.originalPosition.plusPoint(displacement)
            clickedLayer.clickedLayer.position = new_position
            
            CATransaction.commit()
        }
    }
    
    override func mouseUp(theEvent: NSEvent) {
        if !dragged {
            
            //layer has not been dragged, so potentialy, change selection
            let clickPoint = convertMousePoint(theEvent.locationInWindow)
            let currentHitLayers = hitLayers(NSPointToCGPoint(clickPoint))
            
            //determine if the currentHitLayers are the same as the previous (e.g. user hasn't selected some new combo of layers)
            var same = true
            for nl in currentHitLayers {
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
            
            if currentHitLayers.count != previousClickedLayers.count {
                same = false
            }
            
            //if in the same area, then switch the selection, otherwise update the memory for previous clicked layers
            if (same) {
                //switch index (unelss nothing selected)
                if previousClickedLayers.count > 0 {
                    let new_index = highlightedIndex + 1
                    highlightedIndex = new_index % previousClickedLayers.count
                }
            } else {
                previousClickedLayers = currentHitLayers
                highlightedIndex = 0
                
            }
            
            //update the selection
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
    
    func convertMousePoint(point : CGPoint) -> CGPoint {
        guard let mainLayer = mainLayer else { fatalError("No layer detected") }
        let clickPoint = self.convertPoint(point, fromView: nil)
        let convertedPoint = mainLayer.convertPoint(clickPoint, fromLayer: nil)
        //Swift.print("Converted \(point) to \(convertedPoint)")
        return convertedPoint
    }
    
    func hitLayers(point : CGPoint) -> [CALayer] {
        var hitLayers : [CALayer] = []
        guard let mainLayer = mainLayer, sublayers = mainLayer.sublayers else { fatalError("No layer detected") }
        
        //cycle through each screen
        for layer in sublayers {
                    
            if layer !== self.entireScreenPortLayer && !screenLayers.contains(layer) {
                
                
                let convertedPoint = layer.convertPoint(point, fromLayer: mainLayer)
                
                if layer.containsPoint(convertedPoint) {
                    Swift.print("Then converted \(point) to \(convertedPoint)")
                    Swift.print(layer.position)
                    Swift.print(layer.bounds)
                    Swift.print(layer.frame)
                    hitLayers.append(layer)
                }
            }
        }
        
        return hitLayers
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
