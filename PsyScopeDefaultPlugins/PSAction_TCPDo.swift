//
//  PSAction_TCPDo.swift
//  PsyScopeEditor
//
//  Created by James on 06/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAction_TCPDo : PSAction {
    override init() {
        super.init()
        typeString = "TCP"
        userFriendlyNameString = "TCP Command"
        helpfulDescriptionString = ""
        actionParameters = [PSAttributeParameter_String.self,PSAttributeParameter_String.self]
        actionParameterNames = ["Command:", "Data:"]
        groupString = "Actions / Conditions"
    }
}