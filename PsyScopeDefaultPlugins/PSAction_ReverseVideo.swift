//
//  PSAction_ReverseVideo.swift
//  PsyScopeEditor
//
//  Created by James on 05/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAction_ReverseVideo : PSAction {
    override init() {
        super.init()
        typeString = "ReverseVideo"
        userFriendlyNameString = "Reverse Video"
        helpfulDescriptionString = "This function switches the default foreground and background colors for screen stimuli. If no colors have been set, then screen stimuli will appear white against a black background, as opposed to the Macintosh’s usual black-against-white."
        actionParameters = []
        actionParameterNames = []
        groupString = "Stimulus"
    }
}