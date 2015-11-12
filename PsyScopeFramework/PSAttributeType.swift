//
//  PSAttributeType.swift
//  PsyScopeEditor
//
//  Created by James on 16/04/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

public struct PSAttributeType : Equatable {
    public let name : String
    public let parentType : PSType
    
    
    
    public init(name : String, parentType : PSType) {
        self.name = name
        self.parentType = parentType
    }
    
    public init(fullType : String) {
        var comps = fullType.componentsSeparatedByString(".")
        if comps.count == 2 {
            self.name = comps[0]
            self.parentType = PSType.FromName(comps[1])
        } else {
            self.name = ""
            self.parentType = PSType.UndefinedEntry
        }
        
    }
    
    public var fullType : String {
        if name != "" && parentType != PSType.UndefinedEntry {
            return "\(name).\(parentType.name)"
        } else {
            return ""
        }
    }
    
    
}

public func ==(lhs: PSAttributeType, rhs: PSAttributeType) -> Bool {
    return lhs.name == rhs.name && lhs.parentType == rhs.parentType
}