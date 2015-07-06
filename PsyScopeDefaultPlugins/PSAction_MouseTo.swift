//
//  PSAction_MouseDo.swift
//  PsyScopeEditor
//
//  Created by James on 06/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAction_MouseTo : PSAction {
    override init() {
        super.init()
        typeString = "MouseTo"
        userFriendlyNameString = "Mouse To"
        helpfulDescriptionString = ""
        actionParameters = [PSAttributeParameter_Variable.self]
        actionParameterNames = ["Point Variable:"]
        groupString = "Actions / Conditions"
    }
}