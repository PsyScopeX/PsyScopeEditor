//
//  PSAttribute_ExperimentInputDevices.swift
//  PsyScopeEditor
//
//  Created by James on 12/08/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

class PSAttribute_ExperimentInputDevices : PSExperimentAttribute {
    override init() {
        super.init()
        userFriendlyNameString = "Input Devices"
        helpfulDescriptionString = "The types of input to listen to"
        codeNameString = "InputDevices"
        defaultValueString = PSDefaultConstants.DefaultAttributeValues.PSExperimentInputDevices
        attributeClass = PSAttributeParameter_Custom.self
        customAttributeParameterAction = { (before : String, scriptData: PSScriptData, window: NSWindow, setCurrentValueBlock : ((String) -> ())?) -> () in
            
            
            let checkBoxStrings : [(String,String)] = scriptData.pluginProvider.conditionPlugins.values.filter( {
                return $0.isInputDevice()
            }).map({
                let type = $0.type()
                return (type,type)
            })
            
 
            
            let popup = PSCheckBoxListAttributePopup(currentValue: before, displayName: "Data Fields", checkBoxStrings: checkBoxStrings, setCurrentValueBlock: setCurrentValueBlock)
            popup.showAttributeModalForWindow(window)
            
        }
    }
}