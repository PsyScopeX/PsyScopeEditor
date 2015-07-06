//
//  PSAttribute_Position.swift
//  PsyScopeEditor
//
//  Created by James on 03/10/2014.
//

import Foundation

class PSAttribute_Position: PSAttributeGeneric {
    
    
    override init() {
        super.init()
        userFriendlyNameString = "Position"
        helpfulDescriptionString = "Describes a shape to contain and position stimuli such as as text or pictures"
        codeNameString = "Position"
        toolsArray = [PSTextEvent().type()]
        defaultValueString = PSDefaultConstants.DefaultAttributeValues.PSAttribute_Position
        attributeClass = PSAttributeParameter_Custom.self
        customAttributeParameterAction = { (before : String, scriptData: PSScriptData, window: NSWindow, setCurrentValueBlock : ((String) -> ())?) -> () in
            var popup = PSPortBuilderController(currentValue: before, scriptData: scriptData, positionMode: true, setCurrentValueBlock: setCurrentValueBlock)
            popup.showAttributeModalForWindow(window)
            
        }
    }
}