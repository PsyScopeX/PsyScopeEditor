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
}

class PSCondition_TCP_Popup : PSAttributePopup, NSTextFieldDelegate, NSMenuDelegate {
    
    var scriptData : PSScriptData
    init(currentValue: String, scriptData : PSScriptData, setCurrentValueBlock : ((String) -> ())?){
        self.scriptData = scriptData
        super.init(nibName: "TCPCondition",bundle: NSBundle(forClass:self.dynamicType), currentValue: currentValue, displayName: "Mouse", setCurrentValueBlock: setCurrentValueBlock)
    }
    
    
    @IBOutlet var TCPTagText : NSTextField!

    
    func parse() {
        var inputValue = currentValue.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        for v in inputValue {
            
            TCPTagText.stringValue = v.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "\""))

        }
    }
    
    @IBAction func generate(sender : AnyObject) {
        self.currentValue = "\"\(TCPTagText.stringValue)\""
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


class PSCondition_TCPCell : PSConditionCell, NSTextFieldDelegate {
    
    @IBOutlet var TCPTagText : NSTextField!
    
    func parse() {
        var inputValue = entryFunction.getStringValues()
        
        for v in inputValue {
            
            TCPTagText.stringValue = v.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "\""))
            
        }
    }
    
    
    @IBAction func generate(sender : AnyObject) {
        var outputString = TCPTagText.stringValue
        
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