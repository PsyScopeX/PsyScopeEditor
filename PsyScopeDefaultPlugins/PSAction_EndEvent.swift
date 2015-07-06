//
//  PSAction_EndEvent.swift
//  PsyScopeEditor
//
//  Created by James on 05/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAction_EndEvent : PSAction {
    override init() {
        super.init()
        typeString = "EndEvent"
        userFriendlyNameString = "End Event"
        helpfulDescriptionString = "This action ends the specified event, just as if its Duration terminating condition had been met."
        actionParameters = [PSAttributeParameter_Event.self]
        actionParameterNames = ["Event:"]
        groupString = "Event"
    }
}