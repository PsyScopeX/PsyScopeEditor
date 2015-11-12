//
//  PSPluginSingleton.swift
//  PsyScopeEditor
//
//  Created by James on 22/08/2014.
//

import Cocoa

class PSPluginSingleton: NSObject {
    
    //thread safe singleton pattern
    class var sharedInstance: PSPluginSingleton {
        
        struct Static {
            
            static var instance: PSPluginSingleton?
            static var token: dispatch_once_t = 0
            }
        
        dispatch_once(&Static.token) {
            Static.instance = PSPluginSingleton()
            
            var pstools : [NSObject : AnyObject]! = Static.instance?.toolObjects
            let psattributes : [NSObject : AnyObject]! = Static.instance?.attributeObjects
            var psevents : [NSObject : AnyObject]! = Static.instance?.eventObjects
            Static.instance?.tools = []
            Static.instance?.eventTools = []
            Static.instance?.attributes = []
            let tool_names =  Static.instance?.toolObjectOrder
            for tool_name in tool_names!  {
                
                let tool = pstools[tool_name] as! PSToolInterface
                
                let empty_object : PSExtension = PSExtension()
                empty_object.type = tool.type()
                empty_object.helpString = tool.helpfulDescription()
                empty_object.icon = tool.icon()
                empty_object.toolClass = tool
                empty_object.appearsInToolMenu = tool.appearsInToolMenu()
                empty_object.isEvent = false
                Static.instance?.tools.append(empty_object)
            }
            
            let event_names = Static.instance?.eventObjectOrder
            for event_name in event_names! {
                
                let tool = psevents[event_name] as! PSToolInterface
      
                let empty_object = PSExtension()
                empty_object.type = tool.type()
                empty_object.helpString = tool.helpfulDescription()
                empty_object.icon = tool.icon()
                empty_object.toolClass = tool
                empty_object.appearsInToolMenu = tool.appearsInToolMenu()
                empty_object.isEvent = true
                Static.instance?.eventTools.append(empty_object)
            }
            
            let loadedTools : [PSExtension]! = Static.instance?.tools
            
            for plugin in psattributes {
                
                let attribute = plugin.1 as! PSAttributeInterface
                
                //which entry types is this attribute for?
                let entryTypes = attribute.tools() as! [String]
                
                for type in entryTypes {
                
                    //write your code to add data
                    let empty_object = PSAttribute()
                    
                    empty_object.name = attribute.codeName()
                    empty_object.interface = attribute
                    empty_object.fullType = PSAttributeType(name: attribute.codeName(), parentType: PSType.FromName(type)).fullType
                    
                    //link attributes to tools
                    for et in loadedTools {
                        if et.type == type {
                            et.attributes.append(empty_object)
                        }
                    }
                    Static.instance?.attributes.append(empty_object)
                }
                
                        
            }
                    
        }
                
        
            
        
        
        return Static.instance!
    }

    var tools : [PSExtension]!
    var eventTools : [PSExtension]!
    var attributes : [PSAttribute]!

    func typeIsEvent(type : String) -> Bool {
        for anObject in eventTools {
            if anObject.type == type {
                return true
            }
        }
        return false
    }

    func getIconForType(type : String) -> NSImage? {
        for anObject in tools {
            if anObject.type == type {
                return anObject.icon
            }
        }
        
        for anObject in eventTools {
            if anObject.type == type {
                return anObject.icon
            }
        }
        return nil
    }
    
    func getPlugin(name : String) -> PSToolInterface? {
        var r = toolObjects[name]
        
        if (r == nil) {
            r = eventObjects[name]
        }
        return r
    }
    
    var _actionObjects : [String : PSActionInterface]? = nil
    var actionObjects : [String : PSActionInterface] {
        if let loaded = _actionObjects {
            return loaded
        }
        let loader : PSPluginLoader! = pluginLoader
        var new_actionObjects  : [String : PSActionInterface] = [:]
        let initial_actionObjects : [AnyObject] = loader.actions
        for obj in initial_actionObjects {
            if let psattr = obj as? PSActionInterface {
                new_actionObjects[psattr.type()] = psattr
            }
        }
        _actionObjects = new_actionObjects
        return _actionObjects!
    }
    
