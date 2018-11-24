//
//  PSLayoutBoard.swift
//  PsyScopeEditor
//
//  NSView subclass that represents the layout of the experiment in the main window

import Swift
import Cocoa
import QuartzCore

class PSLayoutBoard: NSView {
    
    //MARK: Structs and Links
    
    struct ClickedObjectInfo {
        var clickedLayoutItem : PSLayoutItem = PSLayoutItem()
        var mouseDownPoint : NSPoint = NSPoint()
        var originalPosition : NSPoint = NSPoint()
    }
    
    class Link : Equatable {
        var startLayoutItem : PSLayoutItem
        var destLayoutItem : PSLayoutItem
        var lineLayer : CAShapeLayer
        init(startLayoutItem: PSLayoutItem, destLayoutItem: PSLayoutItem, lineLayer: CAShapeLayer) {
            self.startLayoutItem = startLayoutItem
            self.destLayoutItem = destLayoutItem
            self.lineLayer = lineLayer
        }
    }

    enum ContextMenuObject {
        case selectedObject(PSLayoutItem)
        case multipleObjects([PSLayoutItem])
        case selectedLink(Link)
    }

    //MARK: Outlets
    
    
    @IBOutlet var statusBar : NSTextField!
    @IBOutlet var layoutController : LayoutController!
    @IBOutlet var actionPopup : NSPopUpButton!
    @IBOutlet var contextMenu : NSMenu!
    @IBOutlet var scrollView : NSScrollView!
    @IBOutlet var mainWindow : NSWindow!
    
    @IBOutlet var cleanMenuItem : NSMenuItem!
    @IBOutlet var deleteMenuItem : NSMenuItem!
    @IBOutlet var linkMenuItem : NSMenuItem!
    @IBOutlet var convertMenuItem : NSMenuItem!
    
    //MARK: Variables
    
    var layoutItems : [PSLayoutItem] = []
    var linkLayers: [CALayer] = []
    var objectLinks : [Link] = []
    var clickedObject : ClickedObjectInfo? = nil
    var contextMenuObject : ContextMenuObject? = nil
    var dragSelectionPoint : NSPoint = NSPoint()
    var dragBoxLayer : CAShapeLayer! = nil
    var draggingSelection : Bool = false
    var linkingObjects : [PSLayoutItem]? //if linking to objects, stores the first selected objects
    var currentDragOperation : NSDragOperation? = nil
    var filesToImport : [String : [PSToolInterface]] = [:]
    var highlightedLayoutItem : PSLayoutItem? = nil
    var dragSelectedLayoutItems : [PSLayoutItem : CGPoint] = [:]
    var layoutBoardArea : NSSize = NSSize(width: 1000,height: 1000)

    
    //MARK: Constants

    let draggedTypes : [String] = [PSConstants.PSToolBrowserView.dragType, PSConstants.PSToolBrowserView.pasteboardType,PSConstants.PSEventBrowserView.dragType, PSConstants.PSEventBrowserView.pasteboardType,NSFilenamesPboardType]
    
    //MARK: Setup
    
    //Called by LayoutController's awakeFromNib (awakeFromNib order appears random, whence this is the equivalent)
    func prepareMainLayer() {
        self.register(forDraggedTypes: draggedTypes)
        self.layer = CALayer()
        //self.wantsLayer = true
        self.layer!.backgroundColor = PSConstants.BasicDefaultColors.backgroundColor
        self.layer!.zPosition = 0
        self.layer!.contentsScale = self.mainWindow.backingScaleFactor
        NotificationCenter.default.addObserver(self, selector: "updateContextMenuItems:", name: NSNotification.Name.NSPopUpButtonWillPopUp, object: actionPopup)

        for item in contextMenu.items as [NSMenuItem] {
            actionPopup.menu?.addItem(item.copy() as! NSMenuItem)
        }
        
        layoutBoardArea = self.layer!.bounds.size
    }
    
    //MARK: Misc Overrides
    
    //Adjusts appearance of cursor when linking objects
    override func resetCursorRects() {
        if linkingObjects != nil {
            self.addCursorRect(self.bounds, cursor: NSCursor.crosshair())
        } else {
            super.resetCursorRects()
        }
    }
    
    override var isFlipped : Bool { get { return true } }
    override var acceptsFirstResponder: Bool { get { return true } }
    
    //MARK: Dragging related overrides
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        let pasteboard = sender.draggingPasteboard()
        currentDragOperation = NSDragOperation.link

