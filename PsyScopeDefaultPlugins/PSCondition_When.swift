//
//  PSCondition_When.swift
//  PsyScopeEditor
//
//  Created by James on 09/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSCondition_When : PSCondition {
    override init() {
        super.init()
        expandedHeight = 51
        typeString = "When"
        userFriendlyNameString = "When"
        helpfulDescriptionString = "This condition allows events to trigger when eye movement enters a port area."
        
    }
    
    
    override func nib() -> NSNib {
        return NSNib(nibNamed: "Condition_WhenCell", bundle: NSBundle(forClass:self.dynamicType))!
    }

    override func icon() -> NSImage {
        let image : NSImage = NSImage(contentsOfFile: NSBundle(forClass:self.dynamicType).pathForImageResource("MouseClick")!)!
        return image
    }
}

class PSCondition_WhenCell : PSConditionCell, NSTextFieldDelegate {
    
    @IBOutlet var whenText : NSTextField!
    
    
    
    func parse() {

        let inputValue = entryFunction.getStringValues()
        
        for v in inputValue {
            
            whenText.stringValue = v.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "\""))
            
        }
    }
    
    
    @IBAction func generate(swhener : AnyObject) {
        entryFunction.setStringValues([whenText.stringValue])
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