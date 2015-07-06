//
//  PSAction_SysCmd.swift
//  PsyScopeEditor
//
//  Created by James on 06/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAction_SysCmd : PSAction {
    override init() {
        super.init()
        typeString = "SysCmd"
        userFriendlyNameString = "SysCmd"
        helpfulDescriptionString = ""
        actionParameters = [PSAttributeParameter_String.self,PSAttributeParameter_String.self,PSAttributeParameter_String.self]
        actionParameterNames = ["Type:","Label:", "Data:"]
        groupString = "Actions / Conditions"
    }
}