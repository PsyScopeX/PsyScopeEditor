//
//  PSCondition_Key.swift
//  PsyScopeEditor
//
//  Created by James on 16/11/2014.
//

import Foundation
import Carbon
import CoreServices

class PSCondition_Key : PSCondition {
    override init() {
        super.init()
        expandedHeight = 51
        typeString = "Key"
        userFriendlyNameString = "Keyboard"
        helpfulDescriptionString = "This condition is used to watch for input from the standard Macintosh keyboard. This device can detect single key presses or combinations of keys using Command-, Shift-, Control-, and Option- modifiers."

    }
    
    override func nib() -> NSNib! {
        return NSNib(nibNamed: "Condition_KeyCell", bundle: NSBundle(forClass:self.dynamicType))
    }
    
    override func icon() -> NSImage! {
        let image : NSImage = NSImage(contentsOfFile: NSBundle(forClass:self.dynamicType).pathForImageResource("Key")!)!
        return image
    }
    
    override func isInputDevice() -> Bool {
        return true
    }
}

class PSCondition_Key_Popup : PSAttributePopup, NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate, NSMenuDelegate {

    @IBOutlet var segmentedControl : NSSegmentedControl!
    @IBOutlet var tableView : NSTableView!
    @IBOutlet var windowListener : PSKeyListenerWindow!
    @IBOutlet var actionsMenu : NSMenu!
    var pressedKeys : [PSCondition_Key_Key]
    var selectedRow : Int = -1 {
        didSet {
            updateSegmentedControl(selectedRow)
            
        }
    }
    
    init(currentValue: String, setCurrentValueBlock : ((String)->())?){
        
        pressedKeys = []
        let inputValue = currentValue.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        for aKey in inputValue {
            pressedKeys.append(PSCondition_Key_Key(fromString: aKey))
        }
        super.init(nibName: "KeyCondition",bundle: NSBundle(forClass:self.dynamicType), currentValue: currentValue, displayName: "Key", setCurrentValueBlock: setCurrentValueBlock)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        segmentedControl.setMenu(actionsMenu, forSegment: 2)
        updateSegmentedControl(selectedRow)
        self.attributeSheet.addObserver(self, forKeyPath: "firstResponder", options: .New, context: nil)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "firstResponder" {
            if attributeSheet.firstResponder != tableView {
                tableView.deselectAll(self)
                selectedRow = -1 //this will disable the remove and actions buttons
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return pressedKeys.count
    }
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        return pressedKeys[row].toDisplayString()
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let view = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: self) as! NSTableCellView
        view.textField!.editable = false
        return view
    }
    

    func tableViewSelectionDidChange(notification: NSNotification) {
        selectedRow = tableView.selectedRow
    }
    
    //importantly this reinstates the selection
    func reloadTableView() {
        tableView.reloadData()
        let validSelection = selectedRow >= 0 && selectedRow < pressedKeys.count
        if validSelection {
            tableView.selectRowIndexes(NSIndexSet(index: selectedRow), byExtendingSelection: false)
        } else {
            tableView.deselectAll(self)
        }
    }
    
    
    func menuNeedsUpdate(menu: NSMenu) {
        let validSelection = tableView.clickedRow >= 0 && tableView.selectedRow < pressedKeys.count
        if validSelection {
            tableView.selectRowIndexes(NSIndexSet(index: tableView.clickedRow), byExtendingSelection: false)
        }
        for item in menu.itemArray as [NSMenuItem]{
            item.enabled = validSelection
        }
    }
   
    
    func updateSegmentedControl(row : Int) {
        let validSelection = (row >= 0 && row < pressedKeys.count)
        windowListener.listening = validSelection
        segmentedControl.setEnabled(validSelection, forSegment: 1)
        segmentedControl.setEnabled(validSelection, forSegment: 2)
        let allowAnyButton = validSelection && !pressedKeys[row].any
        anyButton.enabled = allowAnyButton
    }
    
    @IBAction func onKeyUpMenuItemSelected(sender : NSMenuItem) {
        pressedKeys[selectedRow].keyUp = true
        reloadTableView()
    }
    
    @IBAction func onKeyDownMenuItemSelected(sender : NSMenuItem) {
        pressedKeys[selectedRow].keyUp = false
        reloadTableView()
    }
    
    @IBAction func actionsSegmentedControlClicked(sender : AnyObject) {
        switch(segmentedControl.selectedSegment) {
        case 0:
            //add
            pressedKeys.append(PSCondition_Key_Key(fromString: " "))

        case 1:
            //delete selected
            if selectedRow >= 0 && selectedRow < pressedKeys.count {
                pressedKeys.removeAtIndex(selectedRow)
            }
            
        default:
            break
        }
        selectedRow = -1
        reloadTableView()
    }
    
    @IBAction func anyButtonClicked(sender : NSButton) {
        pressedKeys[tableView.selectedRow].any = true
        anyButton.enabled = false
        tableView.reloadData()
    }
    @IBOutlet var anyButton : NSButton!
    
    func keyDown(theEvent: NSEvent) {
        if let key = PSCondition_Key_Key(fromEvent: theEvent) {
            pressedKeys[selectedRow] = key
            selectedRow = -1
            reloadTableView()
        } else {
            NSBeep()
        }
    }
    
    override func closeMyCustomSheet(sender: AnyObject) {
        var outputString = ""
        self.attributeSheet.removeObserver(self, forKeyPath: "firstResponder")
        for k in pressedKeys {
            outputString += "\(k.toScriptString()) "
        }
        self.currentValue = outputString
        
        super.closeMyCustomSheet(sender)
    }
}

