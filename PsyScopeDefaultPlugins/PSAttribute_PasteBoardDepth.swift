//
//  PSPasteBoardEventAttribute.swift
//  PsyScopeEditor
//
//  Created by James on 17/12/2014.
//

import Foundation


class PSAttribute_PasteBoardEventDepth : PSAttributeGeneric {
    override init() {
        super.init()
        userFriendlyNameString = "Color Depth"
        helpfulDescriptionString = "The depth in pixels of the stimulus; this controls the number of colors to use when drawing the picture and the amount of memory it will use when stored."
        codeNameString = "PBoardDepth"
        toolsArray = [PSPasteBoardEvent().type()]
        defaultValueString = PSDefaultConstants.DefaultAttributeValues.PSAttribute_PasteBoardEventDepth
    }
}


