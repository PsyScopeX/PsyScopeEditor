//
//  PSPortBuilder.swift
//  PsyScopeEditor
//
//  Created by James on 24/09/2014.
//

import Cocoa

class PSPortBuilderController: PSAttributePopup, NSOutlineViewDataSource, NSOutlineViewDelegate {

    init(currentValue: String, scriptData: PSScriptData, positionMode : Bool, setCurrentValueBlock : ((String) -> ())?){
        self.originalValue = currentValue
        self.functionName = positionMode ? "PointName" : "PortName"
        self.functionElement = PSFunctionElement()
        self.positionMode = positionMode
        self.portScript = PSPortScript(scriptData: scriptData)
        self.scriptData = scriptData
        super.init(nibName: "PortBuilder",bundle: NSBundle(forClass:self.dynamicType), currentValue: currentValue, displayName: "Port", setCurrentValueBlock: setCurrentValueBlock)
        
    }
    
    var registeredForChanges : Bool = false {
        willSet {
            if newValue != registeredForChanges {
                if newValue {
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: "docMocChanged:", name: NSManagedObjectContextObjectsDidChangeNotification, object: scriptData.docMoc)
                } else {
                    NSNotificationCenter.defaultCenter().removeObserver(self)
                }
            }
        }
    }
    
    deinit {
        registeredForChanges = false
    }
    
    //return value variables
    let functionName : String
    let originalValue : String
    let functionElement : PSFunctionElement
    
    var positionMode : Bool
    var scriptData : PSScriptData
    var portScript : PSPortScript

    //Main controls
    @IBOutlet var outlineView : PSPortBuilderOutlineView!
    @IBOutlet var mainPortWindow : NSWindow!
    @IBOutlet var previewView : PSPortPreviewView!
    @IBOutlet var newPositionButton : NSButton!
    @IBOutlet var chosenPortLabel : NSTextField!
    @IBOutlet var okButton : NSButton!
    @IBOutlet var editButton : NSButton!
    
    //Popover controllers
    @IBOutlet var portPopoverController : PSPortPopoverController!
    @IBOutlet var positionPopoverController : PSPositionPopoverController!
    

    //Selected object
    var selectedPort : PSPort?
    var selectedPosition : PSPosition?
    var preventSelectingObject : Bool = false  //prevent looping when using outline view delegate to make selections
    

    var initialized : Bool = false
    override func awakeFromNib() {
        super.awakeFromNib()
        if (!initialized) {
            
            //update ui to reflect mode
            if positionMode {
                okButton.title = "Select Postion"
            } else {
                okButton.title = "Select Port"
            }
            
            registeredForChanges = true
            refreshDisplay()
            
            //setting initialized to true now means we can get currently selected item from currentValue
            initialized = true
            
            //update function Element
            functionElement.stringValue = self.currentValue
            functionElement.functionName = functionName
            functionElement.bracketType = .Round
            
            //get selected value
            var values = functionElement.getStrippedStringValues()
            if !functionElement.foundErrors &&
                values.count == 1 &&
                functionElement.functionName == functionName
            {
                let selectedPoint = values[0]
                for port in portScript.portEntries {
                    if port.name == selectedPoint {
                        outlineView.expandItem(port)
                        outlineView.selectRowIndexes(NSIndexSet(index: outlineView.rowForItem(port)), byExtendingSelection: false)
                        break
                    }
                }
                for position in portScript.positionEntries {
                    if position.name == selectedPoint {
                        outlineView.expandItem(position.port)
                        outlineView.selectRowIndexes(NSIndexSet(index: outlineView.rowForItem(position)), byExtendingSelection: false)
                        break
                        
                    }
                }
            }
            
        }
    }
    
    //MARK: RefreshDisplay
    func docMocChanged(notification : NSNotification) {
        refreshDisplay()
    }
    
    
    func refreshDisplay() {
        //update controls from ports
        if let entireScreenPort = portScript.entireScreenPort {
            previewView.entireScreenPortLayer = entireScreenPort.layer
        }
        
        for portEntry in portScript.portEntries {
            displayPort(portEntry)
            for positionEntry in portEntry.positions {
                displayPosition(positionEntry)
            }
        }
        outlineView.reloadData()
        updateControls()
    }
    
    func updateControls() {
        if let selectedPort = selectedPort {
            newPositionButton.enabled = true
            
            if positionMode {
                if let selectedPosition = selectedPosition {
                    chosenPortLabel.stringValue = "Selected position: \(selectedPosition.name)"
                    functionElement.values = [PSEntryElement.StringToken(stringElement: PSStringElement(value: selectedPosition.name as String, quotes: .Doubles))]
                } else {
                    chosenPortLabel.stringValue = "No position selected"
                    functionElement.values = []
                }
            } else {
                chosenPortLabel.stringValue = "Selected port: \(selectedPort.name)"
                functionElement.values = [PSEntryElement.StringToken(stringElement: PSStringElement(value: selectedPort.name as String, quotes: .Doubles))]
            }
            
            if selectedPort.name == "Entire Screen" {
                editButton.enabled = false
            } else {
                editButton.enabled = true
            }
            
            if let selectedPosition = selectedPosition {
                outlineView.selectRowIndexes(NSIndexSet(index: outlineView.rowForItem(selectedPosition)), byExtendingSelection: false)
            } else {
                outlineView.selectRowIndexes(NSIndexSet(index: outlineView.rowForItem(selectedPort)), byExtendingSelection: false)
            }
 
        } else {
            if positionMode {
                chosenPortLabel.stringValue = "No position selected"
                functionElement.values = []
            } else {
                chosenPortLabel.stringValue = "No port selected"
                functionElement.values = []
            }
            newPositionButton.enabled = false
            editButton.enabled = false
        }
        
        if (initialized) {
            //prevent changing this during initialization
            self.currentValue = functionElement.stringValue
        }
        
    }
    
    //MARK: Opening Popovers
    
    //opens popover for selected item
    @IBAction func editButtonClick(sender : NSButton) {
        let row = outlineView.selectedRow
        let item: AnyObject? = outlineView.itemAtRow(row)
        positionPopoverController.close()
        portPopoverController.close()
        
        if let _ = item as? PSPort {
            
            if let selectedPort = selectedPort {
                if selectedPort.name != "Entire Screen" {
                    portPopoverController.show(sender)
                }
            }
        } else if let _ = item as? PSPosition {
            positionPopoverController.show(sender)
        }
        
        
    }
    
    //opens popover controller for port when right clicked in outline view
    func rightClickedPort(view : NSView) {
        positionPopoverController.close()
        if let selectedPort = selectedPort {
            if selectedPort.name != "Entire Screen" {
                portPopoverController.show(view)
            }
        }
    }
    
    //opens popover controller for position when right clicked in outline view
    func rightClickedPosition(view : NSView) {
        portPopoverController.close()
        positionPopoverController.show(view)
    }
    
    
    
    func selectLayer(layer : CALayer) {
        for (_, p) in portScript.portEntries.enumerate() {
            if p.layer === layer {
                selectPort(p)
                return
            }
        }
    }
    
    func updatePositionFromLayer(layer : CALayer, originalPosition: NSPoint) {
        for (_, p) in portScript.portEntries.enumerate() {
            if p.layer === layer {
                let res = PSScreenRes()
                let xDiff : Int = Int(layer.position.x - originalPosition.x)
                let yDiff : Int = 0 - Int(layer.position.y - originalPosition.y)
                p.x = p.x.transposeByPixels(xDiff, res: Int(res.width))
                p.y = p.y.transposeByPixels(yDiff, res: Int(res.height))
                return
            }
        }
    }
    
    //MARK: Selection methods
    
    func selectPosition(position : PSPosition) {
        if let sp = selectedPosition {
            sp.setHighlight(false)
            sp.updateLayer()
        }
        
        //select port 
        selectPort(position.port)
        selectedPosition = position
        positionPopoverController.updatePopoverControls(position)
        
        //highlight
        position.updateLayer()
        position.setHighlight(true)
        
        preventSelectingObject = true
        outlineView.selectRowIndexes(NSIndexSet(index: outlineView.rowForItem(position)), byExtendingSelection: false)
        preventSelectingObject = false
    }
    
    func selectPort(port : PSPort) {
        if let sp = selectedPort where port !== sp {
            //undo highlighting
            sp.updateLayer()
            sp.setHighlight(false)
        }
        
        if let sp = selectedPosition {
            sp.setHighlight(false)
        }
        
        selectedPosition = nil
        selectedPort = port
        portPopoverController.updatePopoverControls(port)
        port.updateLayer()
        port.setHighlight(true)
        preventSelectingObject = true
        outlineView.selectRowIndexes(NSIndexSet(index: outlineView.rowForItem(port)), byExtendingSelection: false)
        preventSelectingObject = false
    }
    
    //MARK: Outline view
    
    func outlineViewSelectionDidChange(notification: NSNotification) {
        
        if preventSelectingObject { return }
        
        var selected_item : AnyObject? = outlineView.itemAtRow(outlineView.selectedRow)
        
        if let port = selected_item as? PSPort {
            editButton.enabled = true
            selectPort(port)
            
            if portPopoverController.shown || positionPopoverController.shown {
                positionPopoverController.close()
                var clickedCol = outlineView.selectedColumn
                var clickedRow = outlineView.selectedRow
                
                if clickedRow > -1 && port.name != "Entire Screen" {
                    if let view = outlineView.viewAtColumn(clickedCol, row: clickedRow, makeIfNecessary: false) {
                        portPopoverController.show(view)
                        return
                    }
                }
                portPopoverController.close()
            }
        } else if let position = selected_item as? PSPosition {
            editButton.enabled = true
            selectPosition(position)
            
            if portPopoverController.shown || positionPopoverController.shown {
                portPopoverController.close()
                var clickedCol = outlineView.selectedColumn
                var clickedRow = outlineView.selectedRow
                
                if clickedRow > -1 {
                    if let view = outlineView.viewAtColumn(clickedCol, row: clickedRow, makeIfNecessary: false) {
                        positionPopoverController.show(view)
                        return
                    }
                }
                positionPopoverController.close()
            }
        } else {
            //no selected
            editButton.enabled = false
        }
        updateControls()
    }
    
    
    func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
        if (item == nil) {
            return portScript.portEntries.count
        }
        
        if let port = item as? PSPort {
            return port.positions.count
        }
        return 0
    }
    
    func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        if (item == nil) {
            return portScript.portEntries[index]
        }
        if let port = item as? PSPort {
            return port.positions[index]
        }
        return ""
    }
    
    func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
        if let port = item as? PSPort {
            if port.positions.count > 0 {
                return true
            }
        }
        return false
    }
    
    func outlineView(outlineView: NSOutlineView, objectValueForTableColumn tableColumn: NSTableColumn?, byItem item: AnyObject?) -> AnyObject? {
        if let port = item as? PSPort {
            return port.name
        }
        
        if let position = item as? PSPosition {
            return position.name
        }
        return ""
    }
    
    //MARK: Routines to display ports/ positions
    
    func displayPort(port : PSPort) {
        previewView.screenLayer.addSublayer(port.layer)
        port.updateLayer()
    }
    
    func displayPosition(position : PSPosition) {
        previewView.screenLayer.addSublayer(position.layer)
        position.updateLayer()
    }
    
    //MARK: New port/position buttons
    
    @IBAction func newPortButton(_: AnyObject) {
        let name = scriptData.getNextFreeBaseEntryName("Port")
        portScript.addPort(name)
    }
    
    @IBAction func newPositionButtonClick(_: AnyObject) {
        let name = scriptData.getNextFreeBaseEntryName("Position")
        portScript.addPosition(name, port: selectedPort!)
    }
    
    //MARK: Delete button / menu item
    // returns false if needs to show a dialog
    func deleteCurrentlySelectedItem() -> Bool {
        
        if (!itemIsCurrentlySelected()) {
            NSBeep()
            return true
        }
        let selectedRow = outlineView.selectedRow
        let selected_item : AnyObject? = outlineView.itemAtRow(selectedRow)
        
        if let port = selected_item as? PSPort {
            //warn if referenced
            let referencedEntries = scriptData.searchForEntriesWithReference(port.name as String, entries: scriptData.getBaseEntries().filter({  $0.name != "PortNames" }))
            
            if referencedEntries.count > 0 {
                let alert = NSAlert()
                
                let entryNames = "\n".join(referencedEntries.map { $0.name })
                
                alert.messageText = "This port is referenced in the following entries:\n\n" + entryNames
                alert.addButtonWithTitle("Yes")
                alert.addButtonWithTitle("No")
                alert.informativeText = "If you delete the port, you will have to update these references manually, are you sure you wish to continue?"

                alert.beginSheetModalForWindow(mainPortWindow, completionHandler: {  (returnCode : NSModalResponse) -> Void in
                    if returnCode == NSAlertFirstButtonReturn {
                        self.deleteItemAtRow(selectedRow)
                    }
                    })
                return false
            } else {
                //delete
                self.deleteItemAtRow(selectedRow)
            }
        } else if let position = selected_item as? PSPosition  {
            //warn if referenced
            let referencedEntries = scriptData.searchForEntriesWithReference(position.name as String, entries: scriptData.getBaseEntries()).filter({ $0 !== position.port.entry })
            
            if referencedEntries.count > 0 {
                let alert = NSAlert()
                let entryNames = "\n".join(referencedEntries.map{ $0.name })
                
                alert.messageText = "This position is referenced in the following entries:\n\n" + entryNames
                alert.addButtonWithTitle("Yes")
                alert.addButtonWithTitle("No")
                alert.informativeText = "If you delete the position, you will have to update these references manually, are you sure you wish to continue?"
                
                alert.beginSheetModalForWindow(mainPortWindow, completionHandler: {  (returnCode : NSModalResponse) -> Void in
                    if returnCode == NSAlertFirstButtonReturn {
                        self.deleteItemAtRow(selectedRow)
                    }
                })
                return false
            } else {
                //delete
                self.deleteItemAtRow(selectedRow)
            }
        }
        
        return true
    }
    
    func deleteItemAtRow(row : Int) {
        let selected_item : AnyObject? = outlineView.itemAtRow(row)
        
        if let port = selected_item as? PSPort {
            portScript.deletePort(port)
            if self.selectedPort === port { self.selectedPort = nil }
        } else if let position = selected_item as? PSPosition  {
            portScript.deletePosition(position)
            if selectedPosition === position { selectedPosition = nil }
        }
        //move selection down if item was last item
        var selectedRow = row
        if selectedRow >= outlineView.numberOfRows {
            selectedRow -= 1
        }
        
        outlineView.selectRowIndexes(NSIndexSet(index: selectedRow), byExtendingSelection: false)
    }
    
    func itemIsCurrentlySelected() -> Bool {
        return outlineView.selectedRow != -1
    }
    
    //MARK: Cancel button
    
    @IBAction func cancelButton(_: AnyObject) {
        self.currentValue = originalValue
        closeMyCustomSheet(self)
    }
    
    func deSelect() {
        selectedPort = nil
    }
    
    @IBAction func fullScreenButton(_: AnyObject) {
        previewView.goFullScreen()
    }
}
