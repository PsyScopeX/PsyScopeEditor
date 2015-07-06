//
//  PSAction_NewListItem.swift
//  PsyScopeEditor
//
//  Created by James on 05/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAction_NewListItem : PSAction {
    override init() {
        super.init()
        typeString = "NewListItem"
        userFriendlyNameString = "New List Item"
        helpfulDescriptionString = "This action extends the size of the trial variable array given in LValue; the value of the new item in the list is undefined."
        actionParameters = [PSAttributeParameter_String.self]
        actionParameterNames = ["LValue:"]
        groupString = "List"
    }
}