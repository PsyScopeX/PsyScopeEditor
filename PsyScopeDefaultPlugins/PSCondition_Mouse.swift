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
        portName = ""
        
        for v in entryFunction.values {
            
            switch(v) {
            case .Function(let functionElement):
                if functionElement.functionName.lowercaseString == "portname" {
                    portName = functionElement.getStrippedStringValues().joinWithSeparator(" ")
                    portButton.state = 1
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
        
        let popup = PSPortBuilderController(currentValue: PSGetFirstEntryElementForStringOrNull("PortName(\"\(self.portName)\")"), scriptData: scriptData, positionMode: false, setCurrentValueBlock : { (cValue: PSEntryElement) -> () in
            
            let functionElement = PSFunctionElement.FromStringValue(cValue.stringValue())
            self.portName = functionElement.getStrippedStringValues().joinWithSeparator(" ")
            self.portChangeButton.title = self.portName
            self.portButton.state = 1
            self.parameterChange(self)
        })
        popup.showAttributeModalForWindow(scriptData.window)
    }
    
}

