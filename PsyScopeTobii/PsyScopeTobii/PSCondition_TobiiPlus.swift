//
//  PSCondition_TobiiPlus.swift
//  PsyScopeEditor
//
//  Created by James on 09/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation
import PsyScopeFramework

class PSCondition_TobiiPlus : NSObject, PSConditionInterface {
    var typeString : String = ""
    var userFriendlyNameString : String = ""
    var helpfulDescriptionString : String = ""
    
    func type() -> String! {
        return "TobiiPlus"
    }
    
    func userFriendlyName() -> String! {
        return "Tobii Plus"
    }
    
    func helpfulDescription() -> String! {
        return "This condition allows events to trigger when eye movement enters a port area."
    }
    
    func icon() -> NSImage! {
        let image : NSImage = NSImage(contentsOfFile: NSBundle(forClass:self.dynamicType).pathForImageResource("MouseClick")!)!
        return image
    }
    
    func nib() -> NSNib! {
        return NSNib(nibNamed: "Condition_TobiiPlusCell", bundle: NSBundle(forClass:self.dynamicType))
    }
    
    func expandedCellHeight() -> CGFloat {
        return 51
    }
    
    func isInputDevice() -> Bool {
        return true
    }
}



class PSCondition_TobiiPlusCell : PSConditionCell {
    
    @IBOutlet var portButton : NSButton!
    
    @IBAction func portButton_Click(_: AnyObject) {
        let popup = PSPortBuilderController(currentValue: portValue, scriptData: scriptData, positionMode: false, setCurrentValueBlock : { (cValue: String) -> () in
            self.portValue = cValue
            
            let outputString = self.portValue
            
            self.entryFunction.setStringValues( [outputString] )
            self.updateScript()
        })
        popup.showAttributeModalForWindow(window!)
        
    }
    
    var portValue : String = ""
    
    
    func parse() {
        
        let inputValue = entryFunction.getStringValues()
        
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