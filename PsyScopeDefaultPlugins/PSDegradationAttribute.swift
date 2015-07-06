//
//  PSTextEventDegradation.swift
//  PsyScopeEditor
//
//  Created by James on 24/10/2014.
//

import Foundation

class PSDegradationAttribute : PSAttributePopup {
    init(currentValue : String, setCurrentValueBlock : ((String) -> ())?) {
        var bundle = PSDefaultPluginBundle
        super.init(nibName: "DegradationDialog", bundle: bundle, currentValue: currentValue, displayName: "Degradation", setCurrentValueBlock: setCurrentValueBlock)
    }
    
    @IBOutlet var fgText : NSTextField!
    @IBOutlet var bgText : NSTextField!
    @IBOutlet var fgStepper : NSStepper!
    @IBOutlet var bgStepper : NSStepper!
    
    
    var fgValue : Float = 0.0
    var bgValue : Float = 0.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //parse the current value
        var cv = PSStringListCachedContainer()
        cv.stringValue = currentValue
        if cv.count == 2 {
            //use number formatter of the textfield
            fgText.stringValue = cv[0]
            bgText.stringValue = cv[1]
            fgValue = fgText.floatValue
            bgValue = bgText.floatValue
            fgStepper.floatValue = fgValue
            bgStepper.floatValue = bgValue
        }
    }
    
    @IBAction func doneButton(sender : AnyObject) {
        self.currentValue = "\(fgValue) \(bgValue)"
        closeMyCustomSheet(sender)
    }
}

class PSAttribute_TextEventDegradation : PSAttributeGeneric {
    
    override init() {
        super.init()
        userFriendlyNameString = "Text Degradation"
        helpfulDescriptionString = "First parameter is the probability of pixels being turned off for foreground of text, second for background"
        codeNameString = "Degradation"
        //dialogTypeEnum = PSAttributeDialogType.Custom
        defaultValueString = PSDefaultConstants.DefaultAttributeValues.PSAttribute_TextEventDegradation
        attributeClass = PSAttributeParameter_Custom.self
        toolsArray = [PSTextEvent().type()]
        customAttributeParameterAction = { (before : String, scriptData: PSScriptData, window: NSWindow, setCurrentValueBlock : ((String) -> ())?) -> () in
            var popup = PSDegradationAttribute(currentValue: before, setCurrentValueBlock: setCurrentValueBlock)
            popup.showAttributeModalForWindow(window)
            
        }
    }
    
}

class PSAttribute_PictureEventDegradation : PSAttributeGeneric {
    
    override init() {
        super.init()
        userFriendlyNameString = "Picture Degradation"
        helpfulDescriptionString = "First parameter is the probability of pixels being turned off for foreground of text, second for background"
        codeNameString = "Degradation"
        defaultValueString = PSDefaultConstants.DefaultAttributeValues.PSAttribute_PictureEventDegradation
        attributeClass = PSAttributeParameter_Custom.self
        toolsArray = [PSPictureEvent().type()]
        customAttributeParameterAction = { (before : String, scriptData: PSScriptData, window: NSWindow, setCurrentValueBlock : ((String) -> ())?) -> () in
            var popup = PSDegradationAttribute(currentValue: before, setCurrentValueBlock: setCurrentValueBlock)
            popup.showAttributeModalForWindow(window)
            
        }
    }
}

