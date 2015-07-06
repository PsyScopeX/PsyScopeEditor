//
//  PSAction_UnscheduleEvent.swift
//  PsyScopeEditor
//
//  Created by James on 05/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAction_UnscheduleEvent : PSAction {
    override init() {
        super.init()
        typeString = "UnscheduleEvent"
        userFriendlyNameString = "Unschedule Event"
        helpfulDescriptionString = "This action removes an event from the run schedule. If the event has already been executed, UnscheduleEvent[] has no effect."
        actionParameters = [PSAttributeParameter_Event.self]
        actionParameterNames = ["Event:"]
        groupString = "Event"
    }
}