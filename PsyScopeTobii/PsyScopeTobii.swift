//
//  PsyScopeTobii.swift
//  PsyScopeEditor
//
//  Created by James on 29/10/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

class PsyScopeTobii: NSObject, PSPluginInterface {
    static func pluginsFor(pluginTypeName: PSPluginType) -> [NSObject.Type] {
        switch pluginTypeName {
        case .Tool:
            return []
        case .Attribute:
            return []
        case .Event:
            return []
        case .WindowView:
            return []
        case .Action:
            return [PSAction_TobiiPlus.self]
        case .Condition:
            return [PSCondition_TobiiPlus.self]
        }
    }
}