//
//  PSAttribute_TextStimulus.swift
//  PsyScopeEditor
//
//  Created by James on 31/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAttribute_TextStimulus : PSAttributeGeneric {
    
    override init() {
        super.init()
        userFriendlyNameString = "Stimulus" // luca changed from "text string" for easier comprehension
        helpfulDescriptionString = "The string to display during the event"
        codeNameString = "Stimulus"
        defaultValueString = PSDefaultConstants.DefaultAttributeValues.PSAttribute_TextStimulus
        toolsArray = [PSTextEvent().type()]
    }
    
}