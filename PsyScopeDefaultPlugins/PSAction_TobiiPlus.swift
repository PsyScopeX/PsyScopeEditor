//
//  PSAction_TobiiPlus.swift
//  PsyScopeEditor
//
//  Created by James on 06/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAction_TobiiPlus : PSAction {
    override init() {
        super.init()
        typeString = "Tobii Plus"
        userFriendlyNameString = "Tobii Plus Command"
        helpfulDescriptionString = ""
        actionParameters = [PSAttributeParameter_String.self,PSAttributeParameter_String.self]
        actionParameterNames = ["Command:", "Data:"]
        groupString = "Actions / Conditions"
    }
}