        if let type = pasteboard.availableType(from: draggedTypes) {
            if type == NSFilenamesPboardType {
                currentDragOperation = NSDragOperation.copy
            }
        }
        return currentDragOperation!
    }
    
    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        return currentDragOperation!
    }
    
    
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        //check if file is of a good type
        filesToImport = [:]
        let pasteboard = sender.draggingPasteboard()
        if pasteboard.string(forType: PSConstants.PSToolBrowserView.pasteboardType) != nil {
            return true
        } else if pasteboard.string(forType: PSConstants.PSEventBrowserView.pasteboardType) != nil {
            return true
        } else if let filenames : [AnyObject] = pasteboard.propertyList(forType: NSFilenamesPboardType) as? [AnyObject] {
            var valid_files = true
            for filename in filenames {
                if let fn = filename as? String, absPath = URL(fileURLWithPath: fn).path {
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
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let location = self.convert(sender.draggingLocation(),from: nil)
        let pasteboard = sender.draggingPasteboard()
        window!.makeFirstResponder(self)
        if let type = pasteboard.string(forType: PSConstants.PSToolBrowserView.pasteboardType) {
            layoutController.draggedNewTool(type, location: location)
            return true
        } else if let type = pasteboard.string(forType: PSConstants.PSEventBrowserView.pasteboardType) {
            layoutController.draggedNewTool(type, location: location)
            return true
        } else if filesToImport.count > 0 {
            return layoutController.draggedFiles(filesToImport, location: location)
        }
        return false
    }

    
    override func wantsPeriodicDraggingUpdates() -> Bool { return true }
    
    
    
    //MARK: Mouse related overrides
    
    override func mouseDown(with theEvent: NSEvent) {
        
        
        
        
        //mouseDown can drag existing layoutItems or be the end of a link operation
        let click_point = self.convert(theEvent.locationInWindow, from: nil)
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
            self.dragBoxLayer.strokeColor = NSColor.black.cgColor
            self.dragBoxLayer.fillColor = NSColor.clear.cgColor
            self.dragBoxLayer.lineDashPattern = [10, 5]
            self.layer!.addSublayer(self.dragBoxLayer)
            
            // create animation for the layer
            let dashAnimation : CABasicAnimation = CABasicAnimation(keyPath: "lineDashPhase")
            dashAnimation.fromValue = 0.0
            dashAnimation.toValue = 15.0
            dashAnimation.duration = 0.75
            dashAnimation.repeatCount = Float.infinity
            self.dragBoxLayer.add(dashAnimation, forKey: "linePhase")
            self.draggingSelection = true
            
        }
        
        linkingObjects = nil
        NSCursor.arrow().set()
        window!.invalidateCursorRects(for: self)
    }
    
    override func mouseDragged(with theEvent: NSEvent) {
        
        if let info = clickedObject {
            var displacement = theEvent.locationInWindow - info.mouseDownPoint
            displacement.y = 0 - displacement.y
            
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            
            if (dragSelectedLayoutItems != [:]) {
                for eachLayoutItem in dragSelectedLayoutItems.keys {
                    let new_position = dragSelectedLayoutItems[eachLayoutItem]! + displacement
                    updateObjectLayoutItem(eachLayoutItem, x: Int(new_position.x), y:Int(new_position.y))
                }
            } else {
                let new_position = info.originalPosition + displacement
                updateObjectLayoutItem(info.clickedLayoutItem, x: Int(new_position.x), y: Int(new_position.y))
            }
            CATransaction.commit()
        } else if (self.draggingSelection) {
            let point = self.convert(theEvent.locationInWindow, from: nil)
            // create path for the shape LayoutItem
            
            let path = CGMutablePath();
            CGPathMoveToPoint(path, nil, self.dragSelectionPoint.x, self.dragSelectionPoint.y);
            CGPathAddLineToPoint(path, nil, self.dragSelectionPoint.x, point.y);
            CGPathAddLineToPoint(path, nil, point.x, point.y);
            CGPathAddLineToPoint(path, nil, point.x, self.dragSelectionPoint.y);
            path.closeSubpath();
            
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
    
    
    
    override func mouseUp(with theEvent: NSEvent) {
        
        if (self.draggingSelection) {
            dragBoxLayer.removeFromSuperlayer()
            dragBoxLayer = nil
            draggingSelection = false
        } else if let info = clickedObject {
            
            //command key is down so add to selection
            let commandDown = (theEvent.modifierFlags.contains(NSEventModifierFlags.command))
            
        
            
            if theEvent.clickCount == 0 {
                //detect whether object has moved
                if info.mouseDownPoint != theEvent.locationInWindow {
                    for eachLayoutItem in dragSelectedLayoutItems.keys {
                        dragSelectedLayoutItems[eachLayoutItem] = eachLayoutItem.icon.position
                    }
                    layoutController.layoutItemsMoved(Array(dragSelectedLayoutItems.keys))
                } else {
                    unDragSelectLayoutItems()
                    layoutController.selectObjectForLayoutItem(info.clickedLayoutItem)
                }
            } else if theEvent.clickCount == 1 {
                if commandDown {
                    //if nothing already drag selected, ensure first item is included too
                    if let highlightedLayoutItem = highlightedLayoutItem where dragSelectedLayoutItems.count == 0 {
                        dragSelectLayoutItem(highlightedLayoutItem, on: true)
                    }
                    
                    //toggle
                    let on = dragSelectedLayoutItems[info.clickedLayoutItem] == nil
                    dragSelectLayoutItem(info.clickedLayoutItem, on: on)
                    
                    
                    
                } else {
                    unDragSelectLayoutItems()
                    layoutController.selectObjectForLayoutItem(info.clickedLayoutItem)
                }
                
                self.becomeFirstResponder()
            } else if theEvent.clickCount == 2 {
                unDragSelectLayoutItems()
                layoutController.doubleClickObjectForLayoutItem(info.clickedLayoutItem)
            }
        }
    }
    
    //MARK: Highlighting / Selecting / Dragging
    
    func highlightLayoutItem(_ theLayoutItem : PSLayoutItem?) {
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
            contextMenuObject = ContextMenuObject.selectedObject(l)
        } else {
            contextMenuObject = nil
        }
    }
    
    
    func dragSelectLayoutItem(_ tl : PSLayoutItem, on : Bool) {
        if on {
            tl.icon.opacity = 0.3
            tl.icon.borderWidth = 3.0 // making border bigger to make it more visible when dragging (Luca)
            tl.icon.borderColor = NSColor.red.cgColor // changing the color while dragging
            dragSelectedLayoutItems[tl] = tl.icon.position
        } else {
            tl.icon.opacity = 1.0
            dragSelectedLayoutItems[tl] = nil
        }
        //update context menu
        contextMenuObject = ContextMenuObject.multipleObjects(Array(dragSelectedLayoutItems.keys))
    }
    
    func unDragSelectLayoutItems() {
        for eachLayoutItem in Array(dragSelectedLayoutItems.keys) {
            //reestablishing colors and opacity when undragged
            eachLayoutItem.icon.borderWidth = 0.0
            eachLayoutItem.icon.borderColor = NSColor.white.cgColor
            eachLayoutItem.icon.opacity = 1.0
            
        }
        dragSelectedLayoutItems = [:]
        contextMenuObject = nil
    }
    
    func hideLayoutItem(_ theLayoutItem : PSLayoutItem, hidden : Bool) {
        theLayoutItem.icon.isHidden = hidden
        theLayoutItem.text.isHidden = hidden
        //also hide links
        for link in objectLinks {
            if link.destLayoutItem == theLayoutItem {
                link.lineLayer.isHidden = hidden
            } else if link.startLayoutItem == theLayoutItem {
                //hideLayoutItem takes care of links -to- the object so no need to hide here
                hideLayoutItem(link.destLayoutItem,hidden: hidden)
            }
        }
    }

    //MARK: Context menu
    
    func updateContextMenuItems(_ sender : AnyObject) {
        if let cmo = contextMenuObject {
            switch (cmo) {
            case .selectedLink(_):
                linkMenuItem.isHidden = true
                cleanMenuItem.isHidden = true
                deleteMenuItem.isHidden = false
                convertMenuItem.isHidden = true
                break
            case let .selectedObject(layoutItem):
                linkMenuItem.isHidden = false
                cleanMenuItem.isHidden = true
                deleteMenuItem.isHidden = false
                
                //if layoutObject is an event then allow
                convertMenuItem.isHidden = !layoutController.layoutItemsAreConvertible([layoutItem])
                break
            case let .multipleObjects(layoutItems):
                linkMenuItem.isHidden = false
                cleanMenuItem.isHidden = true
                deleteMenuItem.isHidden = false
                
                //if all layoutObjects are events then allow
                convertMenuItem.isHidden = !layoutController.layoutItemsAreConvertible(layoutItems)
                break
            }
        } else {
            linkMenuItem.isHidden = true
            cleanMenuItem.isHidden = true
            deleteMenuItem.isHidden = true
            convertMenuItem.isHidden = true
        }
    }
    
    
    override func menu(for event: NSEvent) -> NSMenu? {
        //context menu
        
        if linkingObjects != nil {
            linkingObjects = nil
            NSCursor.arrow().set()
            window!.invalidateCursorRects(for: self)
        }
        
        let click_point = NSPointToCGPoint(self.convert(event.locationInWindow, from: nil))
        
        let hit_layoutItem = hitLayoutItem(click_point)
        if let l = hit_layoutItem, cmo = contextMenuObject {
            
            //determine if single or multiple objects selected
            switch (cmo) {
            case .selectedLink(_):
                //never happen
                break
            case let .selectedObject(theItem):
                //select this object if not selected
                if theItem != l {
                    layoutController.selectObjectForLayoutItem(l)
                    contextMenuObject = ContextMenuObject.selectedObject(l)
                }
                break
            case .multipleObjects(_):
                var found = false
                for obj in dragSelectedLayoutItems.keys {
                    if obj == l {
                        found = true
                        break
                    }
                }
                
                if (!found) {
                    layoutController.selectObjectForLayoutItem(l)
                    contextMenuObject = ContextMenuObject.selectedObject(l)
                }
                
                break
            }
            
            updateContextMenuItems(self)
            return super.menu(for: event)
        }
        
        let hit_link = hitLinkItem(click_point)
        if let link = hit_link {
            contextMenuObject = ContextMenuObject.selectedLink(link)
            updateContextMenuItems(self)
            return super.menu(for: event)
        }
        return nil
        
        
    }
    
    //MARK: Menu Actions
    
    @IBAction func cleanUpChildren(_ sender : AnyObject) {
        if let cmo = contextMenuObject {
            switch (cmo) {
            case .selectedLink(_):
          
                break
            case let .selectedObject(theItem):
                layoutController.cleanUpChildren(theItem)
                break
            case .multipleObjects(_):
       
                break
            }
        }
        
        contextMenuObject = nil
        
    }
    
   
    @IBAction func deleteObject(_ sender : AnyObject) {
        
        if let cmo = contextMenuObject {
            switch (cmo) {
            case let .selectedLink(link):
                layoutController.unLinkObjects(link.startLayoutItem, destLayoutItem: link.destLayoutItem)
                break
            case let .selectedObject(theItem):
                layoutController.deleteLayoutItems([theItem])
                break
            case let .multipleObjects(objects):
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
            NSCursor.crosshair().set()
            window!.invalidateCursorRects(for: self)
        } else {
            linkingObjects = nil
        }
    }
    
    @IBAction func convertObject(_: AnyObject) {
        if let cmo = contextMenuObject {
            switch (cmo) {
            case .selectedLink:
                break
            case let .selectedObject(theItem):
                layoutController.convertLayoutItems([theItem])
                break
            case let .multipleObjects(theItems):
                layoutController.convertLayoutItems(theItems)
                break
            }
        }
        
    }
    
    //MARK: Items: Adding / Removing
    
    func makeObjectLayoutItem(_ iconImage : NSImage, name : String) -> PSLayoutItem {
        //creates a layoutItem to represent a layoutobject
        let sublayer = CALayer()
        
        sublayer.backgroundColor = NSColor.clear.cgColor // LucaL to consider how  icons appear when overlapping
        sublayer.shadowOffset = CGSize(width: 0, height: 0);//Luca changed from 0.3 to remove the shadow effect
        sublayer.shadowRadius = 0.0;//Luca changed from 5.0
        sublayer.shadowColor = NSColor.black.cgColor;
        sublayer.shadowOpacity = 0.0;
        sublayer.contentsScale = self.mainWindow.backingScaleFactor
        sublayer.contents = iconImage
        sublayer.borderColor = NSColor.white.cgColor; // Luca experimented. Can be changed to from NSColor.clearColor to remove the visible icon border when selected. Originally, it was BlackColor.
        sublayer.borderWidth = 0.0;
        self.layer!.addSublayer(sublayer)
        sublayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        sublayer.bounds = CGRect(origin: NSZeroPoint, size: CGSize(width: 32,height: 32))
        let text_layer = CATextLayer()
        text_layer.contentsScale = self.mainWindow.backingScaleFactor

        text_layer.backgroundColor = PSConstants.BasicDefaultColors.backgroundColor
        text_layer.font = PSConstants.Fonts.layoutBoardIcons
        text_layer.fontSize = 10
        text_layer.string = name
        text_layer.alignmentMode = kCAAlignmentCenter
        text_layer.foregroundColor = NSColor.black.cgColor
        text_layer.zPosition = 0
        
        
        text_layer.anchorPoint = CGPoint(x: 0.5, y: 1)
        text_layer.bounds = CGRect(origin: NSZeroPoint, size: CGSize(width: 100,height: 17))
        self.layer!.addSublayer(text_layer)
        
        let item = PSLayoutItem()
        item.icon = sublayer
        item.text = text_layer
        layoutItems.append(item)
        return item
    }
    
    func removeObjectLayoutItem(_ subLayoutItem : PSLayoutItem) {
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
        objectLinks = objectLinks.filter({ linksToDelete.index(of: $0) == nil })
    }
    
    //MARK: Items: Updating
    
    func updateObjectLayoutItem(_ subLayoutItem : PSLayoutItem, x: Int, y: Int, name : String? = nil) {
        //update size of board to encompass greater sizes
        resizeLayoutBoardAreaToInclude(CGFloat(x + 100), y: CGFloat(y + 100))
        
        //updates the position of a layer, and links
        subLayoutItem.icon.position = CGPoint(x: x, y: y)
        if let n = name {
            subLayoutItem.text.string = n
        }
        
        let size = subLayoutItem.text.string!.size(withAttributes: [NSFontAttributeName : PSConstants.Fonts.layoutBoardIcons])
        subLayoutItem.text.bounds = CGRect(origin: CGPoint.zero, size: size)
        subLayoutItem.text.position = CGPoint(x: x, y: y + PSConstants.Spacing.iconSize)
        
        for aLink in objectLinks {
            if (subLayoutItem == aLink.startLayoutItem) || (subLayoutItem == aLink.destLayoutItem) {
                redrawLinkLine(aLink)
            }
        }
    }
    
    //MARK: Links: Updating
    
    func updateChildLinks(_ parentLayoutItem : PSLayoutItem, childLayoutItems : [PSLayoutItem]) {
        //this method deletes links that do no longer exist, adds one which dont
        //scope to improve performance here for sure
        
        let currentChildLinks = objectLinks.filter({
                (link : Link) -> Bool in
                return link.startLayoutItem == parentLayoutItem
            })
        
        //remove these links from main list
        objectLinks = objectLinks.filter({ currentChildLinks.index(of: $0) == nil })
        
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
    
    func updateParentLinks(_ childLayoutItem : PSLayoutItem, parentLayoutItems : [PSLayoutItem]) {
        
        let currentParentLinks = objectLinks.filter({
            (link : Link) -> Bool in
            return link.destLayoutItem == childLayoutItem
            })
        
        //remove these links from main list
        objectLinks = objectLinks.filter({ currentParentLinks.index(of: $0) == nil })
        
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
    
    //MARK: Links: Adding / Removing
    
    func makeLinkItem(_ targetLayoutItem : PSLayoutItem, destLayoutItem : PSLayoutItem){
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
    
    func removeLinkItem(_ targetLayoutItem : PSLayoutItem, destLayoutItem : PSLayoutItem) {
        for link in objectLinks {
            if link.startLayoutItem == targetLayoutItem && link.destLayoutItem == destLayoutItem {
                link.lineLayer.removeFromSuperlayer()
                objectLinks = objectLinks.filter( { $0 != link } )
                return
            }
        }
    }
    
    //MARK: Drawing
    
    func redrawLinkLine(_ link : Link) {
        link.lineLayer.path = makeCGLine(link.startLayoutItem.icon.position, to: link.destLayoutItem.icon.position)
    }
    
    func makeLineLayer(_ lineFrom: CGPoint, to: CGPoint) -> CAShapeLayer {
        //makes a CAShapeLayer containing a single line
        let line = CAShapeLayer()
        line.contentsScale = self.mainWindow.backingScaleFactor
        line.path = makeCGLine(lineFrom, to: to)
        line.fillColor = NSColor.gray.cgColor //darkgray from black Luca
        line.opacity = 1.0
        line.strokeColor = NSColor.gray.cgColor //gray from black Luca
        line.lineCap = kCALineCapRound
        return line
    }
    
    func makeCGLine(_ lineFrom: CGPoint, to: CGPoint) -> CGPath {
        //makes a path to insert into a CAShapeLayer
        let linePath = CGMutablePath()
        CGPathMoveToPoint(linePath, nil, lineFrom.x, lineFrom.y + PSConstants.Spacing.halfIconSize)
        CGPathAddLineToPoint(linePath, nil, to.x, to.y - PSConstants.Spacing.halfIconSize)
        linePath.closeSubpath()
        return linePath
    }
    
    //MARK: Resizing
    
    override func viewDidEndLiveResize() {
        resizeLayoutBoardAreaToInclude(scrollView.contentSize.width, y: scrollView.contentSize.height)

    }
    
    func resizeLayoutBoardAreaToInclude(_ x : CGFloat, y: CGFloat) {

        self.layoutBoardArea.width = max(self.layoutBoardArea.width, x)
        self.layoutBoardArea.height = max(self.layoutBoardArea.height, y)
        let newLayerSize = NSSize(width: self.layoutBoardArea.width, height: self.layoutBoardArea.height)
        
        if newLayerSize != self.frame.size {
            let newFrame = NSRect(origin: self.frame.origin, size: newLayerSize)
            self.frame = newFrame
        }
    }
    
    

    //MARK: Geometry / hit detection
    
    func hitLayoutItem(_ point : CGPoint) -> PSLayoutItem? {
        for eachLayoutItem in layoutItems {
            let point2 = eachLayoutItem.icon.convert(point, from: eachLayoutItem.icon.superlayer)
            if eachLayoutItem.icon.contains(point2) {
                return eachLayoutItem
            }
        }
        return nil
    }
    
    func hitLinkItem(_ point : CGPoint) -> Link? {
        for eachLayoutItem in objectLinks {
            let point2 = eachLayoutItem.lineLayer.convert(point, from: eachLayoutItem.lineLayer.superlayer)
            let min_distance =  minDistanceFromLineSegment(eachLayoutItem.startLayoutItem.icon.position, segB: eachLayoutItem.destLayoutItem.icon.position, p: point2)
            
            if min_distance < 5 {
                return eachLayoutItem
            }
        }
        return nil
    }
    
    func minDistanceFromLineSegment(_ segA : CGPoint, segB : CGPoint, p: CGPoint) -> CGFloat {
        let p2 = CGPoint(x: segB.x - segA.x, y: segB.y - segA.y);
        let something = (p2.x*p2.x) + (p2.y*p2.y)
        var u = ((p.x - segA.x) * p2.x + (p.y - segA.y) * p2.y) / something;
        
        if (u > 1) {
            u = 1 }
        else if (u < 0) {
            u = 0 }
        
        let x = segA.x + u * p2.x;
        let y = segA.y + u * p2.y;
        
        let dx = x - p.x;
        let dy = y - p.y;
        
        let dist = sqrt(dx*dx + dy*dy);
        
        return dist;
    }
    
    //scrolls the view to display the layoutItem
    func scrollToLayer(_ layer : CALayer) {
        
        var newScrollOrigin : NSPoint = layer.position
        /*if (scrollView.documentView as NSView).flipped {
            newScrollOrigin = NSMakePoint(0.0, 0.0)
        } else {
            newScrollOrigin = NSMakePoint(0.0, NSMaxY((scrollView.documentView as NSView).frame) - NSHeight(scrollView.contentView.bounds))
        }*/
        
        newScrollOrigin.x = newScrollOrigin.x - (scrollView.contentView.bounds.width / 2)
        newScrollOrigin.y = newScrollOrigin.y - (scrollView.contentView.bounds.height / 2)
        scrollView.documentView?.scroll(newScrollOrigin)
    }
    
    func layerIsVisibleInScrollView(_ layer : CALayer) -> Bool {
        return scrollView.contentView.documentVisibleRect.contains(layer.position)
    }
    
    //MARK: Copy / Paste
    
    func paste(_ sender : AnyObject) {
        layoutController.pasteEntry()
    }
    
    func copy(_ sender : AnyObject) {
        layoutController.copyEntry()
    }
}

func ==(lhs: PSLayoutBoard.Link, rhs: PSLayoutBoard.Link) -> Bool {
    let r = (lhs.startLayoutItem == rhs.startLayoutItem) && (lhs.destLayoutItem == rhs.destLayoutItem) && (lhs.lineLayer == rhs.lineLayer)
    return r
}
    
