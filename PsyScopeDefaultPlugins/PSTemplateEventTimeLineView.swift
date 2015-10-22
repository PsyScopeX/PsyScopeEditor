//
//  PSTemplateEventView.swift
//  PsyScopeEditor
//
//  Created by James on 12/12/2014.
//

import Foundation

class PSTimeLineTableView : NSTableView {
    override func validateProposedFirstResponder(responder: NSResponder, forEvent event: NSEvent?) -> Bool {
        return true
    }
}

//displays a timeline in a view
class PSTemplateEventTimeLineView : NSView {
    
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        initialise()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialise()
    }
    
    var objectValue : AnyObject? {
        get {
            return event
        }
        
        set {
            if let e = newValue as? PSTemplateEvent {
                self.event = e
                self.selected = false
                self.refreshLayers()
            }
        }
    }
    
    //used to initialise the basic graphics layers onc onstruction
    func initialise() {
        self.layer = CALayer()
        self.wantsLayer = true
        self.boxLayer = CALayer()
        self.layer!.addSublayer(self.boxLayer)
        
        let font = NSFont.systemFontOfSize(10)
        
        //layer for feedback during dragging
        draggingTextLayer.font = font
        draggingTextLayer.fontSize = 10
        draggingTextLayer.alignmentMode = kCAAlignmentRight
        draggingTextLayer.foregroundColor = NSColor.blackColor().CGColor
        draggingTextLayer.anchorPoint = CGPoint(x: 1, y: 0.5)
        draggingTextLayer.frame = CGRect(origin: CGPointZero, size: CGSizeMake(50,20))
        
        //box (timeline) layer
        boxLayer.backgroundColor = PSDefaultConstants.TemplateLayoutBoard.fixedTimeColor // luca changed from blue
        boxLayer.borderWidth = 2.0
        boxLayer.borderColor = NSColor.clearColor().CGColor
            
            //luca changed from NSColor.blackColor().CGColor
        boxLayer.shadowOffset = CGSizeMake(0, 0);
        boxLayer.shadowRadius = 0.0;
        boxLayer.shadowColor = NSColor.lightGrayColor().CGColor;/// luca changed from black
        boxLayer.shadowOpacity = 0.5; // luca changed from 0.8
        boxLayer.anchorPoint = CGPoint(x: 0.0, y: 0.5)
        boxLayer.frame = CGRect(origin: NSZeroPoint, size: CGSizeMake(100,PSDefaultConstants.Spacing.TLBtimeBarWidth))
    }
    
    var boxLayer : CALayer!
    var event : PSTemplateEvent!
    var durationIconLayers : [CALayer] = []
    var tableView : NSTableView!
    var durationTrackingArea : NSTrackingArea! = nil
    var startTrackingArea : NSTrackingArea! = nil
    var startTime : EventMSecs!
    var durationTime : EventMSecs!
    var minimumStartTime : EventMSecs!
    var canDragStartTime : Bool = false
    var canDragDurationTime : Bool = false
    var canDragUnscheduledPosition : Bool = false
    var y_pos : CGFloat = (PSDefaultConstants.Spacing.TLBtimeBarViewHeight - PSDefaultConstants.Spacing.TLBtimeBarWidth) / 2
    var icon_y_pos : CGFloat = PSDefaultConstants.Spacing.TLBtimeBarViewHeight / 2
    var text_y_pos : CGFloat = (PSDefaultConstants.Spacing.TLBtimeBarViewHeight - CGFloat(14)) / 2
    var u_y_pos : CGFloat = PSDefaultConstants.Spacing.TLBtimeBarViewHeight / 2
    var currentValue_y_pos : CGFloat = (PSDefaultConstants.Spacing.TLBtimeBarViewHeight - CGFloat(14)) / 2
    var draggedStartTime : EventMSecs! = 0
    var draggingTextLayer : CATextLayer = CATextLayer()
    var durationDragging : Bool = false
    var dragLocation : NSPoint! = nil
    var inStartArea : Bool = false
    var inDurationArea : Bool = false
    var startDragging : Bool = false
    var zoomMultiplier : CGFloat = 1

    //highlight graphic elements when selected (and reverse when unselected)
    var selected : Bool = false {
        didSet {
            if (selected) {
                boxLayer.borderColor = NSColor.redColor().CGColor
                boxLayer.borderWidth = 2.0
            } else {
                boxLayer.borderColor = NSColor.blackColor().CGColor// originally darkGrayColor
                boxLayer.borderWidth = 0.0
            }
        }
    }
    
    
    
    //call to refresh the layers position within the view and all icons
    func refreshLayers() {
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        //get times
        var (starts, durations) = event.getMS()
        startTime = starts * zoomMultiplier
        durationTime = durations * zoomMultiplier
        
        //update dragging
        canDragStartTime = false
        canDragUnscheduledPosition = false
        canDragDurationTime = false
        
        if let sc = event.startCondition as? EventStartEventRelated {
            
            let starting_event = sc.event!
            var (previousStart, previousDuration) = starting_event.getMS()
            
            minimumStartTime = sc.position == EventStartEventRelatedPosition.End ? previousStart + previousDuration : previousStart
            canDragStartTime = true
        } else if let sc = event.startCondition as? EventStartConditionTrialStart {
            minimumStartTime = 0
            canDragStartTime = true
        } else if let sc = event.startCondition as? EventStartConditionUnscheduled {
            minimumStartTime = 0
            canDragUnscheduledPosition = true
        }
        
        if let dc = event.durationCondition as? EventDurationConditionFixedTime {
            canDragDurationTime = true
        }
        
        //update color of bar
        boxLayer.backgroundColor = event.durationCondition.durationKnown() ? PSDefaultConstants.TemplateLayoutBoard.fixedTimeColor : PSDefaultConstants.TemplateLayoutBoard.unknownTimeColor
        
        //Change the color for the events with termination trial end. Trying purple (luca 21 oct)
        if let dc = event.durationCondition as? EventDurationConditionTrialEnd {
            
            canDragDurationTime = true
         
            boxLayer.backgroundColor = NSColor.purpleColor().CGColor
            boxLayer.cornerRadius = 15 // ideally only the right corners should be rounded (luca)
            
        }
        
        

        //update box layer
        let frame : CGRect = CGRect(origin: CGPoint(x: startTime, y: y_pos), size: CGSizeMake(durationTime, PSDefaultConstants.Spacing.TLBtimeBarWidth))
        self.boxLayer.frame = frame
        
        //update trackingArea
        if startTrackingArea != nil {
            self.removeTrackingArea(startTrackingArea)
            startTrackingArea = nil
        }
        
        if canDragStartTime || canDragUnscheduledPosition {
            let leftPart : CGRect = CGRect(origin: CGPoint(x: startTime-5, y: y_pos), size: CGSizeMake(10,PSDefaultConstants.Spacing.TLBtimeBarWidth))
            startTrackingArea = NSTrackingArea(rect: leftPart, options: [NSTrackingAreaOptions.ActiveInActiveApp, NSTrackingAreaOptions.MouseEnteredAndExited], owner: self, userInfo: [:])
            self.addTrackingArea(startTrackingArea)
        }
        
        
        if durationTrackingArea != nil {
            self.removeTrackingArea(durationTrackingArea)
            durationTrackingArea = nil
        }
        
        if canDragDurationTime {
            let rightPart : CGRect = CGRect(origin: CGPoint(x: startTime + durationTime - 5, y: y_pos), size: CGSizeMake(10,PSDefaultConstants.Spacing.TLBtimeBarWidth))
            durationTrackingArea = NSTrackingArea(rect: rightPart, options: [NSTrackingAreaOptions.ActiveInActiveApp, NSTrackingAreaOptions.MouseEnteredAndExited], owner: self, userInfo: [:])
            self.addTrackingArea(durationTrackingArea)
        }
        
        //remove existing icons
        for l in durationIconLayers {
            l.removeFromSuperlayer()
        }
        durationIconLayers = []
        
        //update icon layer
        var icons : Int = 0
        for icon in event.durationCondition.getIcons() {
            let new_icon = CALayer()
            new_icon.shadowOffset = CGSizeMake(0, 0)
            new_icon.shadowRadius = 0.0
            new_icon.contents = icon
            new_icon.borderColor = NSColor.clearColor().CGColor//LucaL changed from white
            new_icon.borderWidth = 0.0;
            new_icon.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            new_icon.bounds = CGRect(origin: NSZeroPoint, size: CGSizeMake(15,15))
            let offset : CGFloat = CGFloat(10 + (icons * 20))
            new_icon.position = CGPoint(x: startTime + durationTime - offset, y: icon_y_pos)
            self.layer!.addSublayer(new_icon)
            durationIconLayers.append(new_icon)
            icons++
        }
        
        //add text layer if appropriate 
        let text = event.durationCondition.getTimelineText()
        if text != "" {
            let text_layer = CATextLayer()
            let font = NSFont.systemFontOfSize(10)
            text_layer.font = font
            text_layer.fontSize = 10
            text_layer.string = text
            text_layer.alignmentMode = kCAAlignmentRight
            text_layer.frame = frame
            text_layer.foregroundColor = NSColor.blackColor().CGColor
            text_layer.anchorPoint = CGPoint(x: 1, y: 0.5)
            
            let offset : CGFloat = CGFloat(3 + (icons * 20))
            text_layer.position = CGPoint(x: startTime + durationTime - offset, y: text_y_pos)
            self.layer!.addSublayer(text_layer)
            durationIconLayers.append(text_layer)
        }
        
        //add "U"  character at start if event is unscheduled (LucaL Changed from question mark)
        var unscheduled : Bool = false
        if let sc = event.startCondition as? EventStartConditionUnscheduled {
            unscheduled = true
            let text_layer = CATextLayer()
            let font = NSFont.systemFontOfSize(10)
            text_layer.font = font
            text_layer.fontSize = 18
            text_layer.string = "U"
            text_layer.alignmentMode = kCAAlignmentLeft
            text_layer.frame = frame
            text_layer.foregroundColor = NSColor.redColor().CGColor
            text_layer.anchorPoint = CGPoint(x: 0, y: 0.5)
            
            
            text_layer.position = CGPoint(x: startTime + 3, y: u_y_pos)
            self.layer!.addSublayer(text_layer)
            durationIconLayers.append(text_layer)
        }
        
        //add currentValue if it is not zero
        let currentValue = self.event.getMainStimulusAttributeValue()
        if currentValue != "" {
            let text_layer = CATextLayer()
            let font = NSFont.systemFontOfSize(10)
            text_layer.font = font
            text_layer.fontSize = 12
            text_layer.string = currentValue
            text_layer.alignmentMode = kCAAlignmentLeft
            text_layer.truncationMode = kCATruncationEnd
            text_layer.foregroundColor = NSColor.darkGrayColor().CGColor
            text_layer.anchorPoint = CGPoint(x: 0, y: 0.5)
            //text_layer.borderColor = NSColor.lightGrayColor().CGColor
            //text_layer.borderWidth = 1
            let offset : CGFloat = CGFloat(3 + (icons * 20))
            let xPos : CGFloat = unscheduled ? 18 : 3
            let width = durationTime - xPos - offset
            text_layer.frame = CGRect(origin: CGPoint(x: startTime + xPos, y: currentValue_y_pos),
                size: CGSizeMake(width, 16))
            //text_layer.position = CGPoint(x: xPos, y: 26)
            self.layer!.addSublayer(text_layer)
            durationIconLayers.append(text_layer)
        }
        
        CATransaction.commit()
    }
    
    override func mouseDown(theEvent: NSEvent) {
        
        if ((inStartArea || inDurationArea) && theEvent.clickCount == 1) {
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            if inStartArea { startDragging = true } else if inDurationArea { durationDragging = true}
            dragLocation = theEvent.locationInWindow
            self.boxLayer.borderColor = NSColor.whiteColor().CGColor
            self.boxLayer.borderWidth = 2.0
            
            for l in durationIconLayers {
                Swift.print("hiding")
                l.hidden = true
            }
            self.layer!.addSublayer(draggingTextLayer)
            
            if inStartArea {
                draggingTextLayer.string = Int(startTime - minimumStartTime).description + " ms"
                draggingTextLayer.position = CGPoint(x: startTime - 3, y: 21)
            } else {
                draggingTextLayer.string = Int(durationTime).description + " ms"
                draggingTextLayer.position = CGPoint(x: startTime + durationTime - 3, y: 21)
            }
            CATransaction.commit()
        } else {
            let row = tableView.rowForView(self)
            let index = NSIndexSet(index: row)
            if let d = tableView.delegate() {
                d.tableView!(tableView, shouldSelectRow: row)
            }
            tableView.selectRowIndexes(index, byExtendingSelection: false)
        }
        
        
        if (theEvent.clickCount == 2) {
            //show properties window
        }
    }
    
    
    
    override func mouseDragged(theEvent: NSEvent) {
        if startDragging || durationDragging  {
            //displacement
            
            let displacement_x = theEvent.locationInWindow.x - dragLocation.x
            

            CATransaction.begin()
            CATransaction.setDisableActions(true)
            
            //update icon
            if startDragging {
                draggedStartTime = max(minimumStartTime, startTime + displacement_x)
                let frame : CGRect = CGRect(origin: CGPoint(x: draggedStartTime, y: y_pos), size: CGSizeMake(durationTime,PSDefaultConstants.Spacing.TLBtimeBarWidth))
                self.boxLayer.frame = frame
                draggingTextLayer.string = Int(draggedStartTime - minimumStartTime).description + " ms"
                draggingTextLayer.position = CGPoint(x: draggedStartTime - 3, y: 21)
            } else if durationDragging {
                draggedStartTime = max(0, durationTime + displacement_x)
                let frame : CGRect = CGRect(origin: CGPoint(x: startTime, y: y_pos), size: CGSizeMake(draggedStartTime,PSDefaultConstants.Spacing.TLBtimeBarWidth))
                self.boxLayer.frame = frame
                draggingTextLayer.string = Int(draggedStartTime).description + " ms"
                draggingTextLayer.position = CGPoint(x: startTime + draggedStartTime - 3, y: 21)
            }
            
            CATransaction.commit()
        }
    }
    
    override func mouseUp(theEvent: NSEvent) {
        if startDragging {
            let displacement_x = theEvent.locationInWindow.x - dragLocation.x
            
            
            draggedStartTime = max(minimumStartTime, startTime + displacement_x)
            
            if canDragStartTime {
                let eventStartCondition = event.startCondition
                eventStartCondition.event_time = EventTime.FixedTime(draggedStartTime - minimumStartTime)
                event.startCondition = eventStartCondition //triggers set method
            } else {
                //set meta data for event
                event.startCondition = EventStartConditionUnscheduled(fakePositionTime: draggedStartTime - minimumStartTime)
            }
            
            
            for l in durationIconLayers {
                l.hidden = false
            }
            
            startDragging = false
            dragLocation = nil
            self.boxLayer.borderColor = NSColor.blackColor().CGColor
            self.boxLayer.borderWidth = 0.5
            draggingTextLayer.removeFromSuperlayer()
        } else if durationDragging {
            let displacement_x = theEvent.locationInWindow.x - dragLocation.x
            
            
            draggedStartTime = max(0, durationTime + displacement_x)
            event.durationCondition = EventDurationConditionFixedTime(time: Int(draggedStartTime))
            for l in durationIconLayers {
                Swift.print("showing")
                l.hidden = false
            }
            
            durationDragging = false
            dragLocation = nil
            self.boxLayer.borderColor = NSColor.blackColor().CGColor
            self.boxLayer.borderWidth = 0.5
            draggingTextLayer.removeFromSuperlayer()
        }
        
    }
    
    override func mouseEntered(theEvent: NSEvent) {
        if theEvent.trackingArea == startTrackingArea  && (canDragStartTime || canDragUnscheduledPosition) && !inDurationArea {
            inStartArea = true
            inDurationArea = false
            NSCursor.resizeLeftRightCursor().set()
        } else if theEvent.trackingArea == durationTrackingArea && canDragDurationTime && !inStartArea {
            inDurationArea = true
            inStartArea = false
            NSCursor.resizeLeftRightCursor().set()
        }
    }
    
    override func mouseExited(theEvent: NSEvent) {
        if theEvent.trackingArea == startTrackingArea && inStartArea {
            inStartArea = false
            NSCursor.arrowCursor().set()
        }
        
        if theEvent.trackingArea == durationTrackingArea && inDurationArea {
            inDurationArea = false
            NSCursor.arrowCursor().set()
        }
    }
    
    override func acceptsFirstMouse(theEvent: NSEvent?) -> Bool { return true }
}