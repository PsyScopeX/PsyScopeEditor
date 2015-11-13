//
//  PSAttributeParameter_OnOff.swift
//  PsyScopeEditor
//
//  Created by James on 06/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAttributeParameter_OneZero : PSAttributeParameter_CustomPopup {
    override init() {
        super.init()
        values = ["1", "0"]
    }
}