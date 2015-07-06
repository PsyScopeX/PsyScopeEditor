//
//  PSAttibute_PasteBoardFlip.swift
//  PsyScopeEditor
//
//  Created by James on 08/04/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAttribute_PasteBoardEventFlip : PSAttributeFlip {
    override init() {
        super.init()
        codeNameString = "PBoardFlip"
        toolsArray = [PSPasteBoardEvent().type()]
    }
}