//
//  PSCondition_Mousse.swift
//  PsyScopeEditor
//
//  Created by James on 10/12/2014.
//

import Foundation

class PSCondition_Mouse : PSCondition {
    override init() {
        super.init()
        expandedHeight = 80
        typeString = "Mouse"
        userFriendlyNameString = "Mouse"
        helpfulDescriptionString = "The Mouse device is used to watch for input from the standard Macintosh mouse. This de- vice can detect button clicks and mouse movement.  Turn on the Click checkbox to detect mouse button presses. Turn on the Movement check- box to detect mouse movement.."
        
    }

    
    override func nib() -> NSNib! {
        return NSNib(nibNamed: "Condition_MouseCell", bundle: NSBundle(forClass:self.dynamicType))
    }

    override func icon() -> NSImage! {
        let image : NSImage = NSImage(contentsOfFile: NSBundle(forClass:self.dynamicType).pathForImageResource("MouseClick")!)!
        return image
    }
    
    override func isInputDevice() -> Bool {
        return true
    }
}

class PSCondition_Mouse_Popup : PSAttributePopup, NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate, NSMenuDelegate {
    
    @IBOutlet var clickButton : NSButton!
    @IBOutlet var moveButton : NSButton!
    @IBOutlet var portButton : NSButton!
    @IBOutlet var portChangeButton : NSButton!
    var portName : String = ""
    var scriptData : PSScriptData
    init(currentValue: String, scriptData : PSScriptData, setCurrentValueBlock : ((String)->())?){
        self.scriptData = scriptData
        
        super.init(nibName: "MouseCondition",bundle: NSBundle(forClass:self.dynamicType), currentValue: currentValue, displayName: "Mouse", setCurrentValueBlock: setCurrentValueBlock)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        var inputValue = currentValue.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        clickButton.state = 0
        moveButton.state = 0
        portButton.state = 0
        for (index,v) in inputValue.enumerate() {
            if v.lowercaseString == "click" {
                clickButton.state = 1
            }
            
            if v.lowercaseString == "move" {
                moveButton.state = 1
            }
            
            if v.lowercaseString == "in" {
                portButton.state = 1
            }
            
            if let _ = v.rangeOfString("PortName") {
                
                if (index + 1) < inputValue.count {
                    portName = inputValue[index + 1]
                    portName = portName.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "()\""))
                }
            }
        }
        portChangeButton.title = portName
    }
    
    override func closeMyCustomSheet(sender: AnyObject) {
        var outputString = ""
   
        if clickButton.state == 1 {
            outputString += "Click "
        }
        
        if moveButton.state == 1 {
            outputString += "Move "
        }
        
        if portButton.state == 1 {
            outputString += "In "
            outputString += "PortName(\"\(self.portName)\")"
        }
        self.currentValue = outputString
        
        super.closeMyCustomSheet(sender)
    }
    
    
    @IBAction func choosePortButton(sender : AnyObject) {
        portButton.state = 1
        let popup = PSPortBuilderController(currentValue: portName, scriptData: scriptData, positionMode: false, setCurrentValueBlock : { (cValue: String) -> () in
                self.portName = cValue
                if let r = self.portName.rangeOfString("PortName") {
                    self.portName.removeRange(r)
                    self.portName = self.portName.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "()\""))
                }
                self.portChangeButton.title = self.portName
            })
        popup.showAttributeModalForWindow(self.attributeSheet)
        
    }
}


class PSCondition_Mouse_Cell : PSConditionCell {
    
    @IBOutlet var clickButton : NSButton!
    @IBOutlet var moveButton : NSButton!
    @IBOutlet var portButton : NSButton!
    @IBOutlet var portChangeButton : NSButton!
    var portName : String = ""

    
    override func setup(conditionInterface: PSConditionInterface, function entryFunction: PSFunctionElement, scriptData: PSScriptData, expandedHeight: CGFloat) {
        super.setup(conditionInterface,function: entryFunction,scriptData: scriptData, expandedHeight: expandedHeight)

        clickButton.state = 0
        moveButton.state = 0
        portButton.state = 0
        for v in entryFunction.values {
            
            switch(v) {
            case .Function(let functionElement):
                if functionElement.functionName == "PortName" {
                    let svs = functionElement.getStringValues()
                    if svs.count > 0 {
                        portName = svs.first!
                    }
                    
                }
                break
            case .List:
                break
            case .Null:
                break
            case .StringToken(let stringElement):
                let string = stringElement.value
                if string.lowercaseString == "click" {
                    clickButton.state = 1
                }else if string.lowercaseString == "move" {
                    moveButton.state = 1
                }else if string.lowercaseString == "in" {
                    portButton.state = 1
                }
                break
            }
        }
        
        if portName != "" {
            portChangeButton.title = portName
        }

    }
    
    @IBAction func parameterChange(sender : AnyObject) {
        var outputString = ""
        
        if clickButton.state == 1 {
            outputString += "Click "
        }
        
        if moveButton.state == 1 {
            outputString += "Move "
        }
        
        if portButton.state == 1 {
            outputString += "In "
            outputString += "PortName(\"\(self.portName)\")"
        }
        entryFunction.setStringValues([outputString])
        self.updateScript()
    }
    
 
    @IBAction func choosePortButton(sender : AnyObject) {
        portButton.state = 1
        let popup = PSPortBuilderController(currentValue: portName, scriptData: scriptData, positionMode: false, setCurrentValueBlock : { (cValue: String) -> () in
            self.portName = cValue
            if let r = self.portName.rangeOfString("PortName") {
                self.portName.removeRange(r)
                self.portName = self.portName.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "()\""))
            }
            self.portChangeButton.title = self.portName
            self.parameterChange(self)
        })
        popup.showAttributeModalForWindow(scriptData.window)
        
        
    }
    
}

