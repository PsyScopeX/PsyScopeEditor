//
//  PSAttribute_SoundVolume.swift
//  PsyScopeEditor
//
//  Created by James on 30/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAttribute_SoundVolume : PSAttributeGeneric {
    override init() {
        super.init()
        userFriendlyNameString = "Volume"
        helpfulDescriptionString = "The volume of the sound 0 - 255"
        codeNameString = "Volume"
        defaultValueString = ""
        attributeClass = PSAttributeParameter_Int255.self
        toolsArray = [PSSoundEvent().type()]
    }
    
}