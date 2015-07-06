//
//  PSAttribute_TextStyle.swift
//  PsyScopeEditor
//
//  Created by James on 31/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAttribute_TextFace : PSAttributeGeneric {
    
    override init() {
        super.init()
        userFriendlyNameString = "Font Typeface"
        helpfulDescriptionString = "The type of effect to apply to the font"
        codeNameString = "Face"
        defaultValueString = PSDefaultConstants.DefaultAttributeValues.PSAttribute_TextFace
        attributeClass = PSAttributeParameter_FontFace.self
        toolsArray = [PSTextEvent().type(), PSKeySequenceEvent().type(), PSDocumentEvent().type(), PSParagraphEvent().type()]
    }
}