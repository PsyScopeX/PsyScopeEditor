//
//  PSAction_ClearPort.swift
//  PsyScopeEditor
//
//  Created by James on 04/02/2015.
//

import Foundation

class PSAction_ClearPort : PSAction {
    override init() {
        super.init()
        typeString = "ClearPort"
        userFriendlyNameString = "Clear Port"
        helpfulDescriptionString = "This action erases the port that is used by the specified event. Event must be of type Text, PICT, Document, Paragraph, Pasteboard, or Key Sequence. The port boarder is unaffected."
        actionParameters = [PSAttributeParameter_Event.self]
        actionParameterNames = ["Event:"]
        groupString = "Event"
    }
}
