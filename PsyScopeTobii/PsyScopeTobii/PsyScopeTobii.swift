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
    //each plugin can have multiple extensions (so you dont need a new bundle each time you develop an extension
    
    //	initializeClass: is called once when the plug-in is loaded. The plug-in's bundle is passed
    //	as argument;
    
    static func initializeClass(theBundle: NSBundle!) -> Bool {
        
    }
    
    //	pluginsFor: returns strings of plugin names
    static func pluginsFor(pluginTypeName: PSPluginType) -> [AnyObject]! {
        
    }
    
    // instantiatePlugin: returns an object (this is not possible currently in swift)
    static func instantiatePlugin(pluginName: String!) -> AnyObject! {
        
    }
    
    //returns class of actual extension
    static func getPSExtensionClass(pluginName: String!) -> AnyObject! {
        
    }
}