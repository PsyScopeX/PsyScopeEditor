//
//  PSPortBuilder.swift
//  PsyScopeEditor
//
//  Created by James on 24/09/2014.
//

import Cocoa

open class PSPortBuilderController: NSObject, NSOutlineViewDataSource, NSOutlineViewDelegate {
    
    
    internal var currentValue : String
    internal var displayName : String
    internal var nibName : String
    internal var bundle : Bundle
    @IBOutlet internal var attributeSheet : NSWindow!
    internal var topLevelObjects : NSArray?
    internal var parentWindow : NSWindow!
    internal var setCurrentValueBlock : ((PSEntryElement) -> ())?
    
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
    

    open func showAttributeModalForWindow(_ window : NSWindow) {
        if (attributeSheet == nil) {
            bundle.loadNibNamed(nibName, owner: self, topLevelObjects: &topLevelObjects)
        }
        
        parentWindow = window
        
        parentWindow.beginSheet(attributeSheet, completionHandler: {
            (response : NSModalResponse) -> () in
            //NSApp.stopModalWithCode(response)
            
            
        })
        //NSApp.runModalForWindow(attributeSheet)
    }
    
    @IBAction open func closeMyCustomSheet(_: AnyObject) {
        parentWindow.endSheet(attributeSheet)
        if let setCurrentValueBlock = setCurrentValueBlock {
            setCurrentValueBlock(PSGetFirstEntryElementForStringOrNull(self.currentValue))
        }
    }
    

    public init(currentValue: PSEntryElement, scriptData: PSScriptData, positionMode : Bool, setCurrentValueBlock : ((PSEntryElement) -> ())?){
        self.originalValue = currentValue.stringValue()
        self.functionName = positionMode ? "PointName" : "PortName"
        self.functionElement = PSFunctionElement()
        self.positionMode = positionMode
        self.portScript = PSPortScript(scriptData: scriptData)
        self.scriptData = scriptData
        self.currentValue = currentValue.stringValue()
        self.nibName = "PortBuilder"
        self.bundle = Bundle(for:self.dynamicType)
        self.displayName = "Port"
        self.setCurrentValueBlock = setCurrentValueBlock
        super.init()
        
    }
    

    
    var registeredForChanges : Bool = false {
        willSet {
            if newValue != registeredForChanges {
                if newValue {
                    NotificationCenter.default.addObserver(self, selector: "refreshNotification:", name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: scriptData.docMoc)

                    NotificationCenter.default.addObserver(self, selector: "refreshNotification:", name: PSScreenChangeNotification, object: nil)
                } else {
                    NotificationCenter.default.removeObserver(self)
                }
            }
        }
    }
    
