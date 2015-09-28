//
//  PSLayoutBoard.swift
//  PsyScopeEditor
//
//  NSView subclass that represents the layout of the experiment in the main window

import Swift
import Cocoa
import QuartzCore

struct ClickedObjectInfo {
    var clickedLayoutItem : PSLayoutItem = PSLayoutItem()
    var mouseDownPoint : NSPoint = NSPoint()
    var originalPosition : NSPoint = NSPoint()
}

public class Link : Equatable {
    var startLayoutItem : PSLayoutItem
    var destLayoutItem : PSLayoutItem
    var lineLayer : CAShapeLayer
    init(startLayoutItem: PSLayoutItem, destLayoutItem: PSLayoutItem, lineLayer: CAShapeLayer) {
        self.startLayoutItem = startLayoutItem
        self.destLayoutItem = destLayoutItem
        self.lineLayer = lineLayer
    }
}

public func ==(lhs: Link, rhs: Link) -> Bool {
    let r = (lhs.startLayoutItem == rhs.startLayoutItem) && (lhs.destLayoutItem == rhs.destLayoutItem) && (lhs.lineLayer == rhs.lineLayer)
    return r
}


enum ContextMenuObject {
    case SelectedObject(PSLayoutItem)
    case MultipleObjects([PSLayoutItem])
    case SelectedLink(Link)
}

class PSLayoutBoard: NSView {

    let cleanMenuItemTag : Int = 1
    let deleteMenuItemTag : Int = 2
    let linkMenuItemTag : Int = 3
    
    @IBOutlet var statusBar : NSTextField!
    @IBOutlet var layoutController : LayoutController!
    @IBOutlet var actionPopup : NSPopUpButton!
    @IBOutlet var contextMenu : NSMenu!
    @IBOutlet var scrollView : NSScrollView!
    @IBOutlet var mainWindow : NSWindow!
    
    var layoutItems : [PSLayoutItem] = []
    var linkLayers: [CALayer] = []
    var objectLinks : [Link] = []
    
    var clickedObject : ClickedObjectInfo? = nil
    var contextMenuObject : ContextMenuObject? = nil
    
    var dragSelectionPoint : NSPoint = NSPoint()
    var dragBoxLayer : CAShapeLayer! = nil
    var draggingSelection : Bool = false

    var linkingObjects : [PSLayoutItem]? //if linking to objects, stores the first selected objects
    
    let draggedTypes : [String] = [PSConstants.PSToolBrowserView.dragType, PSConstants.PSToolBrowserView.pasteboardType,PSConstants.PSEventBrowserView.dragType, PSConstants.PSEventBrowserView.pasteboardType,NSFilenamesPboardType]
    
    func prepareMainLayer() {
        self.registerForDraggedTypes(draggedTypes)
        self.layer = CALayer()
        self.wantsLayer = true
        self.layer!.backgroundColor = PSConstants.BasicDefaultColors.backgroundColor
        self.layer!.zPosition = 0
        self.layer!.contentsScale = self.mainWindow.backingScaleFactor
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateContextMenuItems:", name: NSPopUpButtonWillPopUpNotification, object: actionPopup)


        for item in contextMenu.itemArray as [NSMenuItem] {
            actionPopup.menu?.addItem(item.copy() as! NSMenuItem)
        }
    }
    
    override func resetCursorRects() {
        if linkingObjects != nil {
            self.addCursorRect(self.bounds, cursor: NSCursor.crosshairCursor())
        } else {
            super.resetCursorRects()
        }
    }
    
    override var flipped : Bool { get { return true } }
    
    var currentDragOperation : NSDragOperation? = nil

    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        let pasteboard = sender.draggingPasteboard()
        currentDragOperation = NSDragOperation.Link

