//
//  PSAction_NextCrossing.swift
//  PsyScopeEditor
//
//  Created by James on 05/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAction_NextCrossing : PSAction {
    override init() {
        super.init()
        typeString = "NextCrossing"
        userFriendlyNameString = "Next Crossing"
        helpfulDescriptionString = "This action causes a new cell to be selected in a factor set — whichever set includes Factor. The new cell will be used for the next trial.  This action is intended for use on factor sets with crossing type Fixed."
        actionParameters = [PSAttributeParameter_String.self]
        actionParameterNames = ["Factor:"]
        groupString = "List"
    }
}