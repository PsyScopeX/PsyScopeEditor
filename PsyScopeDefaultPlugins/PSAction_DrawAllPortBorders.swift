//
//  PSAction_DrawAllPortBorders.swift
//  PsyScopeEditor
//
//  Created by James on 05/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAction_DrawAllPortBorders : PSAction {
    override init() {
        super.init()
        typeString = "DrawAllPortBorders"
        userFriendlyNameString = "Draw All Port Borders"
        helpfulDescriptionString = "This action draws the borders of all stimulus ports that are used by screen events in the experiment. If different trials use different stimulus ports, then this action can only draw ports that it knows are going to be used."
        actionParameters = []
        actionParameterNames = []
        groupString = "Stimulus"
    }
}