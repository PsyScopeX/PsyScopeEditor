//
//  PSPluginLoader.swift
//  PsyScopeEditor
//
//  Created by James on 16/10/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

class PSPluginLoader : NSObject {
    
    
    var pluginClasses :[String : AnyObject] = [:]
    var bundlePaths : [String : String] = [:]
    
    var tools : [PSToolInterface] = []
    var events : [PSEventInterface] = []
    var attributes : [PSAttributeInterface] = []
    var windowViews : [PSWindowViewInterface] = []
    var actions : [PSActionInterface] = []
    var conditions : [PSConditionInterface] = []
    
    var pluginsLoaded : [String] = []
    override init() {
        super.init()
        guard let builtInPlugInsPath = NSBundle.mainBundle().builtInPlugInsPath else {
            fatalError("Could not get built in plugins path")
        }
        
        //search in inbuilt plugins
        for resourcePath in NSBundle.pathsForResourcesOfType("psyplugin", inDirectory: builtInPlugInsPath) {
            loadPluginsInPath(resourcePath)
            pluginsLoaded.append(resourcePath)
        }
    
        //also search custom path
        let customPath = PSPreferences.pluginPath.stringValue
        for resourcePath in NSBundle.pathsForResourcesOfType("psyplugin", inDirectory: customPath) {
            loadPluginsInPath(resourcePath)
            pluginsLoaded.append(resourcePath)
        }
        
    }
        
    func loadPluginsInPath(resourcePath : String) {
        guard let pluginBundle = NSBundle(path: resourcePath),
            pluginClass = pluginBundle.principalClass,
            pluginInterface = pluginClass as? PSPluginInterface.Type else {
                fatalError("Incorrect setup for plugin at \(resourcePath) - bundle principal class must be PSPluginInterface")
        }
        
        let toolPlugins = setupPluginsFor(PSPluginType.Tool, pluginInterface: pluginInterface, resourcePath: resourcePath)
        tools = toolPlugins.map({ $0 as! PSToolInterface })
        
        let eventPlugins = setupPluginsFor(PSPluginType.Event, pluginInterface: pluginInterface, resourcePath: resourcePath)
        events = eventPlugins.map({ $0 as! PSEventInterface })
        
        let attributePlugins = setupPluginsFor(PSPluginType.Attribute, pluginInterface: pluginInterface, resourcePath: resourcePath)
        attributes = attributePlugins.map({ $0 as! PSAttributeInterface })
        
        let wvPlugins = setupPluginsFor(PSPluginType.WindowView, pluginInterface: pluginInterface, resourcePath: resourcePath)
        windowViews = wvPlugins.map({ $0 as! PSWindowViewInterface })
        
        let actionPlugins = setupPluginsFor(PSPluginType.Action, pluginInterface: pluginInterface, resourcePath: resourcePath)
        actions = actionPlugins.map({ $0 as! PSActionInterface })
        
        let conditionPlugins = setupPluginsFor(PSPluginType.Condition, pluginInterface: pluginInterface, resourcePath: resourcePath)
        conditions = conditionPlugins.map({ $0 as! PSConditionInterface })
        
    }
        
    
    func setupPluginsFor(type : PSPluginType, pluginInterface : PSPluginInterface.Type, resourcePath : String) -> [NSObject] {
        let classes = pluginInterface.pluginsFor(type)
        var pluginInstances : [NSObject] = []
        for pluginClass in classes {
            
            let name = String(pluginClass.dynamicType)
            let pluginObject = pluginClass.init()
            pluginInstances.append(pluginObject)
            pluginClasses[name] = pluginClass
            bundlePaths[name] = resourcePath
        }
        return pluginInstances
    }
}
