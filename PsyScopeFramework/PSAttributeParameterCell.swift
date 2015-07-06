//
//  PSAttributeParameterCell.swift
//  PsyScopeEditor
//
//  Created by James on 10/04/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

//This cell can be set up with an attribute parameter
public class PSAttributeParameterCell : PSScriptUpdatingCell {
    public var attributeParameter : PSAttributeParameter
    public var interface : PSAttributeInterface

    public init(interface : PSAttributeInterface, scriptData : PSScriptData) {
        self.interface = interface
        self.attributeParameter = interface.attributeParameter() as! PSAttributeParameter
        super.init(frame: NSRect(x: 0, y: 0, width: 200, height: 30))
        self.scriptData = scriptData
    }
}