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
    
    override func nib() -> NSNib {
        return NSNib(nibNamed: "Condition_TCPCell", bundle: Bundle(for:type(of: self)))!
    }
    
    override func icon() -> NSImage {
        let image : NSImage = NSImage(contentsOfFile: Bundle(for:type(of: self)).pathForImageResource("MouseClick")!)!
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
            
            TCPTagText.stringValue = v.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
            
        }
    }
    
    
    @IBAction func generate(_ sender : AnyObject) {
        let outputString = TCPTagText.stringValue
        
        entryFunction.setStringValues([outputString])
        self.updateScript()
    }
    
    func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        generate(control)
        return true
    }
    
    override func setup(_ conditionInterface: PSConditionInterface, function entryFunction: PSFunctionElement, scriptData: PSScriptData, expandedHeight: CGFloat) {
        super.setup(conditionInterface,function: entryFunction,scriptData: scriptData, expandedHeight: expandedHeight)
        parse()
    }
}
