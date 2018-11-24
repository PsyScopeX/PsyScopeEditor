//
//  PSVariableType.swift
//  PsyScopeEditor
//
//  Created by James on 20/04/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

open class PSVariableNamedType {
    
    init(name: String, type: PSVariableType) {
        self.name = name
        self.type = type
    }
    
    var name : String
    var type : PSVariableType
    
}

