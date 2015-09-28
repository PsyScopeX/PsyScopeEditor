//
//  PSTemplateLayoutBoardController.swift
//  PsyScopeEditor
//
//  Created by James on 08/09/2014.
//

import Cocoa




class PSTemplateLayoutBoardController: NSObject, NSTextFieldDelegate, NSTableViewDataSource, NSTableViewDelegate {
    
    //MARK: Constants
    
    let timeLineCellViewIdentifier = "TL"
    let eventIconCellViewIdentifier = "EI"
    
    //MARK: Outlets
    
    @IBOutlet var templateBuilder : PSTemplateBuilder!
    @IBOutlet var zoomButtons : NSSegmentedControl!
    @IBOutlet var eventIconTableView : NSTableView!
    @IBOutlet var timeLineTableView : NSTableView!
    @IBOutlet var timeLineTableViewClipView : NSView!
    @IBOutlet var timeLineTableViewScrollView : NSScrollView!
    @IBOutlet var eventHeadingTableViewScrollView : NSScrollView!
    @IBOutlet var timeLineTableViewColumn : NSTableColumn!
    
    //MARK: Other non event/template related objects
    
    var scriptData : PSScriptData!
    var selectionInterface : PSSelectionInterface!
    var rulerView : NSRulerView!
    var overlayView : NSFlippedView! //this view goes over the timeline table view, and draws lines connecteing etc
    var initialized : Bool = false
    
    
    //MARK: Current selection
    
    var templateObject : LayoutObject!
    var selectedEvent : LayoutObject!
    
    var layoutObjects : [LayoutObject] = []
    var events : [PSTemplateEvent] = []
    var eventsAttribute : PSStringList!
    var linkLines : [CALayer] = []
    var writingRow : Int? = nil
    var zoomMultiplier : CGFloat = 1
    
    
    //MARK: Setup
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if (!initialized) {
            initialized = true
            let nib = NSNib(nibNamed: "TemplateEventIconCell", bundle: NSBundle(forClass:self.dynamicType))
            eventIconTableView.registerNib(nib!, forIdentifier: eventIconCellViewIdentifier)
            let nib2 = NSNib(nibNamed: "TemplateTimeLineCell", bundle: NSBundle(forClass:self.dynamicType))
            timeLineTableView.registerNib(nib2!, forIdentifier: timeLineCellViewIdentifier)
            
            eventIconTableView.registerForDraggedTypes([PSConstants.PSEventBrowserView.dragType, PSConstants.PSEventBrowserView.pasteboardType,"psyscope.pstemplateevent"])
            timeLineTableView.registerForDraggedTypes([PSConstants.PSEventBrowserView.dragType, PSConstants.PSEventBrowserView.pasteboardType,"psyscope.pstemplateevent"])
            
            overlayView = NSFlippedView(frame: timeLineTableView.frame)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "tableFrameSizeChange:", name: NSViewFrameDidChangeNotification, object: timeLineTableView)
            overlayView.layer = CALayer()
            overlayView.wantsLayer = true
            
            //setup up nsrulerview
            timeLineTableViewScrollView.hasHorizontalRuler = true;
            timeLineTableViewScrollView.rulersVisible = true;

            
   
            
            if let horizontalRulerView = timeLineTableViewScrollView.horizontalRulerView {
                rulerView = horizontalRulerView
            }
            
            //rulerView = NSRulerView(scrollView: timeLineTableViewScrollView, orientation: NSRulerOrientation.HorizontalRuler)
            
