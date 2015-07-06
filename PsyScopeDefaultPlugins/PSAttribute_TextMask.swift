//
//  PSAttribute_TextStyle.swift
//  PsyScopeEditor
//
//  Created by James on 31/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAttribute_TextMask : PSAttributeGeneric {
    
    override init() {
        super.init()
        userFriendlyNameString = "Mask Character"
        helpfulDescriptionString = "Specifies a character to use when masking text"
        codeNameString = "Mask"
        defaultValueString = PSDefaultConstants.DefaultAttributeValues.PSAttribute_TextMask
        attributeClass = PSAttributeParameter_Mask.self
        toolsArray = [PSTextEvent().type()]
    }
    
}