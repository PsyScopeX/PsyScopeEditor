//
//  PSChildTypeViewController.swift
//  PsyScopeEditor
//
//  Created by James on 22/05/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSChildTypeViewController : NSViewController {
    let entry : Entry
    let scriptData : PSScriptData
    let pluginViewController : PSPluginViewController
    var tableEntryName : String?
    var tableTypeName : String?
    
    
    init?(pluginViewController : PSPluginViewController, nibName : String) {
        self.entry = pluginViewController.entry
        self.scriptData = pluginViewController.scriptData
        self.pluginViewController = pluginViewController
        super.init(nibName: nibName, bundle: NSBundle(forClass:self.dynamicType))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func createForEntry(entry : Entry, pluginViewController : PSPluginViewController) -> PSChildTypeViewController {
        let scriptData = pluginViewController.scriptData
        if let _ = scriptData.getSubEntry("Groups", entry: entry) {
            return PSGroupsTableController(pluginViewController: pluginViewController)!
        } else if let _ = scriptData.getSubEntry("Blocks", entry: entry) {
            return PSBlocksTableController(pluginViewController: pluginViewController)!
        } else if let _ = scriptData.getSubEntry("Templates", entry: entry) {
            return PSTemplateTableController(pluginViewController: pluginViewController)!
        } else if let _ = scriptData.getSubEntry("Events", entry: entry) {
            return PSEventsTableController(pluginViewController: pluginViewController)!
        } else {
            //offer appropriate choice
            if entry.type == "Experiment" {
                return PSGroupsTableController(pluginViewController: pluginViewController)!
            } else if entry.type == "Group" {
                return PSBlocksTableController(pluginViewController: pluginViewController)!
            } else if entry.type == "Template" {
                return PSEventsTableController(pluginViewController: pluginViewController)!
            } else if entry.type == "Block"{
                return PSTemplateTableController(pluginViewController: pluginViewController)!
            } else {
                return PSEventsTableController(pluginViewController: pluginViewController)!
            }
        }
    }
}