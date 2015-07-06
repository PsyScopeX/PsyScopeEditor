//
//  PSAction_Set.swift
//  PsyScopeEditor
//
//  Created by James on 05/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAction_Set : PSAction {
    override init() {
        super.init()
        typeString = "Set"
        userFriendlyNameString = "Set"
        helpfulDescriptionString = "Given a trial variable in LValue, its value is set to the result of evaluating Expression. "
        actionParameters = [PSAttributeParameter_Variable.self, PSAttributeParameter_String.self]
        actionParameterNames = ["LValue:","Expression:"]
        groupString = "Other"
    }
}