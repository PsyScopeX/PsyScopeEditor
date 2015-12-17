//
//  PSAttribute_SoundChannel.swift
//  PsyScopeEditor
//
//  Created by James on 30/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAttribute_SoundChannel : PSAttributeGeneric {
    override init() {
        super.init()
        userFriendlyNameString = "Channel"
        helpfulDescriptionString = "Specify which channel to use from sound file"
        codeNameString = "Channel"
        defaultValueString = ""
        attributeClass = PSAttributeParameter_Custom.self
        customAttributeParameterAction = { (before : PSEntryElement, scriptData: PSScriptData, window: NSWindow, setCurrentValueBlock : ((PSEntryElement) -> ())?) -> () in
            let popup = PSCheckBoxListAttributePopup(currentValue: before, displayName: "Sound Channel", checkBoxStrings: self.checkBoxStrings, setCurrentValueBlock: setCurrentValueBlock)
            popup.showAttributeModalForWindow(window)            
        }
        toolsArray = [PSSoundEvent().type()]
    }
    
    lazy var checkBoxStrings : [(String, String)] = {
        var strings : [(String, String)] = []
        strings.append(("Left","Left"))
        strings.append(("Right", "Right"))
        return strings
        }()

}