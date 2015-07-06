//
//  PSAttribute_TextStyle.swift
//  PsyScopeEditor
//
//  Created by James on 31/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAttribute_TextFont : PSAttributeGeneric {
    
    override init() {
        super.init()
        userFriendlyNameString = "Font Family"
        helpfulDescriptionString = "The family of font to use for the text event"
        codeNameString = "Font"
        defaultValueString = PSDefaultConstants.DefaultAttributeValues.PSAttribute_TextFont
        attributeClass = PSAttributeParameter_FontAll.self
        toolsArray = [PSTextEvent().type(), PSKeySequenceEvent().type(), PSDocumentEvent().type(), PSParagraphEvent().type()]
    }
}