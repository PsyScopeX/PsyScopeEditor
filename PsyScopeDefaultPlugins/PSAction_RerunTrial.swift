//
//  PSAction_RerunTrial.swift
//  PsyScopeEditor
//
//  Created by James on 05/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAction_RerunTrial : PSAction {
    override init() {
        super.init()
        typeString = "RerunTrial"
        userFriendlyNameString = "Rerun Trial"
        helpfulDescriptionString = "This action tags the trial numbered Trial Number (or the current trial if none is specified) to be run again.  Trial Number is the Trial’s absolute trial number; this specification can be in the form of a number or a trial variable expression.  The When parameter specifies when the trial should be re-run; the possible values are Mix and End. Mix specifies that the trial re-run should be mixed in with the remaining first-run trials, while End specifies that the re-run should be delayed until all of the first-runs are done. If a trial is re-run with End, the second-time re-runs will be performed after the first-time re-runs are complete.  The Arrange parameter specifies an order within the two When types; the possible values are Start, End, and Random. Start specifies that the trial should be re-run before any other trials currently scheduled for re-run in its set (Mix or End). End specifies that it should be re-run after the other re-run trials. Random specifies that it should be rescheduled at a random position within its re-run set."
        actionParameters = [PSAttributeParameter_Int.self, PSAttributeParameter_MixEnd.self, PSAttributeParameter_StartEndRandom.self]
        actionParameterNames = ["Trial Number:", "When:", "Arrange:"]
        groupString = "Block / Trial"
    }
}