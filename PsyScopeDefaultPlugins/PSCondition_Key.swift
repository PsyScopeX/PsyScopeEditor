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
    
    override func nib() -> NSNib {
        return NSNib(nibNamed: "Condition_KeyCell", bundle: Bundle(for:Swift.type(of: self)))!
    }
    
    override func icon() -> NSImage {
        let image : NSImage = NSImage(contentsOfFile: Bundle(for:Swift.type(of: self)).pathForImageResource("Key")!)!
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
    
    init(currentValue: PSEntryElement, setCurrentValueBlock : ((PSEntryElement)->())?){
        
        pressedKeys = []
        let inputValue = currentValue.stringValue().trimmingCharacters(in: CharacterSet.whitespaces).components(separatedBy: CharacterSet.whitespaces)
        for aKey in inputValue {
            pressedKeys.append(PSCondition_Key_Key(fromString: aKey))
        }
        super.init(nibName: "KeyCondition",bundle: Bundle(for:type(of: self)), currentValue: currentValue, displayName: "Key", setCurrentValueBlock: setCurrentValueBlock)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        segmentedControl.setMenu(actionsMenu, forSegment: 2)
        updateSegmentedControl(selectedRow)
        self.attributeSheet.addObserver(self, forKeyPath: "firstResponder", options: .new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "firstResponder" {
            if attributeSheet.firstResponder != tableView {
                tableView.deselectAll(self)
                selectedRow = -1 //this will disable the remove and actions buttons
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return pressedKeys.count
    }
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return pressedKeys[row].toDisplayString()
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let view = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        view.textField!.isEditable = false
        return view
    }
    

    func tableViewSelectionDidChange(_ notification: Notification) {
        selectedRow = tableView.selectedRow
    }
    
    //importantly this reinstates the selection
    func reloadTableView() {
        tableView.reloadData()
        let validSelection = selectedRow >= 0 && selectedRow < pressedKeys.count
        if validSelection {
            tableView.selectRowIndexes(IndexSet(integer: selectedRow), byExtendingSelection: false)
        } else {
            tableView.deselectAll(self)
        }
    }
    
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        let validSelection = tableView.clickedRow >= 0 && tableView.selectedRow < pressedKeys.count
        if validSelection {
            tableView.selectRowIndexes(IndexSet(integer: tableView.clickedRow), byExtendingSelection: false)
        }
        for item in menu.items as [NSMenuItem]{
            item.isEnabled = validSelection
        }
    }
   
    
    func updateSegmentedControl(_ row : Int) {
        let validSelection = (row >= 0 && row < pressedKeys.count)
        windowListener.listening = validSelection
        segmentedControl.setEnabled(validSelection, forSegment: 1)
        segmentedControl.setEnabled(validSelection, forSegment: 2)
        let allowAnyButton = validSelection && !pressedKeys[row].any
        anyButton.isEnabled = allowAnyButton
    }
    
    @IBAction func onKeyUpMenuItemSelected(_ sender : NSMenuItem) {
        pressedKeys[selectedRow].keyUp = true
        reloadTableView()
    }
    
    @IBAction func onKeyDownMenuItemSelected(_ sender : NSMenuItem) {
        pressedKeys[selectedRow].keyUp = false
        reloadTableView()
    }
    
    @IBAction func actionsSegmentedControlClicked(_ sender : AnyObject) {
        switch(segmentedControl.selectedSegment) {
        case 0:
            //add
            pressedKeys.append(PSCondition_Key_Key(fromString: " "))

        case 1:
            //delete selected
            if selectedRow >= 0 && selectedRow < pressedKeys.count {
                pressedKeys.remove(at: selectedRow)
            }
            
        default:
            break
        }
        selectedRow = -1
        reloadTableView()
    }
    
    @IBAction func anyButtonClicked(_ sender : NSButton) {
        pressedKeys[tableView.selectedRow].any = true
        anyButton.isEnabled = false
        tableView.reloadData()
    }
    @IBOutlet var anyButton : NSButton!
    
    func keyDown(_ theEvent: NSEvent) {
        if let key = PSCondition_Key_Key(fromEvent: theEvent) {
            pressedKeys[selectedRow] = key
            selectedRow = -1
            reloadTableView()
        } else {
            NSBeep()
        }
    }
    
    override func closeMyCustomSheet(_ sender: AnyObject) {
        var outputString = ""
        self.attributeSheet.removeObserver(self, forKeyPath: "firstResponder")
        for k in pressedKeys {
            outputString += "\(k.toScriptString()) "
        }
        self.currentValue = PSGetListElementForString(outputString)
        
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
        if event.modifierFlags.contains(.control) {
            control = true
        } else {
            control = false
        }
        
        if event.modifierFlags.contains(.shift) {
            shift = true
        } else {
            shift = false
        }
        
        self.character = PSUnicodeUtilities.character(forEventWithoutModifiers: event)
        //character = event.charactersIgnoringModifiers!.lowercaseString
        
       
        let keepCharacters = NSMutableCharacterSet.lowercaseLetter()
        keepCharacters.addCharacters(in: " ,./;'[]-=`")
        let removeCharacters = keepCharacters.inverted
        character = (character.components(separatedBy: removeCharacters) as NSArray).componentsJoined(by: "")
        
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
        var unquoted = string.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
        
        if let r = unquoted.lowercased().range(of: "any") {
            any = true
            unquoted.removeSubrange(r)
        } else {
            any = false
        }
        
        if let r = unquoted.lowercased().range(of: "up-") {
            keyUp = true
            unquoted.removeSubrange(r)
        } else {
            keyUp = false
        }
        if let r = unquoted.lowercased().range(of: "ctl-") {
            control = true
            unquoted.removeSubrange(r)
        } else {
            control = false
        }
        if let r = unquoted.lowercased().range(of: "shift-") {
            shift = true
            unquoted.removeSubrange(r)
        } else {
            shift = false
        }
        
        if let _ = unquoted.lowercased().range(of: "space") {
            character = " "
        } else {
            if unquoted.utf16.count > 0 {
                character = unquoted.substring(from: unquoted.characters.index(before: unquoted.endIndex))
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
    
    override func setup(_ conditionInterface: PSConditionInterface, function entryFunction: PSFunctionElement, scriptData: PSScriptData, expandedHeight: CGFloat) {
        super.setup(conditionInterface,function: entryFunction,scriptData: scriptData, expandedHeight: expandedHeight)
        button.title = entryFunction.getParametersStringValue()
    }
    
    @IBAction func buttonPressed(_ sender : NSButton) {
        let listElement = PSStringListElement()
        listElement.values = self.entryFunction.values
        
        let popup = PSCondition_Key_Popup(currentValue: .list(stringListElement: listElement), setCurrentValueBlock : { (cValue: PSEntryElement) -> () in
            
            if case .list(let newListElement) = cValue {
                self.entryFunction.values = newListElement.values
            } else {
                self.entryFunction.values = [cValue]
            }
            
            
            self.button.title = self.entryFunction.getParametersStringValue()
            self.updateScript()
        })
        popup.showAttributeModalForWindow(scriptData.window)
    }
}

class PSKeyListenerWindow : NSWindow {
    var controller : PSCondition_Key_Popup!
    var listening : Bool = false
    override func keyDown(with theEvent: NSEvent) {
        if listening {
            controller.keyDown(theEvent)
        } else {
            super.keyDown(with: theEvent)
        }
    }
}

