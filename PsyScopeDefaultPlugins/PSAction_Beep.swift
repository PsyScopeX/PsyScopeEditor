//
//  PSAction_Beep.swift
//  PsyScopeEditor
//
//  Created by James on 04/02/2015.
//

import Foundation

class PSAction_Beep : PSAction {
    override init() {
        super.init()
        typeString = "Beep"
        userFriendlyNameString = "Beep"
        helpfulDescriptionString = "This action plays a system sound, with the given name. If Beep is not specified, “correct beep” is used."
        actionParameters = [PSAttributeParameter_SystemSound.self]
        actionParameterNames = ["Sound:"]
        groupString = "Stimulus"
    }
}