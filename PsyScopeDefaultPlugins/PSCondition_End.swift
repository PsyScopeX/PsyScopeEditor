//
//  PSCondition_End.swift
//  PsyScopeEditor
//
//  Created by James on 09/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSCondition_End : PSCondition {
    override init() {
        super.init()
        expandedHeight = 51
        typeString = "End"
        userFriendlyNameString = "End"
        helpfulDescriptionString = "This condition allows events to trigger when eye movement enters a port area."
        
    }
    
    
    override func nib() -> NSNib {
        return NSNib(nibNamed: "Condition_EndCell", bundle: Bundle(for:Swift.type(of: self)))!
    }
    
    override func icon() -> NSImage {
        let image : NSImage = NSImage(contentsOfFile: Bundle(for:Swift.type(of: self)).pathForImageResource("MouseClick")!)!
        return image
    }
}

class PSCondition_EndCell : PSConditionCell, NSTextFieldDelegate {
    
    @IBOutlet var endText : NSTextField!
    
    
    
    func parse() {
        let inputValue = entryFunction.getStringValues()
        
        for v in inputValue {
            
            endText.stringValue = v.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
            
        }
    }
    
    
    @IBAction func generate(_ sender : AnyObject) {
        let outputString = endText.stringValue
        
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
