//
//  PSAction_DrawPortBorder.swift
//  PsyScopeEditor
//
//  Created by James on 05/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAction_DrawPortBorder : PSAction {
    override init() {
        super.init()
        typeString = "DrawPortBorder"
        userFriendlyNameString = "Draw Port Border"
        helpfulDescriptionString = "This action draws the port border for the stimulus port of the specified event. Event must be of type Text, PICT, Document, Paragraph, Pasteboard, or Key Sequence."
        actionParameters = [PSAttributeParameter_Event.self]
        actionParameterNames = ["Event:"]
        groupString = "Stimulus"
    }
}