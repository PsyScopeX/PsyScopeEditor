//
//  PSCondition_Sound.swift
//  PsyScopeEditor
//
//  Created by James on 31/01/2015.
//

import Foundation

class PSCondition_Sound : PSCondition {
    override init() {
        super.init()
        expandedHeight = 82
        typeString = "Sound"
        userFriendlyNameString = "Sound"
        helpfulDescriptionString = "This action allows events to trigger at the end of a sound"
        
    }
    
    override func nib() -> NSNib! {
        return NSNib(nibNamed: "Condition_SoundCell", bundle: NSBundle(forClass:self.dynamicType))
    }
    
    
    override func icon() -> NSImage! {
        let image : NSImage = NSImage(contentsOfFile: NSBundle(forClass:self.dynamicType).pathForImageResource("MouseClick")!)!
        return image
    }
    
    override func isInputDevice() -> Bool {
        return true
    }
}



class PSCondition_SoundCell : PSConditionCell, NSTextFieldDelegate {
    
    @IBOutlet var soundTagText : NSTextField!
    @IBOutlet var soundRadio  : NSMatrix!
    
    
    func parse() {
        let inputValue = entryFunction.getStringValues()
        
        soundRadio.selectCellWithTag(1) //end
        soundTagText.enabled = false
        
        for v in inputValue {
            if v != "" {
                soundTagText.stringValue = v.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "\""))
                soundRadio.selectCellWithTag(2)
            }
        }
    }
    
    
    @IBAction func generate(sender : AnyObject) {
        var outputString = ""
        let tag = soundRadio.selectedTag()
        if tag == 2 {
            if soundTagText.stringValue == "" {
                soundTagText.stringValue = "0"
            }
            outputString += soundTagText.stringValue
            soundTagText.enabled = true
        } else {
            //done
            soundTagText.enabled = false
        }
        
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