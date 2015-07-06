//
//  PSActionPickerGroups.swift
//  PsyScopeEditor
//
//  Created by James on 16/04/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

//MARK: OutlineView objects

class PSActionPickerAction : NSObject {
    var type : String = ""
    var userFriendlyName : String = ""
    var helpfulDescription : String = ""
    var action : PSActionInterface! = nil
    var group : String = ""
}

class PSActionPickerGroup : NSObject {
    var name : String = ""
    var actions : [PSActionPickerAction] = []
}

var PSActionPickerGroupsCache : [PSActionPickerGroup]?

func PSActionPickerGroups(scriptData : PSScriptData) -> [PSActionPickerGroup] {
    
    if let cachedGroups = PSActionPickerGroupsCache {
        return cachedGroups
    }
    var groups : [PSActionPickerGroup] = []
    
    for (name, a_plugin) in scriptData.pluginProvider.actionPlugins {
        let new_Action = PSActionPickerAction()
        new_Action.type = a_plugin.type()
        new_Action.userFriendlyName = a_plugin.userFriendlyName()
        new_Action.helpfulDescription = a_plugin.helpfulDescription()
        new_Action.action = a_plugin
        new_Action.group = a_plugin.group()
        
        var found_group = false
        for act in groups {
            if new_Action.group == act.name {
                act.actions.append(new_Action)
                found_group = true
                break
            }
        }
        
        if !found_group {
            let new_group = PSActionPickerGroup()
            new_group.name = new_Action.group
            new_group.actions.append(new_Action)
            groups.append(new_group)
        }
    }
    
    //sort alphabetically
    groups = groups.sort({ (s1: PSActionPickerGroup, s2: PSActionPickerGroup) -> Bool in
        return s1.name < s2.name })
    
    for act in groups {
        act.actions = act.actions.sort({ (s1: PSActionPickerAction, s2: PSActionPickerAction) -> Bool in
            return s1.userFriendlyName < s2.userFriendlyName })
    }

    PSActionPickerGroupsCache = groups
    return groups
}

