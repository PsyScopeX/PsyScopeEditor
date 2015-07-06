//
//  PSProperty.swift
//  PsyScopeEditor
//
//  Created by James on 18/02/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

public struct PSProperty {
    public let name : String
    public let defaultValue : String
    public let essential : Bool  //determines if when default value is set if it is removed
    
    public init(name : String, defaultValue : String) {
        self.name = name
        self.defaultValue = defaultValue
        self.essential = false
    }
    
    public init(name : String, defaultValue : String, essential : Bool) {
        self.name = name
        self.defaultValue = defaultValue
        self.essential = essential
    }
}