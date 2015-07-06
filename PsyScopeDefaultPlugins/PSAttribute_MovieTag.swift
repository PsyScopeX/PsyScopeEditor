//
//  PSAttribute_MovieTag.swift
//  PsyScopeEditor
//
//  Created by James on 30/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAttribute_MovieTag : PSAttributeGeneric {
    
    override init() {
        super.init()
        userFriendlyNameString = "Tag"
        helpfulDescriptionString = "Tag for the movie file"
        codeNameString = "MovieTag"
        attributeClass = PSAttributeParameter_String.self
        defaultValueString = ""
        toolsArray = [PSMovieEvent().type()]
    }

}