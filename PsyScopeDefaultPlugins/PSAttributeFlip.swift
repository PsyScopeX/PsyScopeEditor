//
//  PSAttributeFlip.swift
//  PsyScopeEditor
//
//  Created by James on 04/11/2014.
//

import Foundation

class PSAttributeFlip : PSAttributeGeneric {
    
    override init() {
        super.init()
        userFriendlyNameString = "Flip Mode"
        helpfulDescriptionString = "Allows the stimulus to be flipped vertically or horizontally"
        codeNameString = "Flip"
        toolsArray = [PSTextEvent().type(), PSPictureEvent().type()]
        defaultValueString = PSDefaultConstants.DefaultAttributeValues.PSAttributeFlip
        attributeClass = PSAttributeParameter_Custom.self
        customAttributeParameterAction = { (before : PSEntryElement, scriptData: PSScriptData, window: NSWindow, setCurrentValueBlock : ((PSEntryElement) -> ())?) -> () in
            let popup = PSCheckBoxListAttributePopup(currentValue: before, displayName: "Flip", checkBoxStrings: self.checkBoxStrings, setCurrentValueBlock: setCurrentValueBlock)
            popup.showAttributeModalForWindow(window)            
        }
    }
    
    lazy var checkBoxStrings : [(String, String)] = {
        var default_resources = PSDefaultResources()
        return default_resources.getStringPairs("attributeFlipCheckBoxes")
        }()
    

}