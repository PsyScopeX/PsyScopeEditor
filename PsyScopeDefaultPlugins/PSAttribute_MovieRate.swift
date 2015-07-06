//
//  PSAttribute_MovieRate.swift
//  PsyScopeEditor
//
//  Created by James on 30/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAttribute_MovieRate : PSAttributeGeneric {
    
    override init() {
        super.init()
        userFriendlyNameString = "Rate"
        helpfulDescriptionString = "Rate of playback"
        codeNameString = "MovieRate"
        attributeClass = PSAttributeParameter_String.self
        defaultValueString = ""
        toolsArray = [PSMovieEvent().type()]
    }

}