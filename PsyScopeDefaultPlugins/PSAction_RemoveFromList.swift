//
//  PSAction_RemoveFromList.swift
//  PsyScopeEditor
//
//  Created by James on 05/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAction_RemoveFromList : PSAction {
    override init() {
        super.init()
        typeString = "RemoveFromList"
        userFriendlyNameString = "Remove From List"
        helpfulDescriptionString = "Given an array trial variable in LValue and an index into this list in Expression, the indexed item is removed from the list. The list is indexed starting with 1."
        actionParameters = [PSAttributeParameter_String.self,PSAttributeParameter_String.self]
        actionParameterNames = ["LValue:","Expression:"]
        groupString = "List"
    }
}