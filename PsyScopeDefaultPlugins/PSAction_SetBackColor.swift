//
//  PSAction_SetBackColor.swift
//  PsyScopeEditor
//
//  Created by James on 05/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAction_SetBackColor : PSAction {
    override init() {
        super.init()
        typeString = "SetBackColor"
        userFriendlyNameString = "Set Back Color"
        helpfulDescriptionString = "This function changes the default background color for screen stimuli."
        actionParameters = [PSAttributeParameter_Color.self]
        actionParameterNames = ["Color:"]
        groupString = "Stimulus"
    }
}