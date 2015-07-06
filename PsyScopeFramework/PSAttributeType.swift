//
//  PSAttributeType.swift
//  PsyScopeEditor
//
//  Created by James on 16/04/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

public struct PSAttributeType : Equatable {
    public var name : String = ""
    public var type : String = ""
    
    
    
    public init(name : String, type : String) {
        self.name = name
        self.type = type
    }
    
    public init(fullType : String) {
        var comps = fullType.componentsSeparatedByString(".")
        if comps.count == 2 {
            self.name = comps[0]
            self.type = comps[1]
        } else {
            self.name = ""
            self.type = ""
        }
        
    }
    
    public var fullType : String {
        if name != "" && type != "" {
            return "\(name).\(type)"
        } else {
            return ""
        }
    }
    
    
}

public func ==(lhs: PSAttributeType, rhs: PSAttributeType) -> Bool {
    return lhs.name == rhs.name && lhs.type == rhs.type
}