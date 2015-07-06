//
//  PSAttributeParameter_RTFlag.swift
//  PsyScopeEditor
//
//  Created by James on 06/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAttributeParameter_RTFlag : PSAttributeParameter_CustomPopup {
    override init() {
        super.init()
        values = ["VAR_ONLY", "NULL"]
    }
}