        if let type = pasteboard.availableTypeFromArray(draggedTypes) {
            if type == NSFilenamesPboardType {
                currentDragOperation = NSDragOperation.Copy
            }
        }
        return currentDragOperation!
    }
    
    override func draggingUpdated(sender: NSDraggingInfo) -> NSDragOperation {
        return currentDragOperation!
    }
    
    var filesToImport : [String : [PSToolInterface]] = [:]
    
    override func prepareForDragOperation(sender: NSDraggingInfo) -> Bool {
        //check if file is of a good type
        filesToImport = [:]
        let pasteboard = sender.draggingPasteboard()
        if pasteboard.stringForType(PSConstants.PSToolBrowserView.pasteboardType) != nil {
            return true
        } else if pasteboard.stringForType(PSConstants.PSEventBrowserView.pasteboardType) != nil {
            return true
        } else if let filenames : [AnyObject] = pasteboard.propertyListForType(NSFilenamesPboardType) as? [AnyObject] {
            var valid_files = true
            for filename in filenames {
                if let fn = filename as? String, absPath = NSURL(fileURLWithPath: fn).path {
                    //check for type
            
                    if let types = layoutController.toolTypesForPath(fn) {
                        filesToImport[absPath] = types
                    } else {
                        valid_files = false
                    }
                } else {
                    valid_files = false
                    break
                }
            }
            return valid_files
        }
        return false
    }
    
    
    
    
    override func performDragOperation(sender: NSDraggingInfo) -> Bool {
        let location = self.convertPoint(sender.draggingLocation(),fromView: nil)
        let pasteboard = sender.draggingPasteboard()
        window!.makeFirstResponder(self)
        if let type = pasteboard.stringForType(PSConstants.PSToolBrowserView.pasteboardType) {
            layoutController.draggedNewTool(type, location: location)
            return true
        } else if let type = pasteboard.stringForType(PSConstants.PSEventBrowserView.pasteboardType) {
            layoutController.draggedNewTool(type, location: location)
            return true
        } else if filesToImport.count > 0 {
            return layoutController.draggedFiles(filesToImport, location: location)
        }
        return false
    }

    
    
    override func wantsPeriodicDraggingUpdates() -> Bool { return true }
    
    override func mouseDown(theEvent: NSEvent) {
        //mouseDown can drag existing layoutItems or be the end of a link operation
        let click_point = self.convertPoint(theEvent.locationInWindow, fromView: nil)
        let hit_layoutItem = hitLayoutItem(NSPointToCGPoint(click_point))
        
        self.clickedObject = nil
        self.draggingSelection = false
        
        
        if let l = hit_layoutItem {
            if let objects = linkingObjects {
                for object in objects {
                    layoutController.linkObjects(object, destLayoutItem: l)
                }
            }
            else {
                clickedObject = ClickedObjectInfo(clickedLayoutItem: l, mouseDownPoint: theEvent.locationInWindow, originalPosition: l.icon.position)
            }
        } else {
            //deselect object
            layoutController.deSelect()
            
            //start dragging new selection 
            unDragSelectLayoutItems()
            self.dragSelectionPoint = click_point
            
            // create and configure shape layoutItem
            self.dragBoxLayer = CAShapeLayer()
            self.dragBoxLayer.lineWidth = 1.0;
            self.dragBoxLayer.strokeColor = NSColor.blackColor().CGColor
            self.dragBoxLayer.fillColor = NSColor.clearColor().CGColor
            self.dragBoxLayer.lineDashPattern = [10, 5]
            self.layer!.addSublayer(self.dragBoxLayer)
            
            // create animation for the layer
            let dashAnimation : CABasicAnimation = CABasicAnimation(keyPath: "lineDashPhase")
            dashAnimation.fromValue = 0.0
            dashAnimation.toValue = 15.0
            dashAnimation.duration = 0.75
            dashAnimation.repeatCount = Float.infinity
            self.dragBoxLayer.addAnimation(dashAnimation, forKey: "linePhase")
            self.draggingSelection = true
            
        }
        
        linkingObjects = nil
        NSCursor.arrowCursor().set()
        window!.invalidateCursorRectsForView(self)
    }
    
    
    
    var highlightedLayoutItem : PSLayoutItem? = nil
    
    func highlightLayoutItem(theLayoutItem : PSLayoutItem?) {
        if let sl = highlightedLayoutItem {
            //unselect this layoutItem
            sl.icon.borderWidth = 0.0
            sl.icon.shadowOpacity = 0.0
            
        }
        highlightedLayoutItem = theLayoutItem
        
        if let l = theLayoutItem {
            l.icon.borderWidth = 2.0 // making border bigger (Luca)
            l.icon.shadowOpacity = 0.8
        
            if !layerIsVisibleInScrollView(l.icon) {
                scrollToLayer(l.icon)
            }
            contextMenuObject = ContextMenuObject.SelectedObject(l)
        } else {
            contextMenuObject = nil
        }
        
    }
    
    //store original position
    var dragSelectedLayoutItems : [PSLayoutItem : CGPoint] = [:]
    func dragSelectLayoutItem(tl : PSLayoutItem, on : Bool) {
        if on {
            tl.icon.opacity = 0.3
            tl.icon.borderWidth = 3.0 // making border bigger to make it more visible when dragging (Luca)
            tl.icon.borderColor = NSColor.redColor().CGColor // changing the color while dragging
            dragSelectedLayoutItems[tl] = tl.icon.position
        } else {
            tl.icon.opacity = 1.0
            dragSelectedLayoutItems[tl] = nil
        }
        //update context menu
        contextMenuObject = ContextMenuObject.MultipleObjects(Array(dragSelectedLayoutItems.keys))
    }
    
    func unDragSelectLayoutItems() {
        for eachLayoutItem in Array(dragSelectedLayoutItems.keys) {
            //reestablishing colors and opacity when undragged
            eachLayoutItem.icon.borderWidth = 0.0
            eachLayoutItem.icon.borderColor = NSColor.whiteColor().CGColor
            eachLayoutItem.icon.opacity = 1.0
            
        }
        dragSelectedLayoutItems = [:]
        contextMenuObject = nil
    }
    
    func hideLayoutItem(theLayoutItem : PSLayoutItem, hidden : Bool) {
        theLayoutItem.icon.hidden = hidden
        theLayoutItem.text.hidden = hidden
        //also hide links
        for link in objectLinks {
            if link.destLayoutItem == theLayoutItem {
                link.lineLayer.hidden = hidden
            } else if link.startLayoutItem == theLayoutItem {
                //hideLayoutItem takes care of links -to- the object so no need to hide here
                hideLayoutItem(link.destLayoutItem,hidden: hidden)
            }
        }
    }
    
    override func mouseDragged(theEvent: NSEvent) {

        if let info = clickedObject {
            var displacement = theEvent.locationInWindow.minusPoint(info.mouseDownPoint)
            displacement.y = 0 - displacement.y
            

            CATransaction.begin()
            CATransaction.setDisableActions(true)
            
            if (dragSelectedLayoutItems != [:]) {
                for eachLayoutItem in dragSelectedLayoutItems.keys {
                    let new_position = dragSelectedLayoutItems[eachLayoutItem]!.plusPoint(displacement)
                    updateObjectLayoutItem(eachLayoutItem, x: Int(new_position.x), y:Int(new_position.y))
                }
            } else {
                let new_position = info.originalPosition.plusPoint(displacement)
                updateObjectLayoutItem(info.clickedLayoutItem, x: Int(new_position.x), y: Int(new_position.y))
            }
            CATransaction.commit()
        } else if (self.draggingSelection) {
            let point = self.convertPoint(theEvent.locationInWindow, fromView: nil)
            // create path for the shape LayoutItem
            
            let path = CGPathCreateMutable();
            CGPathMoveToPoint(path, nil, self.dragSelectionPoint.x, self.dragSelectionPoint.y);
            CGPathAddLineToPoint(path, nil, self.dragSelectionPoint.x, point.y);
            CGPathAddLineToPoint(path, nil, point.x, point.y);
            CGPathAddLineToPoint(path, nil, point.x, self.dragSelectionPoint.y);
            CGPathCloseSubpath(path);
            
            // set the shape LayoutItem's path
            
            self.dragBoxLayer.path = path;
            
            //now do collision detection
            let leftX = min(self.dragSelectionPoint.x, point.x) - PSConstants.Spacing.halfIconSize
            let rightX = max(self.dragSelectionPoint.x, point.x)  + PSConstants.Spacing.halfIconSize
            let bottomY = min(self.dragSelectionPoint.y, point.y)  - PSConstants.Spacing.halfIconSize
            let topY = max(self.dragSelectionPoint.y, point.y)  + PSConstants.Spacing.halfIconSize
            
            for eachLayoutItem in layoutItems {
                
                let containsPoint = eachLayoutItem.icon.position.x <= rightX && eachLayoutItem.icon.position.x >= leftX && eachLayoutItem.icon.position.y <= topY && eachLayoutItem.icon.position.y >= bottomY
                if containsPoint {
                    //selected layoutItems
                    dragSelectLayoutItem(eachLayoutItem, on: true)
                   
                } else {
                    //unselected LayoutItem
                    dragSelectLayoutItem(eachLayoutItem, on: false)
                }
            }
        }
    }
    
    
    
    override func mouseUp(theEvent: NSEvent) {
        
        if (self.draggingSelection) {
            dragBoxLayer.removeFromSuperlayer()
            dragBoxLayer = nil
            draggingSelection = false
        } else if let info = clickedObject {
                
            if theEvent.clickCount == 0 {
                //detect whether object has moved
                if info.mouseDownPoint != theEvent.locationInWindow {
                    layoutController.layoutItemMoved(info.clickedLayoutItem)
                    for eachLayoutItem in dragSelectedLayoutItems.keys {
                        dragSelectedLayoutItems[eachLayoutItem] = eachLayoutItem.icon.position
                        layoutController.layoutItemMoved(eachLayoutItem)
                    }
                    
                } else {
                    unDragSelectLayoutItems()
                    layoutController.selectObjectForLayoutItem(info.clickedLayoutItem)
                }
            } else if theEvent.clickCount == 1 {
                unDragSelectLayoutItems()
                layoutController.selectObjectForLayoutItem(info.clickedLayoutItem)
                self.becomeFirstResponder()
            } else if theEvent.clickCount == 2 {
                unDragSelectLayoutItems()
                layoutController.doubleClickObjectForLayoutItem(info.clickedLayoutItem)
            }
        }
    }
    

    
    
    func updateContextMenuItems(sender : AnyObject) {
        if let cmo = contextMenuObject {
            switch (cmo) {
            case .SelectedLink(_):
                hideMenuItem(linkMenuItemTag, hidden: true)
                hideMenuItem(cleanMenuItemTag, hidden: true)
                hideMenuItem(deleteMenuItemTag, hidden: false)
                break
            case .SelectedObject(_):
                hideMenuItem(linkMenuItemTag, hidden: false)
                hideMenuItem(cleanMenuItemTag, hidden: false)
                hideMenuItem(deleteMenuItemTag, hidden: false)
                break
            case .MultipleObjects(_):
                hideMenuItem(linkMenuItemTag, hidden: false)
                hideMenuItem(cleanMenuItemTag, hidden: true)
                hideMenuItem(deleteMenuItemTag, hidden: false)
                break
            }
        } else {
            hideMenuItem(linkMenuItemTag, hidden: true)
            hideMenuItem(cleanMenuItemTag, hidden: true)
            hideMenuItem(deleteMenuItemTag, hidden: true)
        }
    }
    
    func hideMenuItem(tag : Int, hidden : Bool) {
        actionPopup.menu?.itemWithTag(tag)?.hidden = hidden
        contextMenu.itemWithTag(tag)?.hidden = hidden
    }
    
    
    override func menuForEvent(event: NSEvent) -> NSMenu? {
        //context menu
        
        if linkingObjects != nil {
            linkingObjects = nil
            NSCursor.arrowCursor().set()
            window!.invalidateCursorRectsForView(self)
        }
        
        let click_point = NSPointToCGPoint(self.convertPoint(event.locationInWindow, fromView: nil))
        
        let hit_layoutItem = hitLayoutItem(click_point)
        if let l = hit_layoutItem, cmo = contextMenuObject {
            
            //determine if single or multiple objects selected
            switch (cmo) {
            case .SelectedLink(_):
                //never happen
                break
            case let .SelectedObject(theItem):
                //select this object if not selected
                if theItem != l {
                    layoutController.selectObjectForLayoutItem(l)
                    contextMenuObject = ContextMenuObject.SelectedObject(l)
                }
                break
            case .MultipleObjects(_):
                var found = false
                for obj in dragSelectedLayoutItems.keys {
                    if obj == l {
                        found = true
                        break
                    }
                }
                
                if (!found) {
                    layoutController.selectObjectForLayoutItem(l)
                    contextMenuObject = ContextMenuObject.SelectedObject(l)
                }
                
                break
            }
            
            updateContextMenuItems(self)
            return super.menuForEvent(event)
        }
        
        let hit_link = hitLinkItem(click_point)
        if let link = hit_link {
            contextMenuObject = ContextMenuObject.SelectedLink(link)
            updateContextMenuItems(self)
            return super.menuForEvent(event)
        }
        return nil
        
        
    }
    
    @IBAction func cleanUpChildren(sender : AnyObject) {
        if let cmo = contextMenuObject {
            switch (cmo) {
            case .SelectedLink(_):
          
                break
            case let .SelectedObject(theItem):
                layoutController.cleanUpChildren(theItem)
                break
            case .MultipleObjects(_):
       
                break
            }
        }
        
        contextMenuObject = nil
        
    }
    
   
    @IBAction func deleteObject(sender : AnyObject) {
        
        if let cmo = contextMenuObject {
            switch (cmo) {
            case let .SelectedLink(link):
                layoutController.unLinkObjects(link.startLayoutItem, destLayoutItem: link.destLayoutItem)
                break
            case let .SelectedObject(theItem):
                layoutController.deleteLayoutItems([theItem])
                break
            case let .MultipleObjects(objects):
                layoutController.deleteLayoutItems(objects)
                break
            }
        }
        
        contextMenuObject = nil
    }
    
    @IBAction func linkObject(_: AnyObject) {
        //activate link mode
        linkingObjects = []
        if let hl = highlightedLayoutItem {
            linkingObjects!.append(hl)
        } else {
            for dsl in dragSelectedLayoutItems.keys {
                linkingObjects!.append(dsl)
            }
        }
        
        if linkingObjects!.count > 0 {
            NSCursor.crosshairCursor().set()
            window!.invalidateCursorRectsForView(self)
        } else {
            linkingObjects = nil
        }
    }
    
    func makeObjectLayoutItem(iconImage : NSImage, name : String) -> PSLayoutItem {
        //creates a layoutItem to represent a layoutobject
        let sublayer = CALayer()
        
       // sublayer.backgroundColor = self.layer!.backgroundColor
        sublayer.backgroundColor = NSColor.clearColor().CGColor // LucaL to consider how  icons appear when overlapping 
        
        sublayer.shadowOffset = CGSizeMake(0, 0);//Luca changed from 0.3 to remove the shadow effect
        sublayer.shadowRadius = 0.0;//Luca changed from 5.0
        sublayer.shadowColor = NSColor.blackColor().CGColor;
        sublayer.shadowOpacity = 0.0;
        sublayer.contentsScale = self.mainWindow.backingScaleFactor
        sublayer.contents = iconImage
        sublayer.borderColor = NSColor.whiteColor().CGColor; // Luca experimented. Can be changed to from NSColor.clearColor to remove the visible icon border when selected. Originally, it was BlackColor.
        sublayer.borderWidth = 0.0;
        self.layer!.addSublayer(sublayer)
        sublayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        sublayer.bounds = CGRect(origin: NSZeroPoint, size: CGSizeMake(32,32))
        
        
        let text_layer = CATextLayer()
        text_layer.contentsScale = self.mainWindow.backingScaleFactor

        text_layer.backgroundColor = PSConstants.BasicDefaultColors.backgroundColor
        text_layer.font = PSConstants.Fonts.layoutBoardIcons
        text_layer.fontSize = 10
        text_layer.string = name
        text_layer.alignmentMode = kCAAlignmentCenter
        text_layer.foregroundColor = NSColor.blackColor().CGColor
        text_layer.zPosition = 0
        
        
        text_layer.anchorPoint = CGPoint(x: 0.5, y: 1)
        text_layer.bounds = CGRect(origin: NSZeroPoint, size: CGSizeMake(100,17))
        self.layer!.addSublayer(text_layer)
        
        let item = PSLayoutItem()
        item.icon = sublayer
        item.text = text_layer
        layoutItems.append(item)
        return item
    }
    
    func removeObjectLayoutItem(subLayoutItem : PSLayoutItem) {
        subLayoutItem.icon.removeFromSuperlayer()
        subLayoutItem.text.removeFromSuperlayer()
        layoutItems = layoutItems.filter { $0 != subLayoutItem }
        var linksToDelete : [Link] = []
    
        for aLink in objectLinks {
            if (subLayoutItem == aLink.startLayoutItem) || (subLayoutItem == aLink.destLayoutItem) {
                aLink.lineLayer.removeFromSuperlayer()
                linksToDelete.append(aLink)
            }
        }
        
        //delete all associated links
        objectLinks = objectLinks.filter({ linksToDelete.indexOf($0) == nil })
    }
    
    func updateChildLinks(parentLayoutItem : PSLayoutItem, childLayoutItems : [PSLayoutItem]) {
        //this method deletes links that do no longer exist, adds one which dont
        //scope to improve performance here for sure
        
        let currentChildLinks = objectLinks.filter({
                (link : Link) -> Bool in
                return link.startLayoutItem == parentLayoutItem
            })
        
        //remove these links from main list
        objectLinks = objectLinks.filter({ currentChildLinks.indexOf($0) == nil })
        
        //go through each existing link and re-add / create
        
        for existing_child in childLayoutItems {
        
                var link_already_drawn = false
                for drawn_link in currentChildLinks {
                    if drawn_link.destLayoutItem == existing_child {
                        link_already_drawn = true
                        objectLinks.append(drawn_link)
                        redrawLinkLine(drawn_link)
                    }
                }
                if (!link_already_drawn) {
                    makeLinkItem(parentLayoutItem, destLayoutItem: existing_child)
                }
         
        }
        
        //delete any links layoutItems that are no longer active
        for drawn_link in currentChildLinks {
            var link_deleted = true
            for existing_child in childLayoutItems {
               
                    if drawn_link.destLayoutItem == existing_child {
                        link_deleted = false
                        break
                    }
                
            }
            if (link_deleted) {
                drawn_link.lineLayer.removeFromSuperlayer()
            }
        }
        
        
    }
    
    func updateParentLinks(childLayoutItem : PSLayoutItem, parentLayoutItems : [PSLayoutItem]) {
        
        let currentParentLinks = objectLinks.filter({
            (link : Link) -> Bool in
            return link.destLayoutItem == childLayoutItem
            })
        
        //remove these links from main list
        objectLinks = objectLinks.filter({ currentParentLinks.indexOf($0) == nil })
        
        //go through each existing link and re-add / create
        for existing_parent in parentLayoutItems {
            
                var link_already_drawn = false
                for drawn_link in currentParentLinks {
                    if drawn_link.startLayoutItem == existing_parent {
                        link_already_drawn = true
                        objectLinks.append(drawn_link)
                        redrawLinkLine(drawn_link)
                    }
                }
                if (!link_already_drawn) {
                    makeLinkItem(existing_parent, destLayoutItem: childLayoutItem)
                }
            
        }
        
        //delete any links layoutItems that are no longer active
        for drawn_link in currentParentLinks {
            var link_deleted = true
            for existing_parent in parentLayoutItems {
                
                    if drawn_link.startLayoutItem == existing_parent {
                        link_deleted = false
                        break
                    }
            }
            
            if (link_deleted) {
                drawn_link.lineLayer.removeFromSuperlayer()
            }
        }
        
    }
    
    func redrawLinkLine(link : Link) {
        link.lineLayer.path = makeCGLine(link.startLayoutItem.icon.position, to: link.destLayoutItem.icon.position)
    }
    
    func makeLinkItem(targetLayoutItem : PSLayoutItem, destLayoutItem : PSLayoutItem){
        //creates a line between two layoutobject layoutItems
        
        //first check if already made
        for link in objectLinks {
            if link.startLayoutItem == targetLayoutItem && link.destLayoutItem == destLayoutItem {
                //println("Link layer already established") - Do Nothing
                return
            }
        }
        
        //make new link
        let new_layer = makeLineLayer(targetLayoutItem.icon.position, to: destLayoutItem.icon.position)
        let new_link = Link(startLayoutItem: targetLayoutItem, destLayoutItem: destLayoutItem, lineLayer: new_layer)
        objectLinks.append(new_link)
        
        linkLayers.append(new_layer)
        self.layer!.addSublayer(new_layer)
    }
    
    func removeLinkItem(targetLayoutItem : PSLayoutItem, destLayoutItem : PSLayoutItem) {
        for link in objectLinks {
            if link.startLayoutItem == targetLayoutItem && link.destLayoutItem == destLayoutItem {
                link.lineLayer.removeFromSuperlayer()
                objectLinks = objectLinks.filter( { $0 != link } )
                return
            }
        }
    }
    
    func updateObjectLayoutItem(subLayoutItem : PSLayoutItem, x: Int, y: Int, name : String? = nil) {
        //updates the position of a layer, and links
        subLayoutItem.icon.position = CGPoint(x: x, y: y)
        if let n = name {
            subLayoutItem.text.string = n
        }
        
        let size = subLayoutItem.text.string!.sizeWithAttributes([NSFontAttributeName : PSConstants.Fonts.layoutBoardIcons])
        subLayoutItem.text.bounds = CGRect(origin: CGPointZero, size: size)
        subLayoutItem.text.position = CGPoint(x: x, y: y + PSConstants.Spacing.iconSize)
        
        for aLink in objectLinks {
            if (subLayoutItem == aLink.startLayoutItem) || (subLayoutItem == aLink.destLayoutItem) {
                redrawLinkLine(aLink)
            }
        }
    }
    
    func makeLineLayer(lineFrom: CGPoint, to: CGPoint) -> CAShapeLayer {
        //makes a CAShapeLayer containing a single line
        let line = CAShapeLayer()
        line.contentsScale = self.mainWindow.backingScaleFactor
        line.path = makeCGLine(lineFrom, to: to)
        line.fillColor = NSColor.grayColor().CGColor //darkgray from black Luca
        line.opacity = 1.0
        line.strokeColor = NSColor.grayColor().CGColor //gray from black Luca
        line.lineCap = kCALineCapRound
        return line
    }
    
    func makeCGLine(lineFrom: CGPoint, to: CGPoint) -> CGPath {
        //makes a path to insert into a CAShapeLayer
        let linePath = CGPathCreateMutable()
        CGPathMoveToPoint(linePath, nil, lineFrom.x, lineFrom.y + PSConstants.Spacing.halfIconSize)
        CGPathAddLineToPoint(linePath, nil, to.x, to.y - PSConstants.Spacing.halfIconSize)
        CGPathCloseSubpath(linePath)
        return linePath
    }
    

    
    func hitLayoutItem(point : CGPoint) -> PSLayoutItem? {
        for eachLayoutItem in layoutItems {
            let point2 = eachLayoutItem.icon.convertPoint(point, fromLayer: eachLayoutItem.icon.superlayer)
            if eachLayoutItem.icon.containsPoint(point2) {
                return eachLayoutItem
            }
        }
        return nil
    }
    
    func hitLinkItem(point : CGPoint) -> Link? {
        for eachLayoutItem in objectLinks {
            let point2 = eachLayoutItem.lineLayer.convertPoint(point, fromLayer: eachLayoutItem.lineLayer.superlayer)
            let min_distance =  CGPoint.minDistanceFromLineSegment(eachLayoutItem.startLayoutItem.icon.position, segB: eachLayoutItem.destLayoutItem.icon.position, p: point2)
            
            if min_distance < 5 {
                return eachLayoutItem
            }
        }
        return nil
    }
    
    
    override var acceptsFirstResponder: Bool { get { return true } }
    
    
    
    func layerIsVisibleInScrollView(layer : CALayer) -> Bool {
        return scrollView.contentView.documentVisibleRect.contains(layer.position)
    }
    
    
    //scrolls the view to display the layoutItem
    func scrollToLayer(layer : CALayer) {
        
        var newScrollOrigin : NSPoint = layer.position
        /*if (scrollView.documentView as NSView).flipped {
            newScrollOrigin = NSMakePoint(0.0, 0.0)
        } else {
            newScrollOrigin = NSMakePoint(0.0, NSMaxY((scrollView.documentView as NSView).frame) - NSHeight(scrollView.contentView.bounds))
        }*/
        
        newScrollOrigin.x = newScrollOrigin.x - (scrollView.contentView.bounds.width / 2)
        newScrollOrigin.y = newScrollOrigin.y - (scrollView.contentView.bounds.height / 2)
        scrollView.documentView?.scrollPoint(newScrollOrigin)
    }
    
    func paste(sender : AnyObject) {
        layoutController.pasteEntry()
    }
    
    func copy(sender : AnyObject) {
        layoutController.copyEntry()
    }
}
    