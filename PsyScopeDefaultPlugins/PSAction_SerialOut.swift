//
//  PSAction_SerialOut.swift
//  PsyScopeEditor
//
//  Created by James on 06/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAction_SerialOut : PSAction {
    override init() {
        super.init()
        typeString = "SerialOut"
        userFriendlyNameString = "Serial Out"
        helpfulDescriptionString = ""
        actionParameters = [PSAttributeParameter_String.self,PSAttributeParameter_String.self]
        actionParameterNames = ["Port:", "Data:"]
        groupString = "Actions / Conditions"
    }
}