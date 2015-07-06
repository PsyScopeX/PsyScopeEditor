//
//  PSAction_MovieDo.swift
//  PsyScopeEditor
//
//  Created by James on 06/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAction_MovieDo : PSAction {
    override init() {
        super.init()
        typeString = "MovieDo"
        userFriendlyNameString = "Movie Do"
        helpfulDescriptionString = ""
        actionParameters = [PSAttributeParameter_SetGetPlayPause.self,PSAttributeParameter_String.self,PSAttributeParameter_String.self]
        actionParameterNames = ["Command:","Movie Tag:", "Arguments:"]
        groupString = "Actions / Conditions"
    }
}