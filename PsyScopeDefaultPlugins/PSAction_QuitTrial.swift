//
//  PSAction_QuitTrial.swift
//  PsyScopeEditor
//
//  Created by James on 06/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAction_QuitTrial : PSAction {
    override init() {
        super.init()
        typeString = "QuitTrial"
        userFriendlyNameString = "Quit Trial"
        helpfulDescriptionString = "This action ends the current trial. Any trial actions which execute on the End[] con- dition will be performed."
        actionParameters = []
        actionParameterNames = []
        groupString = "Block / Trial"
    }
}