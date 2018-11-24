//
//  PSCondition_SysCmd.swift
//  PsyScopeEditor
//
//  Created by James on 31/01/2015.
//

import Foundation

class PSCondition_SysCmd : PSCondition {
    override init() {
        super.init()
        expandedHeight = 82
        typeString = "SysCmd"
        userFriendlyNameString = "SysCmd"
        helpfulDescriptionString = "This action allows events to trigger on a system command"
        
    }
    
    override func nib() -> NSNib {
        return NSNib(nibNamed: "Condition_SysCmdCell", bundle: Bundle(for:Swift.type(of: self)))!
    }
    
    override func icon() -> NSImage {
        let image : NSImage = NSImage(contentsOfFile: Bundle(for:Swift.type(of: self)).pathForImageResource("MouseClick")!)!
        return image
    }
    
    override func isInputDevice() -> Bool {
        return true
    }
}

class PSCondition_SysCmdCell : PSConditionCell, NSTextFieldDelegate {
    
    @IBOutlet var SysCmdTagText : NSTextField!

    
    
    func parse() {
        let inputValue = entryFunction.getStringValues()
        
        for v in inputValue {
            
            SysCmdTagText.stringValue = v.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
        
        }
    }
    
    
    @IBAction func generate(_ sender : AnyObject) {
        let outputString = SysCmdTagText.stringValue
        
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
