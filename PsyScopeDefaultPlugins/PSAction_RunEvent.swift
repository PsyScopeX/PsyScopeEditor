//
//  PSAction_RunEvent.swift
//  PsyScopeEditor
//
//  Created by James on 05/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAction_RunEvent : PSAction {
    override init() {
        super.init()
        typeString = "RunEvent"
        userFriendlyNameString = "Run Event"
        helpfulDescriptionString = "This action initiates the specified event, just as if it had been started by the regular scheduling mechanism.\nIf the event has been run already, but ended, then it will be run again. If the event is still running, then RunEvent[] does nothing."
        actionParameters = [PSAttributeParameter_Event.self]
        actionParameterNames = ["Event:"]
        groupString = "Event"
    }
}