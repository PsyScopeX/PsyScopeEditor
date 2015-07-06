//
//  PSAttributeParameter_StartEndRandom.swift
//  PsyScopeEditor
//
//  Created by James on 06/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAttributeParameter_StartEndRandom : PSAttributeParameter_CustomPopup {
    override init() {
        super.init()
        values = ["Start", "End", "Random"]
    }
}