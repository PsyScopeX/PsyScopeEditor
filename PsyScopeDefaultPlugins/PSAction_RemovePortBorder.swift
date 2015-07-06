//
//  PSAction_RemovePortBorder.swift
//  PsyScopeEditor
//
//  Created by James on 05/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAction_RemovePortBorder : PSAction {
    override init() {
        super.init()
        typeString = "RemovePortBorder"
        userFriendlyNameString = "Remove Port Border"
        helpfulDescriptionString = "This action removes the port border for the stimulus port of the specified event. Event must be of type Text, PICT, Document, Paragraph, Pasteboard, or Key Sequence."
        actionParameters = [PSAttributeParameter_Event.self]
        actionParameterNames = ["Event:"]
        groupString = "Stimulus"
    }
}