//
//  PSConditionInterface.swift
//  PsyScopeEditor
//
//  Created by James on 15/01/2016.
//  Copyright © 2016 James. All rights reserved.
//

import Foundation

public protocol PSConditionInterface {

    //returns type of action
    func type() -> String

    //return user friendly unique name of attribute
    func userFriendlyName() -> String

    //return a user firendly small description of attribute
    func helpfulDescription() -> String

    //return an icon for the tool
    func icon() -> NSImage

    func nib() -> NSNib

    //returns height of the cell when expanded
    func expandedCellHeight() -> CGFloat

    //determines if condition is an input device
    func isInputDevice() -> Bool

    //allows the input device to change the script when it's turned on (despite being added to list of input devices)
    func turnInputDeviceOn(_ on : Bool, scriptData : PSScriptData)
    
}

