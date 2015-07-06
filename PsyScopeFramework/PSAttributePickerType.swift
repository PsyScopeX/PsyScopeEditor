//
//  PSAttributePickerType.swift
//  PsyScopeEditor
//
//  Created by James on 16/04/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

public typealias PSAttributePickerTypeCallback = (PSAttributeType,Bool) -> ()


//Allows a callback for when attributes are picked
public class PSAttributePickerType : PSAttributePicker {
    
    public init(attributePickedCallback : PSAttributePickerTypeCallback, scriptData : PSScriptData) {
        self.attributePickedCallback = attributePickedCallback
        super.init(scriptData: scriptData)
    }
    
    let attributePickedCallback : PSAttributePickerTypeCallback
    
    override func attributeButtonClicked(row : Int, clickedOn : Bool) {
        super.attributeButtonClicked(row, clickedOn: clickedOn)
        let type = tableViewAttributes[row].type
        attributePickedCallback(type, clickedOn)
        popover.close()
    }
}