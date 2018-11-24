//
//  PSAttributePickerCategories.swift
//  PsyScopeEditor
//
//  Created by James on 16/04/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

struct PSAttributePickerCategory  {
    var name : String = ""
    var userFriendlyName : String = ""
    var helpfulDescription : String = ""
}

var PSAttributePickerCategoriesCache : [PSAttributePickerCategory]?

func PSAttributePickerCategories(_ scriptData : PSScriptData) -> [PSAttributePickerCategory] {
    
    if let cachedCategories = PSAttributePickerCategoriesCache {
        return cachedCategories
    }
    
    var _categories : [PSAttributePickerCategory] = []
        
    var catNames : [String] = []
    //show just the relevent attributes
    for (_, a_plugin) in scriptData.pluginProvider.attributePlugins {
        for type in a_plugin.tools() as! [String] {
            if !catNames.contains(type) {
                catNames.append(type)
            }
        }
    }
    
    for (_, plugin) in scriptData.pluginProvider.toolPlugins as [String : PSToolInterface] {
        
        if catNames.contains(plugin.type()) {
            var new_type = PSAttributePickerCategory()
            new_type.name = plugin.type()
            new_type.userFriendlyName = plugin.type()
            new_type.helpfulDescription = plugin.helpfulDescription()
            _categories.append(new_type)
        }
        
    }
    
    for (_, plugin) in scriptData.pluginProvider.eventPlugins as [String : PSToolInterface] {
        if catNames.contains(plugin.type()) {
            var new_type = PSAttributePickerCategory()
            new_type.name = plugin.type()
            new_type.userFriendlyName = plugin.type()
            new_type.helpfulDescription = plugin.helpfulDescription()
            _categories.append(new_type)
        }
    }
    
    //sort alphabetically
    _categories = _categories.sorted(by: { (s1: PSAttributePickerCategory, s2: PSAttributePickerCategory) -> Bool in
        return s1.name < s2.name })
    
    PSAttributePickerCategoriesCache = _categories
    
    return _categories
}
