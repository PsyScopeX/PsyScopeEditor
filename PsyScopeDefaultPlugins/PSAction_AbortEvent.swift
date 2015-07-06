//
//  PSAction_AbortEvent.swift
//  PsyScopeEditor
//
//  Created by James on 16/11/2014.
//

import Foundation

class PSAction_AbortEvent : PSAction {
    override init() {
        super.init()
        typeString = "AbortEvent"
        userFriendlyNameString = "Abort Event"
        helpfulDescriptionString = "This action aborts the specified event, clearing the stimulus, if appropriate. It also deactivates any actions that are linked to the event and marks the time the event ended, and computes the event's duration."
        actionParameters = [PSAttributeParameter_Event.self]
        actionParameterNames = ["Event:"]
        groupString = "Event"
    }
}
