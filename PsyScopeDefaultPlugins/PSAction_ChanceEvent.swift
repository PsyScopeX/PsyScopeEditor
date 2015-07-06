//
//  PSAction_ChanceEvent.swift
//  PsyScopeEditor
//
//  Created by James on 05/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAction_ChanceEvent : PSAction {
    override init() {
        super.init()
        typeString = "ChanceEvent"
        userFriendlyNameString = "Chance Event"
        helpfulDescriptionString = "This action is like RunEvent[], except that the event is run only with the probability given in Chance. Chance can be a number between 0 and 1, or a trial variable ex- pression that evaluates to a number."
        actionParameters = [PSAttributeParameter_Event.self,PSAttributeParameter_Float.self]
        actionParameterNames = ["Event:","Chance:"]
        groupString = "Event"
    }
}