class PSCondition_Key_Key : NSObject {
    var character : String
    var shift : Bool
    var control : Bool
    var keyUp : Bool
    var any : Bool
    init?(fromEvent event : NSEvent) {
        any = false
        keyUp = false
        if event.modifierFlags.contains(.ControlKeyMask) {
            control = true
        } else {
            control = false
        }
        
        if event.modifierFlags.contains(.ShiftKeyMask) {
            shift = true
        } else {
            shift = false
        }
        
        self.character = PSUnicodeUtilities.characterForEventWithoutModifiers(event)
        //character = event.charactersIgnoringModifiers!.lowercaseString
        
       
        let keepCharacters = NSMutableCharacterSet.lowercaseLetterCharacterSet()
        keepCharacters.addCharactersInString(" ,./;'[]-=`")
        let removeCharacters = keepCharacters.invertedSet
        character = (character.componentsSeparatedByCharactersInSet(removeCharacters) as NSArray).componentsJoinedByString("")
        
        if character == "" {
            self.any = false
            self.keyUp = false
            self.control = false
            self.shift = false
            self.character = ""
            super.init()
            return nil
        }
        super.init()
    }
    
    init(fromString string: String) {
        /*
        Key[ANY/key-list]
        Given the ANY parameter, this condition matches when any non-modifier key is hit
        on the standard Macintosh keyboard.
        Otherwise, a list of key combinations is specified; the condition will match when any one of the specified combinations is hit.
        A key combination is made up of any number of modifiers keys and a base (non- modifier) key. The base key can be specified as:
        • the letter, number, or symbol that appears on the key on the keyboard. If a letter is specified, the case (uppercase/lowercase) of the letter is ignored. If a symbol is given that requires the shift key to be typed, the shift key will be required for a match (but the SHIFT- prefix should not be used – see below).
        • the ASCII- keyword followed by a number. The condition will match when the correct combination of keys is pressed to type the character with the given ASCII value. Only the shift key may be used to generate the ASCII character; characters generated by using the option key can not be matched this way.
        • the CODE- keyword followed by a number which corresponds to a unique key on the keyboard; key code numbers are defined in Macintosh program- ming documentation. This method of specifying is key is somewhat key- board-specific, but allows you to use all keys on the keyboard. Modifier keys cannot be matched this way.
        • the SPACE keyword, representing the space bar.
        • the RETURN keyword, representing the return key.
        To specify a key combination containing modifiers, prefixes are added to one of the base forms described above. The CMD- prefix matches only when the command key is held down at the same time as the base key. Similarly, CTL- matches with the con- trol key and OPT- matches with the option key. SHIFT- matches with the shift key only when it is not already represented in the base character (e.g.: SHIFT-* can nev- er match, since * – which is the same as SHIFT-8 – already contains SHIFT).
        */
        var unquoted = string.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "\""))
        
        if let r = unquoted.lowercaseString.rangeOfString("any") {
            any = true
            unquoted.removeRange(r)
        } else {
            any = false
        }
        
        if let r = unquoted.lowercaseString.rangeOfString("up-") {
            keyUp = true
            unquoted.removeRange(r)
        } else {
            keyUp = false
        }
        if let r = unquoted.lowercaseString.rangeOfString("ctl-") {
            control = true
            unquoted.removeRange(r)
        } else {
            control = false
        }
        if let r = unquoted.lowercaseString.rangeOfString("shift-") {
            shift = true
            unquoted.removeRange(r)
        } else {
            shift = false
        }
        
        if let _ = unquoted.lowercaseString.rangeOfString("space") {
            character = " "
        } else {
            if unquoted.utf16.count > 0 {
                character = unquoted.substringFromIndex(unquoted.endIndex.predecessor())
            } else {
                character = "" //default to any
                any = true
            }
        }
    }
    
    func toDisplayString() -> String {
        if any { return "Any" }
        var outputString = ""
        if control { outputString += "Ctrl-" }
        if shift { outputString += "Shift-" }
        if character == " " { outputString += "Space" }
        else { outputString += character }
        if keyUp { outputString += "-Up" }
        return outputString
    }
    
    func toScriptString() -> String {
        if any { return "Any" }
        var outputString = "\""
        if keyUp { outputString += "UP-" }
        if control { outputString += "CTL-" }
        if shift { outputString += "SHIFT-" }
        if character == " " { outputString += "SPACE" }
        else { outputString += character }
        outputString += "\""
        return outputString
    }
}

class PSCondition_Key_Cell : PSConditionCell {
    @IBOutlet var button : NSButton!
    
    override func setup(conditionInterface: PSConditionInterface, function entryFunction: PSFunctionElement, scriptData: PSScriptData, expandedHeight: CGFloat) {
        super.setup(conditionInterface,function: entryFunction,scriptData: scriptData, expandedHeight: expandedHeight)
        button.title = entryFunction.getParametersStringValue()
    }
    
    @IBAction func buttonPressed(sender : NSButton) {
        let popup = PSCondition_Key_Popup(currentValue: self.entryFunction.getParametersStringValue(), setCurrentValueBlock : { (cValue: String) -> () in
            self.entryFunction.setStringValues([cValue])
            self.button.title = cValue
            self.updateScript()
        })
        popup.showAttributeModalForWindow(scriptData.window)
    }
}

class PSKeyListenerWindow : NSWindow {
    var controller : PSCondition_Key_Popup!
    var listening : Bool = false
    override func keyDown(theEvent: NSEvent) {
        if listening {
            controller.keyDown(theEvent)
        } else {
            super.keyDown(theEvent)
        }
    }
}

