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
    var errorLabel : NSTextField? //view to rpesent errors on the overlay (if impossible processing template possibly due to custom code)
    var initialized : Bool = false
    var errorList : [String] = []
    
    
    //MARK: Current selection
    
    var templateObject : LayoutObject!
    var selectedEvent : LayoutObject!
    
    var events : [PSTemplateEvent] = []
    var eventsAttribute : PSStringList!
    var linkLines : [CALayer] = []
    var writingRow : Int? = nil
    var zoomMultiplier : CGFloat = 1
    var errorsPresent : Bool = false
    
    //MARK: Setup
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if (!initialized) {
            initialized = true
            let nib = NSNib(nibNamed: "TemplateEventIconCell", bundle: Bundle(for:type(of: self)))
            eventIconTableView.register(nib!, forIdentifier: convertToNSUserInterfaceItemIdentifier(eventIconCellViewIdentifier))
            let nib2 = NSNib(nibNamed: "TemplateTimeLineCell", bundle: Bundle(for:type(of: self)))
            timeLineTableView.register(nib2!, forIdentifier: convertToNSUserInterfaceItemIdentifier(timeLineCellViewIdentifier))
            
            eventIconTableView.registerForDraggedTypes(convertToNSPasteboardPasteboardTypeArray([PSConstants.PSEventBrowserView.dragType, PSConstants.PSEventBrowserView.pasteboardType,"psyscope.pstemplateevent"]))
            timeLineTableView.registerForDraggedTypes(convertToNSPasteboardPasteboardTypeArray([PSConstants.PSEventBrowserView.dragType, PSConstants.PSEventBrowserView.pasteboardType,"psyscope.pstemplateevent"]))
            
            overlayView = NSFlippedView(frame: timeLineTableView.frame)
            NotificationCenter.default.addObserver(self, selector: #selector(PSTemplateLayoutBoardController.tableFrameSizeChange(_:)), name: NSView.frameDidChangeNotification, object: timeLineTableView)
            overlayView.layer = CALayer()
            overlayView.wantsLayer = true
            
            //setup up nsrulerview
            timeLineTableViewScrollView.hasHorizontalRuler = true;
            timeLineTableViewScrollView.rulersVisible = true;

        
            if let horizontalRulerView = timeLineTableViewScrollView.horizontalRulerView {
                rulerView = horizontalRulerView
            }
            
            timeLineTableView.superview!.addSubview(overlayView)
        }
    }
    
    //MARK: Selected event / template
    
    func isTemplateEntry(_ entry : Entry) -> Bool {
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
        
        //This code selects the appropriate templte for the selected entry
        if let e = selectionInterface.getSelectedEntry(), let lobject = e.layoutObject {
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
        errorsPresent = false
        errorList = []
        events = []
        
        defer { refreshTimeLineTableViews() }
        
        //get list of events
        guard let templateObject = templateObject, let templateEntry = templateObject.mainEntry else {
            addError("No template object selected.")
            return }
        
        let eventsEntry = scriptData.getOrCreateSubEntry("Events", entry: templateEntry, isProperty: true)
        
        let parser = PSEntryValueParser(stringValue: eventsEntry.currentValue)
        
        if parser.foundErrors {
            addError("There were errors found in the Events: attribute for this template")
            return
        }
        
        let eventValues : [PSEntryElement] = parser.values
        
        for event in eventValues {
            addEventToListIfValid(event)
        }
        
        
    }
    
    
    
    func addError(_ stringReason: String) {
        errorsPresent = true
        errorList.append(stringReason)
        print(stringReason)
    }
    
    func refreshTimeLineTableViews() {
        
        //remove error label
        if let errorLabel = errorLabel {
            errorLabel.removeFromSuperview()
            self.errorLabel = nil
        }
        
        if errorsPresent {
            events = []
            //trigger the reloading of the events.
            eventIconTableView.reloadData()
            timeLineTableView.reloadData()
            
            
            //add errorlabel
            let newErrorLabel = NSTextField()
            overlayView.addSubview(newErrorLabel)
            newErrorLabel.stringValue = errorList.joined(separator: "\n")
            newErrorLabel.frame = overlayView.bounds
            newErrorLabel.isBezeled = false
            errorLabel = newErrorLabel
            return
        }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        

        //now update all the objects
        for event in events {
            PSEventStringParser.parseForTemplateLayoutBoardEvent(event, events: events)
        }
    
        
        
        
        
        //get the width for the time line table view - which will be the the maximum from the frames width and the length of the longest event (plus some leeway)
        var minimumframeWidth : CGFloat = 0
        
        //store eventTimes for later use, whilst getting longest one
        var eventTimes : [PSTemplateEvent : (start: EventMSecs, duration : EventMSecs)] = [:]
        for (_,event) in events.enumerated() {
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
        for (index,event) in events.enumerated() {
            let cellFrame = timeLineTableView.frameOfCell(atColumn: 0, row: index)
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
                
                if let starting_event = sc.event {
                    let (start, duration) = eventTimes[starting_event]!
                    
                    var start_x = sc.position == EventStartEventRelatedPosition.end ? start + duration : start
                    
                    start_x += 1 //seems to be offset of one required
                    let start_point = CGPoint(x: start_x * zoomMultiplier, y: cellYLocations[starting_event]!)
                    var (end, _) = eventTimes[event]!
                    end += 1 //ditto
                    let end_point = CGPoint(x: end * zoomMultiplier, y: cellYLocations[event]!)
                    
                    for line in makeLineLinkLayer(start_point, to: end_point) {
                        
                        linkLines.append(line)
                        overlayView.layer!.addSublayer(line)
                    }
                } else {
                    let (start, _) = eventTimes[event]!
                    let line = makeLineLayer(CGPoint(x: 0, y: cellYLocations[event]!), to: CGPoint(x: start, y:cellYLocations[event]!))
                    line.lineDashPattern = nil
                    line.lineWidth = 2
                    overlayView.layer!.addSublayer(line)
                    linkLines.append(line)
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
        
        
        //update nsrulerview
        NSRulerView.registerUnit(withName: convertToNSRulerViewUnitName("Milliseconds"), abbreviation: "ms", unitToPointsConversionFactor: zoomMultiplier, stepUpCycle: [10], stepDownCycle: [0.5])
        rulerView.measurementUnits = convertToNSRulerViewUnitName("Milliseconds")
        CATransaction.commit()
        refreshVisualSelection()
    }
    
    
    func refreshVisualSelection() {
        if selectedEvent != nil && selectedEvent.mainEntry != nil {
            //select the correct row
            for (index,event) in events.enumerated() {
                if event.entry == selectedEvent.mainEntry {
                    timeLineTableView.selectRowIndexes(IndexSet(integer: index), byExtendingSelection: false)
                    eventIconTableView.selectRowIndexes(IndexSet(integer: index), byExtendingSelection: false)
                    break
                }
            }
        }
    }
    
    //MARK: Adding events
    
    //adds to event list, if not already in the list, and is a member of the template
    func addEventToListIfValid(_ event : PSEntryElement) {
        
        switch (event) {
        case .null:
            addError("You cannot have NULL events in Events: attribute.")
            return
        case .function(let functionElement):
            if functionElement.bracketType != .expression ||
                functionElement.values.count != 3 ||
                functionElement.values[1].stringValue() != "~" {
                addError("The template editor cannot parse templates with expressions / functions beyond the ~ operator")
                return
            }
            
            let eventName = functionElement.values[2].stringValue()
            
            guard let repeats = Int(PSFunctionEvaluate(functionElement.values[0], scriptData: scriptData)) else {
                addError("The template editor cannot parse templates with expressions / functions beyond the ~ operator (with just numbers or references to an entry with a number")
                return
            }
            
            if let entry = scriptData.getBaseEntry(eventName) {
                //check there is no start ref
                if scriptData.getSubEntry("StartRef", entry: entry) != nil {
                    addError("The Entry '\(eventName)' is referenced by a tilde in the Events attribute, but it also has a StartRef attribute, meaning it will lead to unpredictable behaviour.")
                    return
                }
                
                events.append(PSTemplateEvent(entry: entry, scriptData: scriptData, repeats: repeats))
            } else {
                addError("Either the entry '\(eventName)' in the Events Attribute cannot be found, or it is a expression that cannot be interpreted by the template editor.")
                return
            }
            
            break
        case .list:
            addError("You cannot have sub lists in Events: attribute.")
            return
        case .stringToken(let stringElement):
            
            let entryName = stringElement.value
            if let entry = scriptData.getBaseEntry(entryName) {
                events.append(PSTemplateEvent(entry: entry, scriptData: scriptData, repeats: 1))
            } else {
                addError("The entry '\(entryName)' in the Events Attribute cannot be found.")
                return
            }
            
            break
        }
    }
    
    //MARK: Table view methods
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if events.count == 0 {
            return NSView()
        }
        
        switch (tableView) {
        case eventIconTableView:
            let view = eventIconTableView.makeView(withIdentifier: convertToNSUserInterfaceItemIdentifier(eventIconCellViewIdentifier), owner: self) as! PSEventTableCellView
            view.deleteAction = {(event : PSTemplateEvent) -> () in
                let objToDelete = event.entry.layoutObject
                //select another object from this template
                var objToSelect : LayoutObject? = nil
                for otherEvent in self.events {
                    if otherEvent.entry.layoutObject != objToDelete {
                        objToSelect = otherEvent.entry.layoutObject
                        break
                    }
                }
                
                //if not valid objects, then select the template
                if objToSelect == nil {
                    objToSelect = self.templateObject
                }
                self.selectionInterface.deleteObject(objToDelete!, andSelect: objToSelect!.mainEntry)
            }
            return view
        case timeLineTableView:
            let view = timeLineTableView.makeView(withIdentifier: convertToNSUserInterfaceItemIdentifier(timeLineCellViewIdentifier), owner: self) as! PSTemplateEventTimeLineView
            view.zoomMultiplier = zoomMultiplier
            view.tableView = timeLineTableView
            return view
        default:
            return NSView()
        }
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return events[row]
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat { return PSDefaultConstants.Spacing.TLBtimeBarViewHeight }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        //tableViewSelectionIsChanging?
        if row >= 0 && row < events.count {
            selectionInterface.selectEntry(events[row].entry)
        
            switch (tableView) {
            case eventIconTableView:
                timeLineTableView.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
                break
            case timeLineTableView:
                eventIconTableView.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
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
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let rowView = PSTemplateTableRowView()
        return rowView
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        timeLineTableView.enumerateAvailableRowViews({
            (rowView : NSTableRowView!, row : Int) -> () in
            _ = rowView.view(atColumn: 0) as! NSView
            if (rowView.isSelected) {
                //do custom emphasis here (
            } else {
                //go to normal
            }
        })
    }
    
    //MARK: Table view dragging
    
    func tableView(_ tableView: NSTableView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forRowIndexes rowIndexes: IndexSet) {
        tableView.draggingDestinationFeedbackStyle = NSTableView.DraggingDestinationFeedbackStyle.gap
    }
    
    func tableView(_ tableView: NSTableView, draggingSession session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
        writingRow = nil
    }
   
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
        
        //only allow in between
        if dropOperation == NSTableView.DropOperation.on {
            return false
        }
        
        //access plugin
        if templateObject != nil {
            
            //is this a new tool, or a reorder drag?
            let pasteboard = info.draggingPasteboard
            
            for q in convertFromOptionalNSPasteboardPasteboardTypeArray(pasteboard.types)! {
                if q == PSConstants.PSEventBrowserView.pasteboardType {
                    scriptData.beginUndoGrouping("Add New Object")
                    var success = false
                    let type = pasteboard.string(forType: convertToNSPasteboardPasteboardType(PSConstants.PSEventBrowserView.pasteboardType))!
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
                        let new_events = pasteboard.readObjects(forClasses: [PSTemplateEvent.self], options: convertToOptionalNSPasteboardReadingOptionKeyDictionary([:])) as! [PSTemplateEvent]
                        for e in new_events {
                            e.unarchiveData(scriptData)
                            events.append(e)
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
            
            PSModalAlert("Error accepting drag type...")
            return false
        } else {
            PSModalAlert("You cannot add an event, as there is no template to add it to.")
            return false
        }
    }
    
    
    
    
    
    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        //return nil of no dragging allowed
        if tableView == eventIconTableView {
            writingRow = row
            return events[row]
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        info.animatesToDestination = true
        
        var operation = NSDragOperation()
        //only allow in between
        if dropOperation == NSTableView.DropOperation.on || tableView == timeLineTableView {
            return operation
        }
        
        //is this a new tool, or a reorder drag?
        if templateObject != nil {
            let pasteboard = info.draggingPasteboard
            for q in convertFromOptionalNSPasteboardPasteboardTypeArray(pasteboard.types)! {
                if q == PSConstants.PSEventBrowserView.pasteboardType {
                    operation = NSDragOperation.link
                } else if q == "psyscope.pstemplateevent" {
                    operation = NSDragOperation.move
                }
            }
        }
        
        return operation
    }
    
    //MARK: Overlay view
    // Transparent view on which connecting lines are drawn
    // automatically resize overlayView when timeLineTableView size is changed
    @objc func tableFrameSizeChange(_ sender : AnyObject) {
        overlayView.frame = timeLineTableView.frame
    }
    
    //MARK: Overlay view drawing
    
    func makeLineLayer(_ lineFrom: CGPoint, to: CGPoint) -> CAShapeLayer {
        let line = CAShapeLayer()
        let linePath = CGMutablePath()
        linePath.move(to: lineFrom)
        linePath.addLine(to: to)
        linePath.closeSubpath()
        
        line.path = linePath
        line.fillColor = NSColor.red.cgColor
        line.opacity = 0.5
        line.strokeColor = NSColor.red.cgColor
        line.lineCap = CAShapeLayerLineCap.round
        return line
    }
    
    func makeLineLinkLayer(_ lineFrom: CGPoint, to: CGPoint) -> [CAShapeLayer] {
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
    
    @IBAction func zoomButtonSelect(_ sender : AnyObject) {
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSUserInterfaceItemIdentifier(_ input: String) -> NSUserInterfaceItemIdentifier {
	return NSUserInterfaceItemIdentifier(rawValue: input)
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSPasteboardPasteboardTypeArray(_ input: [String]) -> [NSPasteboard.PasteboardType] {
	return input.map { key in NSPasteboard.PasteboardType(key) }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSRulerViewUnitName(_ input: String) -> NSRulerView.UnitName {
	return NSRulerView.UnitName(rawValue: input)
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromOptionalNSPasteboardPasteboardTypeArray(_ input: [NSPasteboard.PasteboardType]?) -> [String]? {
	guard let input = input else { return nil }
	return input.map { key in key.rawValue }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSPasteboardPasteboardType(_ input: String) -> NSPasteboard.PasteboardType {
	return NSPasteboard.PasteboardType(rawValue: input)
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSPasteboardReadingOptionKeyDictionary(_ input: [String: Any]?) -> [NSPasteboard.ReadingOptionKey: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSPasteboard.ReadingOptionKey(rawValue: key), value)})
}
