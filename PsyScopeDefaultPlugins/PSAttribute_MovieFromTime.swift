//
//  PSAttribute_MovieFromTime.swift
//  PsyScopeEditor
//
//  Created by James on 30/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAttribute_MovieFromTime : PSAttributeGeneric {
    
    override init() {
        super.init()
        userFriendlyNameString = "From Time"
        helpfulDescriptionString = "Movie from time"
        codeNameString = "FromTime"
        attributeClass = PSAttributeParameter_String.self
        defaultValueString = ""
        toolsArray = [PSMovieEvent().type()]
    }
}