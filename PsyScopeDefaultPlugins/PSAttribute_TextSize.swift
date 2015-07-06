//
//  PSAttribute_TextStyle.swift
//  PsyScopeEditor
//
//  Created by James on 31/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAttribute_TextSize : PSAttributeGeneric {
    
    override init() {
        super.init()
        userFriendlyNameString = "Font Size"
        helpfulDescriptionString = "The size of the font"
        codeNameString = "Size"
        defaultValueString = PSDefaultConstants.DefaultAttributeValues.PSAttribute_TextSize
        attributeClass = PSAttributeParameter_FontSize.self
        toolsArray = [PSTextEvent().type(), PSKeySequenceEvent().type(), PSDocumentEvent().type(), PSParagraphEvent().type()]
    }
}