//
//  PSAction_GetTimestamp.swift
//  PsyScopeEditor
//
//  Created by James on 06/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAction_GetTimestamp : PSAction {
    override init() {
        super.init()
        typeString = "GetTimestamp"
        userFriendlyNameString = "Get Timestamp"
        helpfulDescriptionString = ""
        actionParameters = [PSAttributeParameter_Int.self,PSAttributeParameter_Variable.self]
        actionParameterNames = ["Time Source:","Variable:"]
        groupString = "Actions / Conditions"
    }
}