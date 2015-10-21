//
//  PsyScopeTobii.swift
//  PsyScopeTobii
//
//  Created by James on 16/10/2015.
//  Copyright © 2015 James Alvarez. All rights reserved.
//

import Foundation
import PsyScopeFramework

class PsyScopeTobii: NSObject, PSPluginInterface {
   static func pluginsFor(pluginTypeName: PSPluginType) -> [NSObject.Type] {
        Swift.print("Helllo")
        return []
    }
}