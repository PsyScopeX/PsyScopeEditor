//
//  PSAction_ClearStim.swift
//  PsyScopeEditor
//
//  Created by James on 05/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAction_ClearStim : PSAction {
    override init() {
        super.init()
        typeString = "ClearStim"
        userFriendlyNameString = "Clear Stim"
        helpfulDescriptionString = "This action clears the stimulus associated with the specified event. It also marks the time at which this occurs, computing and storing the actual duration for the event. It does not perform the scheduling operations of EndEvent[]; these will be performed when the scheduled end of the event is reached (if the event is currently running)."
        actionParameters = [PSAttributeParameter_Event.self]
        actionParameterNames = ["Event:"]
        groupString = "Stimulus"
    }
}