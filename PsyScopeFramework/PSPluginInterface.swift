//
//  PSPluginInterface.swift
//  PsyScopeEditor
//
//  Created by James on 16/10/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

@objc public enum PSPluginType : Int {
    case Tool, Event, Attribute, WindowView, Action, Condition
}


@objc public protocol PSPluginInterface {

    //each plugin can have multiple extensions (so you dont need a new bundle each time you develop an extension

    //pluginsFor: returns strings of plugin types (must be nsobject with zero argument constructors)
    static func pluginsFor(pluginTypeName : PSPluginType) -> [NSObject.Type]
    
}