            timeLineTableView.superview!.addSubview(overlayView)
        }
    }
    
    //MARK: Selected event / template
    
    func isTemplateEntry(entry : Entry) -> Bool {
        if let _ = scriptData.getSubEntry("Events", entry: entry) {
            return true
        }
        
        if entry.type == "Template" {
            return true
        }
        
        return false
    }
    
    //MARK: Refreshing methods
    
    func refresh() {
        
        defer { fullRefresh() }
        
        if let e = selectionInterface.getSelectedEntry(), lobject = e.layoutObject {
            if scriptData.typeIsEvent(e.type) {
                let parentLinks = Array(e.layoutObject.parentLink as! Set<LayoutObject>)
                
                //check if current templateEntry is in parentLinks
                if templateObject != nil && parentLinks.contains(templateObject) {
                    //already showing template, just select the right entry
                    selectedEvent = lobject
                    return
                } else {
                    //select one of the parent templates (check it is a template)
                    for parent in parentLinks {
                        if isTemplateEntry(parent.mainEntry) {
                            templateObject = parent
                            selectedEvent = lobject
                            return
                        }
                    }
                }
            } else if isTemplateEntry(e) {
                templateObject = lobject
                selectedEvent = nil
                return
            }
        }
        
        //unknown object type / no template so clear the screen
        templateObject = nil
        selectedEvent = nil
    }
    
    func fullRefresh() {
        //reset arrays containing events and layout objects
        layoutObjects = []
        events = []
        
        //get existing objects and create them
        if templateObject != nil && templateObject.mainEntry != nil {
            let lobjects = templateObject.childLink.array as! [LayoutObject]
            
            for lobject in lobjects {
                addEventToListIfValid(lobject)
            }
        }
        
        refreshTimeLineTableViews()
    }
    
    func refreshTimeLineTableViews() {
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        //now update all the objects
        for event in events {
            PSEventStringParser.parseForTemplateLayoutBoardEvent(event, events: events)
        }
        
        //make sure they are sorted correctly
        if events.count > 0 {
            if let events_attribute = scriptData.getSubEntry("Events", entry: templateObject.mainEntry) {
                self.eventsAttribute = PSStringList(entry: events_attribute, scriptData: scriptData)
                var sorted : [PSTemplateEvent] = []
                for name in eventsAttribute.stringListLiteralsOnly {
                    for ev in events {
                        if ev.entry.name == name {
                            sorted.append(ev)
                            break
                        }
                    }
                }
                events = sorted
                
            } else {
                fatalError("Internal inconsistency: child links on layoutobjects do not match list in main template entry")
            }
        }
        
        
        
        
        //get the width for the time line table view - which will be the the maximum from the frames width and the length of the longest event (plus some leeway)
        var minimumframeWidth : CGFloat = 0
        
        //store eventTimes for later use, whilst getting longest one
        var eventTimes : [PSTemplateEvent : (start: EventMSecs, duration : EventMSecs)] = [:]
        for (_,event) in events.enumerate() {
            let (start, duration) = event.getMS()
            eventTimes[event] = (start,duration)
            let width = start + duration
            
            minimumframeWidth = max(width, minimumframeWidth)
        }
        
        //adjust for zoom and add some leeway
        minimumframeWidth *= zoomMultiplier
        minimumframeWidth += 150
        
        //ensure at least as wide as frame
        minimumframeWidth = max(timeLineTableViewScrollView.frame.size.width, minimumframeWidth)
        
        //set the width
        var timeLineTableViewFrame = timeLineTableView.frame
        timeLineTableViewFrame.size.width = minimumframeWidth
        timeLineTableView.frame = timeLineTableViewFrame
        timeLineTableViewColumn.minWidth = minimumframeWidth
        timeLineTableViewColumn.maxWidth = minimumframeWidth
        
        
        //trigger the reloading of the events.
        eventIconTableView.reloadData()
        timeLineTableView.reloadData()
        
        //get y locations for each cell (to calculate connecting lines well)
        var cellYLocations : [PSTemplateEvent : CGFloat] = [:]
        for (index,event) in events.enumerate() {
            let cellFrame = timeLineTableView.frameOfCellAtColumn(0, row: index)
            cellYLocations[event] = cellFrame.origin.y + (cellFrame.height / 2)
        }
        
        //now update lines (first removing old ones)
        for ll in linkLines {
            ll.removeFromSuperlayer()
        }
        linkLines = []
        //for each event determine if it relies on another ending or starting
        for event in events {
            
            if let sc = event.startCondition as? EventStartEventRelated {
                
                let starting_event = sc.event!
                let (start, duration) = eventTimes[starting_event]!
                
                var start_x = sc.position == EventStartEventRelatedPosition.End ? start + duration : start
                
                start_x++ //seems to be offset of one required
                let start_point = CGPoint(x: start_x * zoomMultiplier, y: cellYLocations[starting_event]!)
                var (end, _) = eventTimes[event]!
                end++ //ditto
                let end_point = CGPoint(x: end * zoomMultiplier, y: cellYLocations[event]!)
                
                for line in makeLineLinkLayer(start_point, to: end_point) {
                    
                    linkLines.append(line)
                    overlayView.layer!.addSublayer(line)
                }
            } else if let _ = event.startCondition as? EventStartConditionTrialStart {
                let (start, _) = eventTimes[event]!
                let line = makeLineLayer(CGPoint(x: 0, y: cellYLocations[event]!), to: CGPoint(x: start, y:cellYLocations[event]!))
                line.lineDashPattern = nil
                line.lineWidth = 2
                overlayView.layer!.addSublayer(line)
                linkLines.append(line)
            }
        }
        
        //add scale to timeline
        /*
        let startPoint = CGPoint(x: 0, y: 10)
        let endPoint = CGPoint(x: minimumframeWidth, y: 10)
        let scaleLine = makeLineLayer(startPoint, to: endPoint)
        overlayView.layer!.addSublayer(scaleLine)*/
        
        
        //update nsrulerview
        NSRulerView.registerUnitWithName("Milliseconds", abbreviation: "ms", unitToPointsConversionFactor: zoomMultiplier, stepUpCycle: [10], stepDownCycle: [0.5])
        rulerView.measurementUnits = "Milliseconds"
        CATransaction.commit()
        refreshVisualSelection()
    }
    
    
    func refreshVisualSelection() {
        if selectedEvent != nil && selectedEvent.mainEntry != nil {
            //select the correct row
            for (index,event) in events.enumerate() {
                if event.entry == selectedEvent.mainEntry {
                    timeLineTableView.selectRowIndexes(NSIndexSet(index: index), byExtendingSelection: false)
                    eventIconTableView.selectRowIndexes(NSIndexSet(index: index), byExtendingSelection: false)
                    break
                }
            }
        }
    }
    
    //MARK: Adding events
    
    //adds to event list, if not already in the list, and is a member of the template
    func addEventToListIfValid(lobject : LayoutObject) {
        if !layoutObjects.contains(lobject) {
            //event is not in list
            let isEventAndOnThisTemplate = scriptData.isEventAndOnThisTemplate(lobject, templateObject: templateObject)
            if  isEventAndOnThisTemplate && lobject.mainEntry != nil {
                
                //event is on template
                layoutObjects.append(lobject)
                events.append(PSTemplateEvent(entry: lobject.mainEntry, scriptData: scriptData))
            }   
        }
    }
    
    //MARK: Table view methods
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return events.count
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if events.count == 0 {
            return NSView()
        }
        
        switch (tableView) {
        case eventIconTableView:
            let view = eventIconTableView.makeViewWithIdentifier(eventIconCellViewIdentifier, owner: self) as! PSEventTableCellView
            view.deleteAction = {(event : PSTemplateEvent) -> () in
                let objToDelete = event.entry.layoutObject
                //select another object from this template
                var objToSelect : LayoutObject? = nil
                for lo in self.layoutObjects {
                    if lo != objToDelete {
                        objToSelect = lo
                        break
                    }
                }
                
                //if not valid objects, then select the template
                if objToSelect == nil {
                    objToSelect = self.templateObject
                }
                self.selectionInterface.deleteObject(objToDelete, andSelect: objToSelect!.mainEntry)
            }
            return view
        case timeLineTableView:
            let view = timeLineTableView.makeViewWithIdentifier(timeLineCellViewIdentifier, owner: self) as! PSTemplateEventTimeLineView
            view.zoomMultiplier = zoomMultiplier
            view.tableView = timeLineTableView
            return view
        default:
            return NSView()
        }
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        return events[row]
    }
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat { return PSDefaultConstants.Spacing.TLBtimeBarViewHeight }
    
    func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        //tableViewSelectionIsChanging?
        if row >= 0 && row < events.count {
            selectionInterface.selectEntry(events[row].entry)
        
            switch (tableView) {
            case eventIconTableView:
                timeLineTableView.selectRowIndexes(NSIndexSet(index: row), byExtendingSelection: false)
                break
            case timeLineTableView:
                eventIconTableView.selectRowIndexes(NSIndexSet(index: row), byExtendingSelection: false)
                break
            default:
                break
            }
        } else {
            timeLineTableView.deselectAll(self)
            eventIconTableView.deselectAll(self)
        }
        
        
        
        return true
    }
    
    func tableView(tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let rowView = PSTemplateTableRowView()
        return rowView
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        timeLineTableView.enumerateAvailableRowViewsUsingBlock({
            (rowView : NSTableRowView!, row : Int) -> () in
            _ = rowView.viewAtColumn(0) as! NSView
            if (rowView.selected) {
                //do custom emphasis here (
            } else {
                //go to normal
            }
        })
    }
    
    //MARK: Table view dragging
    
    func tableView(tableView: NSTableView, draggingSession session: NSDraggingSession, willBeginAtPoint screenPoint: NSPoint, forRowIndexes rowIndexes: NSIndexSet) {
        tableView.draggingDestinationFeedbackStyle = NSTableViewDraggingDestinationFeedbackStyle.Gap
    }
    
    func tableView(tableView: NSTableView, draggingSession session: NSDraggingSession, endedAtPoint screenPoint: NSPoint, operation: NSDragOperation) {
        writingRow = nil
    }
   
    func tableView(tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
        
        //only allow in between
        if dropOperation == NSTableViewDropOperation.On {
            return false
        }
        
        //access plugin
        if templateObject != nil {
            
            //is this a new tool, or a reorder drag?
            let pasteboard = info.draggingPasteboard()
            
            for p in pasteboard.types! {
                if let q = p as? String {
                    if q == PSConstants.PSEventBrowserView.pasteboardType {
                        scriptData.beginUndoGrouping("Add New Object")
                        var success = false
                        let type = pasteboard.stringForType(PSConstants.PSEventBrowserView.pasteboardType)!
                        if let new_entry = scriptData.createNewEventFromTool(type, templateObject: templateObject,order: row) {
                            success = true
                            selectionInterface.selectEntry(new_entry)
                        }
                        scriptData.endUndoGrouping(success)
                        
                        return success
                    } else if q == "psyscope.pstemplateevent" {
                        scriptData.beginUndoGrouping("Move Event")
                        let success = true
                        if let fromRow = writingRow {
                            //drag was within same tableview
                            scriptData.moveEvent(templateObject.mainEntry, fromIndex: fromRow, toIndex: row)
                            
                        } else {
                        
                            //delete writingRow
                            
                            
                            
                            //instantiate new event
                            let new_events = pasteboard.readObjectsForClasses([PSTemplateEvent.self], options: [:]) as! [PSTemplateEvent]
                            for e in new_events {
                                e.unarchiveData(scriptData)
                                events.append(e)
                                layoutObjects.append(e.entry.layoutObject)
                                //link to template in correct place
                                scriptData.createLinkFrom(templateObject.mainEntry, to: e.entry, withAttribute: "Events")
                                scriptData.moveEvent(templateObject.mainEntry, fromIndex: events.count - 1, toIndex: row)
                            }
                            
                            
                        }
                        writingRow = nil
                        scriptData.endUndoGrouping(success)
                        return true
                    }
                }
            }
            
            PSModalAlert("Error accepting drag type...")
            return false
        } else {
            PSModalAlert("You cannot add an event, as there is no template to add it to.")
            return false
        }
    }
    
    
    
    
    
    func tableView(tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        //return nil of no dragging allowed
        if tableView == eventIconTableView {
            writingRow = row
            return events[row]
        } else {
            return nil
        }
    }
    
    func tableView(tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableViewDropOperation) -> NSDragOperation {
        info.animatesToDestination = true
        
        var operation = NSDragOperation.None
        //only allow in between
        if dropOperation == NSTableViewDropOperation.On || tableView == timeLineTableView {
            return operation
        }
        
        //is this a new tool, or a reorder drag?
        
        
        if templateObject != nil {
            let pasteboard = info.draggingPasteboard()
            for p in pasteboard.types! {
                if let q = p as? String {
                    if q == PSConstants.PSEventBrowserView.pasteboardType {
                        operation = NSDragOperation.Link
                    } else if q == "psyscope.pstemplateevent" {
                        operation = NSDragOperation.Move
                    }
                }
            }
        }
        
        return operation
    }
    
    //MARK: Overlay view
    // Transparent view on which connecting lines are drawn
    // automatically resize overlayView when timeLineTableView size is changed
    func tableFrameSizeChange(sender : AnyObject) {
        overlayView.frame = timeLineTableView.frame
    }
    
    //MARK: Overlay view drawing
    
    func makeLineLayer(lineFrom: CGPoint, to: CGPoint) -> CAShapeLayer {
        let line = CAShapeLayer()
        let linePath = CGPathCreateMutable()
        CGPathMoveToPoint(linePath, nil, lineFrom.x, lineFrom.y)
        CGPathAddLineToPoint(linePath, nil, to.x, to.y)
        CGPathCloseSubpath(linePath)
        
        line.path = linePath
        line.fillColor = NSColor.redColor().CGColor
        line.opacity = 0.5
        line.strokeColor = NSColor.redColor().CGColor
        line.lineCap = kCALineCapRound
        return line
    }
    
    func makeLineLinkLayer(lineFrom: CGPoint, to: CGPoint) -> [CAShapeLayer] {
        //makes a CAShapeLayer containing an L
        var lines : [CAShapeLayer] = []
        
        //dashed line
        let line = makeLineLayer(lineFrom, to: CGPoint(x: lineFrom.x, y: to.y))
        line.lineDashPattern =  [3,3]
        line.lineWidth = 1
        lines.append(line)
        
        
        //solid line
        let line2 = makeLineLayer(CGPoint(x: lineFrom.x, y: to.y), to: to)
        line2.lineDashPattern = nil
        line2.lineWidth = 1
        lines.append(line2)
       
        return lines
    }

    //MARK: Zooming
    
    @IBAction func zoomButtonSelect(sender : AnyObject) {
        switch (zoomButtons.selectedSegment) {
        case 0:
            self.zoomMultiplier *= 2
            self.zoomMultiplier = min(self.zoomMultiplier, 16)
            break
        case 1:
            self.zoomMultiplier /= 2
            self.zoomMultiplier = max(self.zoomMultiplier, 0.125)
            break
        default:
            return
        }
        fullRefresh()
    }
    
}
