//
//  PSGenericAttributeEditor.swift
//  PsyScopeEditor
//
//  Created by James on 29/08/2014.
//
// Note, The nib needs to have a title bar otherwise the bstextfields dont work - this is an nsbug
// http://stackoverflow.com/questions/7561347/cant-edit-nstextfield-in-sheet-at-runtime

import Cocoa

public class PSGenericAttributePopup : PSAttributePopup {
    
    public init(currentValue: String, displayName : String, setCurrentValueBlock : ((String) -> ())?) {
        super.init(nibName: "GenericAttribute",bundle: NSBundle(forClass:self.dynamicType),currentValue: currentValue, displayName: displayName, setCurrentValueBlock: setCurrentValueBlock)
    }

    @IBOutlet var label : NSTextField!
    @IBOutlet var field : NSTextField!
    @IBOutlet var view : NSView!
    
    override public func awakeFromNib() {
        label.stringValue = "Please enter the value for the attribute named: " + displayName
        field.stringValue = currentValue
        if custFormatter != nil {
            field.formatter = custFormatter
        }
    }
    
    var custFormatter : NSFormatter? = nil
    
    func setCustomFormatter(formatter : NSFormatter) {
        custFormatter = formatter
        if field != nil {
            field.formatter = formatter
        }
    }
    
    @IBAction func enteredDone(_: AnyObject) {
        currentValue = field.stringValue.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        closeMyCustomSheet(self)
    }

}
