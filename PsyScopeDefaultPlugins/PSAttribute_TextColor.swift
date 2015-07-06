//
//  PSAttribute_TextStyle.swift
//  PsyScopeEditor
//
//  Created by James on 31/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAttribute_TextColor : PSAttributeGeneric {
    
    override init() {
        super.init()
        userFriendlyNameString = "Text Color"
        helpfulDescriptionString = "Specifies the text color"
        codeNameString = "Color"
        defaultValueString = "0 0 0"
        attributeClass = PSAttributeParameter_Color.self
        toolsArray = [PSTextEvent().type(), PSKeySequenceEvent().type(), PSDocumentEvent().type(), PSParagraphEvent().type()]
    }
}