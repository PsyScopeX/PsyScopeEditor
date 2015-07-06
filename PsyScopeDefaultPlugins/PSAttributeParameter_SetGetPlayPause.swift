//
//  PSAttributeParameter_SetGetPlayPause.swift
//  PsyScopeEditor
//
//  Created by James on 06/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAttributeParameter_SetGetPlayPause : PSAttributeParameter_CustomPopup {
    override init() {
        super.init()
        values = ["Set", "Get", "Play", "Pause"]
    }
}