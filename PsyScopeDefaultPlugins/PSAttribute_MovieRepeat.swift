//
//  PSAttribute_MovieRepeat.swift
//  PsyScopeEditor
//
//  Created by James on 30/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAttribute_MovieRepeat : PSAttributeGeneric {
    
    override init() {
        super.init()
        userFriendlyNameString = "Repeat"
        helpfulDescriptionString = "Movie repeat"
        codeNameString = "Repeat"
        attributeClass = PSAttributeParameter_String.self
        defaultValueString = ""
        toolsArray = [PSMovieEvent().type()]
    }

}