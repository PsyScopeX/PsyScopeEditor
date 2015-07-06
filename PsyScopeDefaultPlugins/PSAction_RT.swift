//
//  PSAction_RT.swift
//  PsyScopeEditor
//
//  Created by James on 05/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAction_RT : PSAction {
    override init() {
        super.init()
        typeString = "RT"
        userFriendlyNameString = "RT"
        helpfulDescriptionString = "This action records the state of all input devices and stores this either: a) in the data file, or b) in a specified trial variable of type Response, or c) in both the data file and a variable. Where the information is stored depends on the values of the Stor- age Variable and Flag parameters; the default is to the data file.\n The Label string is stored along with the regular response time information; this la- bel is used by the experiment designer to mark the recorded data and is meaningless to PsyScope. \n The Relative to parameter changes which event is used to calculate response time; the recorded response time will be the difference between start time of this event and the time at which a response was received. The default Relative to event is the one that posted the action.\n The Storage Variable parameter specifies a trial variable with either a numerical or Response type. If the variable’s type is Response, the response data is copied into this variable.If the variable’s type is numerical (Integer, Long Integer, etc.), the variable is filled in with an index into the standard response list – RTData – when the response was recorded.\n The Flag optional parameter is used when a trial variable of type Response is specified for Storage Variable; if it is VAR_ONLY, the response information is not written to the data file (only to the trial variable)."
        actionParameters = [PSAttributeParameter_String.self,PSAttributeParameter_Event.self,PSAttributeParameter_Variable.self,PSAttributeParameter_RTFlag.self]
        actionParameterNames = ["Label:", "Relative to:", "Storage Variable:", "Flag:"]
        groupString = "Stimulus"
    }
}