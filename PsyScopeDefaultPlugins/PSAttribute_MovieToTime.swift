//
//  PSAttribute_MovieToTime.swift
//  PsyScopeEditor
//
//  Created by James on 30/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAttribute_MovieToTime : PSAttributeGeneric {
    
    override init() {
        super.init()
        userFriendlyNameString = "To Time"
        helpfulDescriptionString = "Movie to time"
        codeNameString = "ToTime"
        attributeClass = PSAttributeParameter_String.self
        defaultValueString = ""
        toolsArray = [PSMovieEvent().type()]
    }

}