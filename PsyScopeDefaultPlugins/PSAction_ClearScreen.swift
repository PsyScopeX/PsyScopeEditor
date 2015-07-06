//
//  PSAction_ClearScreen.swift
//  PsyScopeEditor
//
//  Created by James on 05/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAction_ClearScreen : PSAction {
    override init() {
        super.init()
        typeString = "ClearScreen"
        userFriendlyNameString = "Clear Screen"
        helpfulDescriptionString = "This action erases the screen, using the global background color."
        actionParameters = []
        actionParameterNames = []
        groupString = "Stimulus"
    }
}