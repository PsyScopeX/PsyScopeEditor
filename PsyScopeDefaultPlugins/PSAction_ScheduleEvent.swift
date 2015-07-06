//
//  PSAction_ScheduleEvent.swift
//  PsyScopeEditor
//
//  Created by James on 05/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAction_ScheduleEvent : PSAction {
    override init() {
        super.init()
        typeString = "ScheduleEvent"
        userFriendlyNameString = "Schedule Event"
        helpfulDescriptionString = "This action schedules the specified event to be run at the specified starting time, just as if it had been scheduled according to Start. Start is a string that is the same as the PsyScript expression of a start dependency."
        actionParameters = [PSAttributeParameter_Event.self, PSAttributeParameter_String.self]
        actionParameterNames = ["Event:", "Start:"]
        groupString = "Event"
    }
}