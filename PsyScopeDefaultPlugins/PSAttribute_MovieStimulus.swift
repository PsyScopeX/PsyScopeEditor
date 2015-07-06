//
//  PSAttribute_MovieStimulus.swift
//  PsyScopeEditor
//
//  Created by James on 30/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAttribute_MovieStimulus : PSAttributeGeneric {
    
    override init() {
        super.init()
        userFriendlyNameString = "Movie File"
        helpfulDescriptionString = "The movie file"
        codeNameString = "Stimulus"
        attributeClass = PSAttributeParameter_FileOpen.self
        defaultValueString = ""
        toolsArray = [PSMovieEvent().type()]
    }

}