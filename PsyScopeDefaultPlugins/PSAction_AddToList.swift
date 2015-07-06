//
//  PSAction_AppendToList.swift
//  PsyScopeEditor
//
//  Created by James on 04/02/2015.
//

import Foundation

class PSAction_AddToList : PSAction {
    override init() {
        super.init()
        typeString = "AddToList"
        userFriendlyNameString = "Add To List"
        helpfulDescriptionString = "This action is used to add a value to a trial variable of List type. LValue should be a variable expression that evaluates to a array variable, and the result of evaluating Expression is appended to this array."
        actionParameters = [PSAttributeParameter_String.self,PSAttributeParameter_String.self]
        actionParameterNames = ["LValue:","Expression:"]
        groupString = "List"
    }
}