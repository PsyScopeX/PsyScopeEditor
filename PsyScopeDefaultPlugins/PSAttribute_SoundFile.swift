//
//  PSAttribute_SoundFile.swift
//  PsyScopeEditor
//
//  Created by James on 30/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAttribute_SoundFile : PSAttributeGeneric {
    override init() {
        super.init()
        userFriendlyNameString = "Filename"
        helpfulDescriptionString = "The filename of the sound to use"
        codeNameString = "SoundFile"
        defaultValueString = ""
        attributeClass = PSAttributeParameter_FileOpen.self
        toolsArray = [PSSoundEvent().type()]
    }

}