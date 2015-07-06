//
//  PSDocumentFileAttribute.swift
//  PsyScopeEditor
//
//  Created by James on 17/12/2014.
//

import Foundation

class PSDocumentFileAttribute : PSAttributeGeneric {
    override init() {
        super.init()
        userFriendlyNameString = "Filename"
        helpfulDescriptionString = "The filename of the text to open"
        codeNameString = "Stimulus"
        defaultValueString = ""
        attributeClass = PSAttributeParameter_FileOpen.self
        toolsArray = [PSDocumentEvent().type()]
    }
    
}