//
//  PSCondition_TCP.swift
//  PsyScopeEditor
//
//  Created by James on 31/01/2015.
//

import Foundation

class PSCondition_TCP : PSCondition {
    override init() {
        super.init()
        typeString = "TCP"
        userFriendlyNameString = "TCP"
        helpfulDescriptionString = "This action allows events to trigger on TCP events"
        expandedHeight = 70
    }
    
    override func nib() -> NSNib! {
        return NSNib(nibNamed: "Condition_TCPCell", bundle: NSBundle(forClass:self.dynamicType))
    }
    
    override func icon() -> NSImage! {
        let image : NSImage = NSImage(contentsOfFile: NSBundle(forClass:self.dynamicType).pathForImageResource("MouseClick")!)!
        return image
    }
    
    override func isInputDevice() -> Bool {
        return true
    }
}


class PSCondition_TCPCell : PSConditionCell, NSTextFieldDelegate {
    
    @IBOutlet var TCPTagText : NSTextField!
    
    func parse() {
        let inputValue = entryFunction.getStringValues()
        
        for v in inputValue {
            
            TCPTagText.stringValue = v.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "\""))
            
        }
    }
    
    
    @IBAction func generate(sender : AnyObject) {
        let outputString = TCPTagText.stringValue
        
        entryFunction.setStringValues([outputString])
        self.updateScript()
    }
    
    func control(control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        generate(control)
        return true
    }
    
    override func setup(conditionInterface: PSConditionInterface, function entryFunction: PSFunctionElement, scriptData: PSScriptData, expandedHeight: CGFloat) {
        super.setup(conditionInterface,function: entryFunction,scriptData: scriptData, expandedHeight: expandedHeight)
        parse()
    }
}