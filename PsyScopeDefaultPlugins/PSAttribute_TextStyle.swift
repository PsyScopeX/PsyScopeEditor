//
//  PSAttribute_TextStyle.swift
//  PsyScopeEditor
//
//  Created by James on 31/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAttribute_TextStyle : PSAttributeGeneric {
    
    override init() {
        super.init()
        userFriendlyNameString = "Text Style"
        helpfulDescriptionString = "Contains the full specification of text appearance.  Individual properties i.e. typeface / size can by overridden by other more specific attributes i.e. Face / Size"
        codeNameString = "Style"
        defaultValueString = PSDefaultConstants.DefaultAttributeValues.PSAttribute_TextStyle
        attributeClass = PSAttributeParameter_FontFamily.self
        toolsArray = [PSTextEvent().type(), PSKeySequenceEvent().type(), PSDocumentEvent().type(), PSParagraphEvent().type()]
    }
}