    var _conditionObjects : [String : PSConditionInterface]? = nil
    var conditionObjects : [String : PSConditionInterface] {
        if let loaded = _conditionObjects {
            return loaded
        }
        let loader : PSPluginLoader! = pluginLoader
        var new_conditionObjects  : [String : PSConditionInterface] = [:]
        let initial_conditionObjects : [AnyObject] = loader.conditions
        for obj in initial_conditionObjects {
            if let psattr = obj as? PSConditionInterface {
                new_conditionObjects[psattr.type()] = psattr
            }
        }
        _conditionObjects = new_conditionObjects
        return _conditionObjects!
    }
    
    var eventObjectOrder : [String]! = nil
    var _eventObjects : [String : PSToolInterface]? = nil
    var eventObjects : [String : PSToolInterface] {
        if let loaded = _eventObjects {
            return loaded
            }
            let loader : PSPluginLoader! = pluginLoader
            var new_toolObjects  : [String : PSToolInterface] = [:]
            eventObjectOrder = []
            let initial_toolObjects : [AnyObject] = loader.events
            for obj in initial_toolObjects {
                if let psattr = obj as? PSToolInterface {
                    eventObjectOrder.append(psattr.type())
                    new_toolObjects[psattr.type()] = psattr
                }
            }
            _eventObjects = new_toolObjects
            return _eventObjects!
    }
    
    var _attributeObjects : [String : PSAttributeInterface]? = nil
    var attributeObjects : [String : PSAttributeInterface] {
        if let loaded = _attributeObjects {
            return loaded
            }
            let loader : PSPluginLoader! = pluginLoader
            var new_toolObjects  : [String : PSAttributeInterface] = [:]
            let initial_toolObjects : [AnyObject] = loader.attributes
            for obj in initial_toolObjects {
                if let psattr = obj as? PSAttributeInterface {
                    new_toolObjects[psattr.psclassName()] = psattr
                }
            }
            _attributeObjects = new_toolObjects
            return _attributeObjects!
    }
    
    var toolObjectOrder : [String]!
    var _toolObjects : [String : PSToolInterface]? = nil
    var toolObjects : [String : PSToolInterface] {
        if let loaded = _toolObjects {
            return loaded
            }
            let loader : PSPluginLoader! = pluginLoader
            var new_toolObjects  : [String : PSToolInterface] = [:]
            toolObjectOrder = []
            let initial_toolObjects : [AnyObject] = loader.tools
            for obj in initial_toolObjects {
                if let pstool = obj as? PSToolInterface {
                    toolObjectOrder.append(pstool.type())
                    new_toolObjects[pstool.type()] = pstool
                }
            }
            _toolObjects = new_toolObjects
            return _toolObjects!
    }
    
    
    var pluginLoader : PSPluginLoader {
        if let loader = _pluginLoader {
            return loader
            }
            _pluginLoader = PSPluginLoader()
            return _pluginLoader!
    }
    var _pluginLoader : PSPluginLoader? = nil
    
    
    func createPluginProvider() -> PSPluginProvider {
        return PSPluginProvider(attributePlugins: attributeObjects, toolPlugins: toolObjects, eventPlugins: eventObjects, actionPlugins: actionObjects, conditionPlugins: conditionObjects, attributeSourceTools: attributeSourceTools, extensions: tools, eventExtensions: eventTools, attributes: attributes)
    }
    
    
    func getViewControllerFor(entry : Entry, document : Document) -> PSPluginViewController? {
        
        if let plugin = toolObjects[entry.type] {
            return plugin.getPropertiesViewController(entry, withScript: document.scriptData)
        } else if let plugin = eventObjects[entry.type] {
            return plugin.getPropertiesViewController(entry, withScript: document.scriptData)
        }
        return nil
    }
    
    func getExtension(type : String) -> PSExtension? {
        for obj in tools {
            if obj.type == type {
                return obj
            }
        }
        
        return nil
    }
    
    
    //dictionary of only tools which can pass attributes (e.g. BlockAttrib)
    var _attributeSourceTools : [String : PSToolInterface]? = nil
    var attributeSourceTools : [String : PSToolInterface] {
        
        if let loaded = _attributeSourceTools {
            return loaded
        }
        
        var ast : [String : PSToolInterface] = [:]
        for (name, ext): (String, PSToolInterface) in toolObjects {
            if ext.isSourceForAttributes() {
                ast[name] = ext
            }
        }
        _attributeSourceTools = ast
        return ast
    }
    
    
    
}
