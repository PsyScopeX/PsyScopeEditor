//
//  PSAction_SetDefaultColor.swift
//  PsyScopeEditor
//
//  Created by James on 05/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAction_SetDefaultColor : PSAction {
    override init() {
        super.init()
        typeString = "SetDefaultColor"
        userFriendlyNameString = "Set Default Color"
        helpfulDescriptionString = "This function changes the default foreground color for screen stimuli."
        actionParameters = [PSAttributeParameter_Color.self]
        actionParameterNames = ["Color:"]
        groupString = "Stimulus"
    }
}