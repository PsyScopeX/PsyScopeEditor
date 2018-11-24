//
//  PSCondition_ScriptWhen.swift
//  PsyScopeEditor
//
//  Created by James on 09/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSCondition_ScriptWhen : PSCondition {
    override init() {
        super.init()
        expandedHeight = 51
        typeString = "ScriptWhen"
        userFriendlyNameString = "Script When"
        helpfulDescriptionString = "This condition allows events to trigger when eye movement enters a port area."
        
    }
    
    
    override func nib() -> NSNib {
        return NSNib(nibNamed: "Condition_ScriptWhenCell", bundle: Bundle(for:self.dynamicType))!
    }
    
    override func icon() -> NSImage {
        let image : NSImage = NSImage(contentsOfFile: Bundle(for:self.dynamicType).pathForImageResource("MouseClick")!)!
        return image
    }
    
    override func isInputDevice() -> Bool {
        return true
    }
}

class PSCondition_ScriptWhenCell : PSConditionCell, NSTextFieldDelegate {
    
    @IBOutlet var scriptWhenText : NSTextField!
    
    
    
    func parse() {
        let inputValue = entryFunction.getStringValues()
        
        for v in inputValue {
            
            scriptWhenText.stringValue = v.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
            
        }
    }
    
    
    @IBAction func generate(_ sscriptWhener : AnyObject) {
        let outputString = scriptWhenText.stringValue
        
        entryFunction.setStringValues([outputString])
        self.updateScript()
    }
    
    func control(_ control: NSControl, textShouldscriptWhenEditing fieldEditor: NSText) -> Bool {
        generate(control)
        return true
    }
    
    override func setup(_ conditionInterface: PSConditionInterface, function entryFunction: PSFunctionElement, scriptData: PSScriptData, expandedHeight: CGFloat) {
        super.setup(conditionInterface,function: entryFunction,scriptData: scriptData, expandedHeight: expandedHeight)
        parse()
    }
}
