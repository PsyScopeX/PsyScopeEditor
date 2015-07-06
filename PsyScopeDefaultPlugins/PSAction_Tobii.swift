//
//  PSAction_TobiiEyeTracker.swift
//  PsyScopeEditor
//
//  Created by James on 06/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAction_Tobii : PSAction {
    override init() {
        super.init()
        typeString = "Tobii"
        userFriendlyNameString = "Tobii Command"
        helpfulDescriptionString = ""
        actionParameters = [PSAttributeParameter_String.self,PSAttributeParameter_String.self]
        actionParameterNames = ["Command:", "Data:"]
        groupString = "Actions / Conditions"
    }
}