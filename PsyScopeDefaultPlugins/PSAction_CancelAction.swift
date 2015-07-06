//
//  PSAction_CancelAction.swift
//  PsyScopeEditor
//
//  Created by James on 04/02/2015.
//

import Foundation

class PSAction_CancelAction : PSAction {
    override init() {
        super.init()
        typeString = "CancelAction"
        userFriendlyNameString = "Cancel Action"
        helpfulDescriptionString = "This action removes either a specified action or all actions (controlled by the Action parameter) from the action list of either a specified event or all events (controlled by the Stored with parameter) triggered by either a particular condition or any condition (controlled by the Type).  If an action name is specified in Action (e.g. RT), only actions with that name will be removed. If an event name is given in Event, only actions to be posted by that event will be removed. If a condition device name is given in Type (e.g. Start, End, Mouse), only actions that depend on that device will be removed. There is a technical interaction between CancelAction[] and the way in which ac- tions are grouped into action-condition pairs: when any action of a particular con- dition-action pair is cancelled, all of the actions in the pair are cancelled."
        actionParameters = [PSAttributeParameter_Action.self,PSAttributeParameter_Event.self,PSAttributeParameter_StartEnd.self]
        actionParameterNames = ["Action:","Event:","Time:"]
        groupString = "Actions / Conditions"
    }
}