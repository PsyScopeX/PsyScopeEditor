//
//  PSAction_MaskStim.swift
//  PsyScopeEditor
//
//  Created by James on 05/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAction_MaskStim : PSAction {
    override init() {
        super.init()
        typeString = "MaskStim"
        userFriendlyNameString = "Mask Stimulus"
        helpfulDescriptionString = "This action masks the stimulus associated with Stimulus Event.  By default, MaskStim[] uses the mask specified as the Mask attribute for the event; however, an optional a mask stimulus (for Text stimuli, this is a character) can be specified as the Mask parameter. Also, an optional Attrib Event can be specified as a source for non-Stimulus at- tributes, just as with ShowEvent[]."
        actionParameters = [PSAttributeParameter_Event.self,PSAttributeParameter_String.self,PSAttributeParameter_Event.self]
        actionParameterNames = ["Event:","Mask:","AttribEvent:"]
        groupString = "Stimulus"
    }
}