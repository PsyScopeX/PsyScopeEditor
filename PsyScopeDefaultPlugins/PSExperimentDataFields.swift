//
//  PSExperimentDataFields.swift
//  PsyScopeEditor
//
//  Created by James on 19/08/2014.
//

import Foundation


class PSExperimentDataFields : PSExperimentAttribute {
    
    override init() {
        super.init()
        userFriendlyNameString = "Data Fields"
        helpfulDescriptionString = "The types of data that will be outputted"
        codeNameString = "DataFields"
        attributeClass = PSAttributeParameter_Custom.self
        defaultValueString = PSDefaultConstants.DefaultAttributeValues.PSExperimentDataFields
        attributeClass = PSAttributeParameter_Custom.self
        customAttributeParameterAction = { (before : String, scriptData: PSScriptData, window: NSWindow, setCurrentValueBlock : ((String) -> ())?) -> () in
            var popup = PSCheckBoxListAttributePopup(currentValue: before, displayName: "Data Fields", checkBoxStrings: self.checkBoxStrings, setCurrentValueBlock: setCurrentValueBlock)
            popup.showAttributeModalForWindow(window)
            
        }
    }
    
    
    lazy var checkBoxStrings : [(String, String)] = {
        var default_resources = PSDefaultResources()
        return default_resources.getStringPairs("experimentDataFieldsCheckBoxes")
        }()
}

