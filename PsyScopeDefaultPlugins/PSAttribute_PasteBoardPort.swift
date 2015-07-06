//
//  PSAttribute_PasteBoardPort.swift
//  PsyScopeEditor
//
//  Created by James on 08/04/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAttribute_PasteBoardEventPort : PSAttribute_Port {
    
    override init() {
        super.init()
        userFriendlyNameString = "Port"
        helpfulDescriptionString = "Describes a shape to contain and position stimuli such as as text or pictures"
        codeNameString = "PBoardPort"
        toolsArray = [PSPasteBoardEvent().type()]
        defaultValueString = PSDefaultConstants.DefaultAttributeValues.PSAttribute_Port
    }    
}
