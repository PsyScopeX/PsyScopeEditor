//
//  PSAttribute_MovieVolume.swift
//  PsyScopeEditor
//
//  Created by James on 30/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAttribute_MovieVolume : PSAttributeGeneric {
    
    override init() {
        super.init()
        userFriendlyNameString = "Volume"
        helpfulDescriptionString = "Movie volume"
        codeNameString = "Volume"
        attributeClass = PSAttributeParameter_String.self
        defaultValueString = ""
        toolsArray = [PSMovieEvent().type()]
    }

}