    deinit {
        registeredForChanges = false
    }
    
    
    override open func awakeFromNib() {
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
            
            //update the outline view's data
            outlineView.reloadData()
            
            //setting initialized to true now means we can get currently selected item from currentValue
            initialized = true
            
            //update function Element
            functionElement.stringValue = self.currentValue
            functionElement.functionName = functionName
            functionElement.bracketType = .round
            
            //get selected value
            var values = functionElement.getStrippedStringValues()
            if !functionElement.foundErrors &&
                values.count == 1 &&
                functionElement.functionName == functionName
            {
                let selectedItem = values[0]
                for port in portScript.portEntries {
                    if port.name == selectedItem {
                        self.selectPort(port)
                        return
                    }
                }
                for position in portScript.positionEntries {
                    if position.name == selectedItem {
                        self.selectPosition(position)
                        return
                    }
                }
            }
        }
    }
    
    //MARK: RefreshDisplay
    func refreshNotification(_ notification : Notification) {
        refreshDisplay()
    }
    
    
    func DisplayCallback(_ :CGDirectDisplayID, _: CGDisplayChangeSummaryFlags,_: UnsafeMutableRawPointer) -> Void {
        //reset caches
        PSScreen.cached = false
    }
    
    
    func refreshDisplay() {
        //update controls from ports
        previewView.resetDisplayToScreensOnly()
        
        //now add all the port and position layers
        for port in portScript.portEntries {
            port.updateLayer()
            previewView.addNewPort(port)
        }
        
        for position in portScript.positionEntries { previewView.addNewPosition(position) }
        
        //set up the entire screen port (special, cant be clicked)
        if let entireScreenPort = portScript.entireScreenPort {
            previewView.setEntireScreenPort(entireScreenPort)
        }
        
        //check if selected port / positionstill exists + update popovers
        if let selectedPort = selectedPort where portScript.portEntries.contains(selectedPort) {
            
            portPopoverController.updatePopoverControls(selectedPort)
            if let selectedPosition = selectedPosition where portScript.positionEntries.contains(selectedPosition) {
                    positionPopoverController.updatePopoverControls(selectedPosition)
            } 
        } else {
            self.selectedPort = nil
            self.selectedPosition = nil
        }
        
        //remember which controller was being shown
        
        //let showingPortPopover = portPopoverController.shown
        
        
    
        //update the other controls (e.g. buttons and visual selection)
        updateControls()
        
        /*
        if showingPositionPopover {
            if positionPopoverController.view == editButton {
                positionPopoverController.show(editButton)
            } else if let view = outlineView.viewAtColumn(0, row: outlineView.rowForItem(selectedPosition), makeIfNecessary: true) {
                    positionPopoverController.show(view)
                }

        } else if showingPortPopover {
            if portPopoverController.view == editButton {
                portPopoverController.show(editButton)
            } else if let view = outlineView.viewAtColumn(0, row: outlineView.rowForItem(selectedPort), makeIfNecessary: true) {
                portPopoverController.show(view)
            }
        }*/
        
    }
    
    func updateControls() {
        if let selectedPort = selectedPort {
            newPositionButton.isEnabled = true
            
            if positionMode {
                if let selectedPosition = selectedPosition {
                    chosenPortLabel.stringValue = "Selected position: \(selectedPosition.name)"
                    functionElement.values = [PSEntryElement.stringToken(stringElement: PSStringElement(value: selectedPosition.name as String, quotes: .doubles))]
                } else {
                    chosenPortLabel.stringValue = "No position selected"
                    functionElement.values = []
                }
            } else {
                chosenPortLabel.stringValue = "Selected port: \(selectedPort.name)"
                functionElement.values = [PSEntryElement.stringToken(stringElement: PSStringElement(value: selectedPort.name as String, quotes: .doubles))]
            }
            
            if selectedPort.name == "Entire Screen" {
                editButton.isEnabled = false
            } else {
                editButton.isEnabled = true
            }
            
            /*
            preventSelectingObject = true
            if let selectedPosition = selectedPosition {
                outlineView.selectRowIndexes(NSIndexSet(index: outlineView.rowForItem(selectedPosition)), byExtendingSelection: false)
            } else {
                outlineView.selectRowIndexes(NSIndexSet(index: outlineView.rowForItem(selectedPort)), byExtendingSelection: false)
            }
            preventSelectingObject = false*/
 
        } else {
            if positionMode {
                chosenPortLabel.stringValue = "No position selected"
                functionElement.values = []
            } else {
                chosenPortLabel.stringValue = "No port selected"
                functionElement.values = []
            }
            newPositionButton.isEnabled = false
            editButton.isEnabled = false
            outlineView.deselectAll(nil)
        }
        
        if (initialized) {
            //prevent changing this during initialization
            self.currentValue = functionElement.stringValue
        }
        
    }
    
    //MARK: Opening Popovers
    
    //opens popover for selected item
    @IBAction func editButtonClick(_ sender : NSButton) {
        let row = outlineView.selectedRow
        let item: AnyObject? = outlineView.item(atRow: row)
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
    func rightClickedPort(_ view : NSView) {
        positionPopoverController.close()
        if let selectedPort = selectedPort {
            if selectedPort.name != "Entire Screen" {
                portPopoverController.show(view)
            }
        }
    }
    
    //opens popover controller for position when right clicked in outline view
    func rightClickedPosition(_ view : NSView) {
        portPopoverController.close()
        positionPopoverController.show(view)
    }
    
    
    
    func selectLayer(_ layer : CALayer) {
        for (_, p) in portScript.portEntries.enumerated() {
            if p.layer === layer {
                selectPort(p)
                return
            }
        }
    }
    
    func updatePositionFromLayer(_ layer : CALayer, originalPosition: NSPoint) {
        for port in portScript.portEntries {
            if port.layer === layer {
                let res = PSScreen.getEffectiveResolution()
                let xDiff : Int = Int(layer.position.x - originalPosition.x)
                let yDiff : Int = Int(layer.position.y - originalPosition.y)
                port.x = port.x.transposeByPixels(xDiff, res: Int(res.width))
                port.y = port.y.transposeByPixels(yDiff, res: Int(res.height))
                return
            }
        }
    }
    
    //MARK: Selection methods
    
    func selectPosition(_ position : PSPosition) {
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
        outlineView.selectRowIndexes(IndexSet(integer: outlineView.row(forItem: position)), byExtendingSelection: false)
        preventSelectingObject = false
    }
    
    func selectPort(_ port : PSPort) {
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
        outlineView.selectRowIndexes(IndexSet(integer: outlineView.row(forItem: port)), byExtendingSelection: false)
        preventSelectingObject = false
    }
    
    //MARK: Outline view
    
    open func outlineViewSelectionDidChange(_ notification: Notification) {
        
        if preventSelectingObject { return }
        
        let selected_item : AnyObject? = outlineView.item(atRow: outlineView.selectedRow)
        
        if let port = selected_item as? PSPort {

                editButton.isEnabled = true
                selectPort(port)
                
                if portPopoverController.shown || positionPopoverController.shown {
                    positionPopoverController.close()
                    let clickedCol = outlineView.selectedColumn
                    let clickedRow = outlineView.selectedRow
                    
                    if clickedRow > -1 && port.name != "Entire Screen" {
                        if let view = outlineView.view(atColumn: clickedCol, row: clickedRow, makeIfNecessary: false) {
                            portPopoverController.show(view)
                            return
                        }
                    }
                    portPopoverController.close()
                }
       
        } else if let position = selected_item as? PSPosition {

                editButton.isEnabled = true
                selectPosition(position)
                
                if portPopoverController.shown || positionPopoverController.shown {
                    portPopoverController.close()
                    let clickedCol = outlineView.selectedColumn
                    let clickedRow = outlineView.selectedRow
                    
                    if clickedRow > -1 {
                        if let view = outlineView.view(atColumn: clickedCol, row: clickedRow, makeIfNecessary: false) {
                            positionPopoverController.show(view)
                            return
                        }
                    }
                    positionPopoverController.close()
                }
     
        } else {
            //no selected
            editButton.isEnabled = false
            positionPopoverController.close()
            portPopoverController.close()
        }
        updateControls()
    }
    
    
    open func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if (item == nil) {
            return portScript.portEntries.count
        }
        
        if let port = item as? PSPort {
            return port.positions.count
        }
        return 0
    }
    
    open func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if (item == nil) {
            return portScript.portEntries[index]
        }
        if let port = item as? PSPort {
            return port.positions[index]
        }
        return ""
    }
    
    open func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let port = item as? PSPort {
            if port.positions.count > 0 {
                return true
            }
        }
        return false
    }
    
    open func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        if let port = item as? PSPort {
            return port.name
        }
        
        if let position = item as? PSPosition {
            return position.name
        }
        return ""
    }

    
    //MARK: New port/position buttons
    
    @IBAction func newPortButton(_: AnyObject) {
        let name = scriptData.getNextFreeBaseEntryName("Port")
        if let port = portScript.addPort(name) {
            previewView.addNewPort(port)
        }
        //update the outline view's data
        outlineView.reloadData()
        refreshDisplay()
    }
    
    @IBAction func newPositionButtonClick(_: AnyObject) {
        guard let currentSelectedPort = selectedPort else { return }
        let name = scriptData.getNextFreeBaseEntryName("Position")
        if let position = portScript.addPosition(name, port: currentSelectedPort) {
            previewView.addNewPosition(position)
        }
        //update the outline view's data
        outlineView.reloadData()
        refreshDisplay()
    }
    
    //MARK: Delete button / menu item
    // returns false if needs to show a dialog
    func deleteCurrentlySelectedItem() -> Bool {
        
        if (!itemIsCurrentlySelected()) {
            NSBeep()
            return true
        }
        let selectedRow = outlineView.selectedRow
        let selected_item : AnyObject? = outlineView.item(atRow: selectedRow)
        
        if let port = selected_item as? PSPort {
            //warn if referenced
            let referencedEntries = scriptData.searchForEntriesWithReference(port.name as String, entries: scriptData.getBaseEntries().filter({  $0.name != "PortNames" }))
            
            if referencedEntries.count > 0 {
                let alert = NSAlert()
                
                let entryNames = referencedEntries.map { $0.name }.joined(separator: "\n")
                
                alert.messageText = "This port is referenced in the following entries:\n\n" + entryNames
                alert.addButton(withTitle: "Yes")
                alert.addButton(withTitle: "No")
                alert.informativeText = "If you delete the port, you will have to update these references manually, are you sure you wish to continue?"

                alert.beginSheetModal(for: mainPortWindow, completionHandler: {  (returnCode : NSModalResponse) -> Void in
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
                let entryNames = referencedEntries.map{ $0.name }.joined(separator: "\n")
                
                alert.messageText = "This position is referenced in the following entries:\n\n" + entryNames
                alert.addButton(withTitle: "Yes")
                alert.addButton(withTitle: "No")
                alert.informativeText = "If you delete the position, you will have to update these references manually, are you sure you wish to continue?"
                
                alert.beginSheetModal(for: mainPortWindow, completionHandler: {  (returnCode : NSModalResponse) -> Void in
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
    
    func deleteItemAtRow(_ row : Int) {
        let selected_item : AnyObject? = outlineView.item(atRow: row)
        
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
        //update the outline view's data
        outlineView.reloadData()
        refreshDisplay()
        
        outlineView.selectRowIndexes(IndexSet(integer: selectedRow), byExtendingSelection: false)
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
