//
//  PSAction_ScriptEval.swift
//  PsyScopeEditor
//
//  Created by James on 05/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAction_ScriptEval : PSAction {
    override init() {
        super.init()
        typeString = "ScriptEval"
        userFriendlyNameString = "ScriptEval"
        helpfulDescriptionString = "This action is used to directly evaluate a PsyScript entry. Usually, evaluating the en- try will change some value in the script, and that value will be used for compiling future trials."
        actionParameters = [PSAttributeParameter_String.self]
        actionParameterNames = ["Entry Name:"]
        groupString = "Other"
    }
}