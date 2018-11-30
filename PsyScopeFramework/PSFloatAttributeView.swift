//
//  PSGenericAttributeEditor.swift
//  PsyScopeEditor
//
//  Created by James on 29/08/2014.
//
// Note, The nib needs to have a title bar otherwise the bstextfields dont work - this is an nsbug
// http://stackoverflow.com/questions/7561347/cant-edit-nstextfield-in-sheet-at-runtime

import Cocoa



public class PSFloatAttributePopup : PSAttributePopup {
    
    public init(currentValue: PSEntryElement, displayName : String, setCurrentValueBlock : ((PSEntryElement) -> ())?){
        super.init(nibName: "FloatAttribute",bundle: Bundle(for:type(of: self)), currentValue: currentValue, displayName: displayName, setCurrentValueBlock: setCurrentValueBlock)
    }

    @IBOutlet var label : NSTextField!
    @IBOutlet var field : NSTextField!
    @IBOutlet var view : NSView!
    
    override public func awakeFromNib() {
        label.stringValue = "Please enter the number value for the attribute named: " + displayName
        field.stringValue = currentValue.stringValue()
    }
    
    @IBAction func enteredDone(_: AnyObject) {
        currentValue = PSGetFirstEntryElementForStringOrNull(field.stringValue.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
        closeMyCustomSheet(self)
    }

}


