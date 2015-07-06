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
    
    override func nib() -> NSNib! {
        return NSNib(nibNamed: "Condition_SysCmdCell", bundle: NSBundle(forClass:self.dynamicType))
    }
    
    override func icon() -> NSImage! {
        let image : NSImage = NSImage(contentsOfFile: NSBundle(forClass:self.dynamicType).pathForImageResource("MouseClick")!)!
        return image
    }
}

class PSCondition_SysCmd_Popup : PSAttributePopup, NSTextFieldDelegate, NSMenuDelegate {
    
    var scriptData : PSScriptData
    init(currentValue: String, scriptData : PSScriptData, setCurrentValueBlock : ((String)->())?){
        self.scriptData = scriptData
        super.init(nibName: "SysCmdCondition",bundle: NSBundle(forClass:self.dynamicType), currentValue: currentValue, displayName: "Mouse", setCurrentValueBlock: setCurrentValueBlock)
    }
    
    
    @IBOutlet var SysCmdTagText : NSTextField!
    
    
    func parse() {
        var inputValue = currentValue.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        for v in inputValue {
            
            SysCmdTagText.stringValue = v.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "\""))
           
        }
    }
    
    @IBAction func generate(sender : AnyObject) {
        self.currentValue = "\"\(SysCmdTagText.stringValue)\""
    }
    
    func control(control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        generate(control)
        return true
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        parse()
    }
    
    override func closeMyCustomSheet(sender: AnyObject!) {
        generate(sender)
        super.closeMyCustomSheet(sender)
    }
    
}


class PSCondition_SysCmdCell : PSConditionCell, NSTextFieldDelegate {
    
    @IBOutlet var SysCmdTagText : NSTextField!

    
    
    func parse() {
        let inputValue = entryFunction.getStringValues()
        
        for v in inputValue {
            
            SysCmdTagText.stringValue = v.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "\""))
        
        }
    }
    
    
    @IBAction func generate(sender : AnyObject) {
        let outputString = SysCmdTagText.stringValue
        
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