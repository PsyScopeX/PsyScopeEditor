//
//  PSAttribute_KeySequenceStimulus.swift
//  PsyScopeEditor
//
//  Created by James on 30/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAttribute_KeySequenceStimulus : PSAttributeGeneric {
    
    override init() {
        super.init()
        userFriendlyNameString = "Prompt"
        helpfulDescriptionString = "The string to prompt with during the event"
        codeNameString = "Stimulus"
        defaultValueString = ""
        toolsArray = [PSKeySequenceEvent().type()]
    }
}