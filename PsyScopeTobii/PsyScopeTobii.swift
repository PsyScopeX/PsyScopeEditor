//
//  PsyScopeTobii.swift
//  PsyScopeEditor
//
//  Created by James on 29/10/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

class PsyScopeTobii: NSObject, PSPluginInterface {
    static func pluginsFor(_ pluginTypeName: PSPluginType) -> [NSObject.Type] {
        switch pluginTypeName {
        case .tool:
            return []
        case .attribute:
            return []
        case .event:
            return []
        case .windowView:
            return [PSTobiiSetup.self]
        case .action:
            return [PSAction_TobiiPlus.self]
        case .condition:
            return [PSCondition_TobiiPlus.self]
        }
    }
}
