//
//  PSAttribute_SoundFeature.swift
//  PsyScopeEditor
//
//  Created by James on 30/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAttribute_SoundFeature : PSAttributeGeneric {
    override init() {
        super.init()
        userFriendlyNameString = "Feature"
        helpfulDescriptionString = "Sound playback settings"
        codeNameString = "Feature"
        defaultValueString = ""
        attributeClass = PSAttributeParameter_Custom.self
        customAttributeParameterAction = { (before : PSEntryElement, scriptData: PSScriptData, window: NSWindow, setCurrentValueBlock : ((PSEntryElement) -> ())?) -> () in
            let popup = PSCheckBoxListAttributePopup(currentValue: before, displayName: "Sound Options", checkBoxStrings: self.checkBoxStrings, setCurrentValueBlock: setCurrentValueBlock)
            popup.showAttributeModalForWindow(window)
            
        }
        toolsArray = [PSSoundEvent().type()]
    }
    
    lazy var checkBoxStrings : [(String, String)] = {
        var strings : [(String, String)] = []
        strings.append(("Keep_Sound","Keep sound in memory"))
        strings.append(("Parallel", "Parallel"))
        strings.append(("Play_From_Disk","Play from disk"))
        return strings
        }()
    
}