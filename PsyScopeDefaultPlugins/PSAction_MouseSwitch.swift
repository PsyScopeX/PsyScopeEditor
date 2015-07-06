//
//  PSAction_MouseSwitch.swift
//  PsyScopeEditor
//
//  Created by James on 06/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAction_MouseSwitch : PSAction {
    override init() {
        super.init()
        typeString = "MouseSwitch"
        userFriendlyNameString = "Mouse Switch"
        helpfulDescriptionString = ""
        actionParameters = [PSAttributeParameter_OnOff.self]
        actionParameterNames = ["On / Off:"]
        groupString = "Actions / Conditions"
    }
}