//
//  PSCondition_TobiiPlus.swift
//  PsyScopeEditor
//
//  Created by James on 09/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSCondition_TobiiPlus : PSCondition {
    override init() {
        super.init()
        expandedHeight = 51
        typeString = "TobiiPlus"
        userFriendlyNameString = "Tobii Plus"
        helpfulDescriptionString = "This condition allows events to trigger when eye movement enters a port area."
        
    }

    
    override func nib() -> NSNib! {
        return NSNib(nibNamed: "Condition_TobiiPlusCell", bundle: NSBundle(forClass:self.dynamicType))
    }
    
    override func icon() -> NSImage! {
        let image : NSImage = NSImage(contentsOfFile: NSBundle(forClass:self.dynamicType).pathForImageResource("MouseClick")!)!
        return image
    }
}

class PSCondition_TobiiPlusCell : PSConditionCell {
    
    @IBOutlet var portButton : NSButton!
    
    @IBAction func portButton_Click(AnyObject) {
        var popup = PSPortBuilderController(currentValue: portValue, scriptData: scriptData, positionMode: false, setCurrentValueBlock : { (cValue: String) -> () in
            self.portValue = cValue
            
            var outputString = self.portValue
            
            self.entryFunction.setStringValues( [outputString] )
            self.updateScript()
        })
        popup.showAttributeModalForWindow(window!)
        
    }
    
    var portValue : String = ""
    
    
    func parse() {
        
        var inputValue = entryFunction.getStringValues()
        
        for v in inputValue {
            
            portValue = v.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "\""))
            
        }
        
        portButton.title = portValue
    }
    
    override func setup(conditionInterface: PSConditionInterface, function entryFunction: PSFunctionElement, scriptData: PSScriptData, expandedHeight: CGFloat) {
        super.setup(conditionInterface,function: entryFunction,scriptData: scriptData, expandedHeight: expandedHeight)
        parse()
    }
}