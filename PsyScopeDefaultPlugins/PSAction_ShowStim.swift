//
//  PSAction_ShowStim.swift
//  PsyScopeEditor
//
//  Created by James on 05/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAction_ShowStim : PSAction {
    override init() {
        super.init()
        typeString = "ShowStim"
        userFriendlyNameString = "Show Stimulus"
        helpfulDescriptionString = "This action presents the stimulus for Stimulus Event without actually executing the event (i.e. its duration condition is not watched, actions are not posted, etc.).\n Usually, you will not specify the second event. If you specify two different events, the Stimulus value for the first is combined with the non-Stimulus attributes from the second.\nShowStim[] does mark the time at which the stimulus began, and records this as the start time for Stimulus Event; it does not, however, perform the scheduling oper- ations of RunEvent[] and ScheduleEvent[]."
        actionParameters = [PSAttributeParameter_Event.self,PSAttributeParameter_Event.self]
        actionParameterNames = ["Event:","Attributes:"]
        groupString = "Stimulus"
    }
}