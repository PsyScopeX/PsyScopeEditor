//
//  PSAttribute_PasteBoardDegradation.swift
//  PsyScopeEditor
//
//  Created by James on 08/04/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAttribute_PasteBoardEventDegradation : PSAttributeGeneric {
    
    override init() {
        super.init()
        userFriendlyNameString = "Degradation"
        helpfulDescriptionString = "First parameter is the probability of pixels being turned off for foreground of text, second for background"
        codeNameString = "Degradation"
        //dialogTypeEnum = PSAttributeDialogType.Custom
        defaultValueString = PSDefaultConstants.DefaultAttributeValues.PSAttribute_PasteBoardEventDegradation
        attributeClass = PSAttributeParameter_Custom.self
        toolsArray = [PSPasteBoardEvent().type()]
        customAttributeParameterAction = { (before : String, scriptData: PSScriptData, window: NSWindow, setCurrentValueBlock : ((String) -> ())?) -> () in
            var popup = PSDegradationAttribute(currentValue: before, setCurrentValueBlock: setCurrentValueBlock)
            popup.showAttributeModalForWindow(window)
            
        }
    }
}