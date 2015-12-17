//
//  PSPictureEventAttribute.swift
//  PsyScopeEditor
//
//  Created by James on 04/11/2014.
//

import Foundation


class PSAttribute_PictureEventFeature : PSAttributeGeneric {
    
    override init() {
        super.init()
        userFriendlyNameString = "Special Options"
        helpfulDescriptionString = "Extra options for displaying pictures"
        codeNameString = "Feature"
        defaultValueString = ""
        attributeClass = PSAttributeParameter_Custom.self
        toolsArray = [PSPictureEvent().type()]
        customAttributeParameterAction = { (before : PSEntryElement, scriptData: PSScriptData, window: NSWindow, setCurrentValueBlock : ((PSEntryElement) -> ())?) -> () in
            let popup = PSCheckBoxListAttributePopup(currentValue: before, displayName: "Picture Options", checkBoxStrings: self.checkBoxStrings, setCurrentValueBlock: setCurrentValueBlock)
            popup.showAttributeModalForWindow(window)
            
        }
    }
    
    lazy var checkBoxStrings : [(String, String)] = {
        var default_resources = PSDefaultResources()
        return default_resources.getStringPairs("pictureFeatureCheckBoxes")
        }()
}

class PSAttribute_PictureEventDepth : PSAttributeGeneric {
    override init() {
        super.init()
        userFriendlyNameString = "Color Depth"
        helpfulDescriptionString = "The depth in pixels of the stimulus; this controls the number of colors to use when drawing the picture and the amount of memory it will use when stored."
        codeNameString = "Depth"
        toolsArray = [PSPictureEvent().type()]
        attributeClass = PSAttributeParameter_Int.self
        defaultValueString = PSDefaultConstants.DefaultAttributeValues.PSAttribute_PictureEventDepth
    }
}

class PSAttribute_PictureEventFilename : PSAttributeGeneric {
    override init() {
        super.init()
        userFriendlyNameString = "Filename"
        helpfulDescriptionString = "The filename of the picture to use"
        codeNameString = "Stimulus"
        toolsArray = [PSPictureEvent().type()]
        attributeClass = PSAttributeParameter_FileOpen.self
        defaultValueString = PSDefaultConstants.DefaultAttributeValues.PSAttribute_PictureEventFilename
    }
}

