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
        guard let builtInPlugInsPath = Bundle.main.builtInPlugInsPath else {
            fatalError("Could not get built in plugins path")
        }
        
        //search in inbuilt plugins
        for resourcePath in Bundle.paths(forResourcesOfType: "psyplugin", inDirectory: builtInPlugInsPath) {
            loadPluginsInPath(resourcePath)
            pluginsLoaded.append(resourcePath)
        }
    
        //also search custom path
        let customPath = PSPreferences.pluginPath.stringValue
        for resourcePath in Bundle.paths(forResourcesOfType: "psyplugin", inDirectory: customPath) {
            loadPluginsInPath(resourcePath)
            pluginsLoaded.append(resourcePath)
        }
        
    }
        
    func loadPluginsInPath(_ resourcePath : String) {
        guard let pluginBundle = Bundle(path: resourcePath),
            let pluginClass = pluginBundle.principalClass,
            let pluginInterface = pluginClass as? PSPluginInterface.Type else {
                print("Incorrect setup for plugin at \(resourcePath) - bundle principal class must be PSPluginInterface")
                return
        }
        
        let toolPlugins = setupPluginsFor(PSPluginType.tool, pluginInterface: pluginInterface, resourcePath: resourcePath)
        tools += toolPlugins.map({ $0 as! PSToolInterface })
        
        let eventPlugins = setupPluginsFor(PSPluginType.event, pluginInterface: pluginInterface, resourcePath: resourcePath)
        events += eventPlugins.map({ $0 as! PSEventInterface })
        
        let attributePlugins = setupPluginsFor(PSPluginType.attribute, pluginInterface: pluginInterface, resourcePath: resourcePath)
        attributes += attributePlugins.map({ $0 as! PSAttributeInterface })
        
        let wvPlugins = setupPluginsFor(PSPluginType.windowView, pluginInterface: pluginInterface, resourcePath: resourcePath)
        windowViews += wvPlugins.map({ $0 as! PSWindowViewInterface })
        
        let actionPlugins = setupPluginsFor(PSPluginType.action, pluginInterface: pluginInterface, resourcePath: resourcePath)
        actions += actionPlugins.map({ $0 as! PSActionInterface })
        
        let conditionPlugins = setupPluginsFor(PSPluginType.condition, pluginInterface: pluginInterface, resourcePath: resourcePath)
        conditions += conditionPlugins.map({ $0 as! PSConditionInterface })
        
    }
        
    
    func setupPluginsFor(_ type : PSPluginType, pluginInterface : PSPluginInterface.Type, resourcePath : String) -> [NSObject] {
        let classes = pluginInterface.pluginsFor(type)
        var pluginInstances : [NSObject] = []
        for pluginClass in classes {
            
            let name = String(describing: Swift.type(of: pluginClass))
            let pluginObject = pluginClass.init()
            pluginInstances.append(pluginObject)
            pluginClasses[name] = pluginClass
            bundlePaths[name] = resourcePath
        }
        return pluginInstances
    }
}
