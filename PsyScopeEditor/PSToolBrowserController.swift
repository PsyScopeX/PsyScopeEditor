//
//  PSToolBrowserController.swift
//  PsyScopeEditor
//
//  Created by James on 29/10/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

class PSToolBrowserController : NSObject, NSOutlineViewDelegate, NSOutlineViewDataSource {
    
    //Class to hold extensions
    class PSToolBrowserControllerGroup : NSObject {
        var name : String
        var extensions : [PSExtension]
        init(name: String, extensions : [PSExtension]) {
            self.name = name
            self.extensions = extensions
        }
    }
    
    @IBOutlet var toolBrowserView : PSToolBrowserView!
    
    var tableCellViewIdentifier = "PSToolBrowserViewItem"
    var pluginProvider : PSPluginProvider!
    var toolGroups : [PSToolBrowserControllerGroup] = [PSToolBrowserControllerGroup(name: "TOOLS" , extensions: []), PSToolBrowserControllerGroup(name: "EVENTS" , extensions: [])]
    
    func setup(_ pluginProvider : PSPluginProvider) {
        self.pluginProvider = pluginProvider
        refresh()
        toolBrowserView.expandItem(nil, expandChildren: true)
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            return toolGroups.count
        } else if let toolGroup = item as? PSToolBrowserControllerGroup {
            return toolGroup.extensions.count
        } else {
            return 0
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return item is PSToolBrowserControllerGroup
    }
    
    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        return item is PSToolBrowserControllerGroup
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
            return toolGroups[index]
        } else if let toolGroup = item as? PSToolBrowserControllerGroup {
            return toolGroup.extensions[index]
        } else {
            return ""
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        if let toolGroup = item as? PSToolBrowserControllerGroup {
            let view = outlineView.makeView(withIdentifier: convertToNSUserInterfaceItemIdentifier("HeaderCell"), owner: nil) as! NSTableCellView
            view.textField?.stringValue = toolGroup.name
            return view
        } else {
            let view = outlineView.makeView(withIdentifier: convertToNSUserInterfaceItemIdentifier("DataCell"), owner: nil) as! NSTableCellView
            view.objectValue = item
            return view
        }
        
    }
    
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        if item is PSExtension {
            return PSConstants.Spacing.objectTableViewRowHeight
        } else {
            return 18
        }
    }
    
    
    
    
    func refresh() {
        //get only tools that should appear in side bar (bug sometimes they are not there)
        _ = pluginProvider.toolPlugins
        _ =  pluginProvider.eventPlugins
        
        
        let tools = pluginProvider.extensions.filter({
            (tool : PSExtension) -> Bool in
            return tool.appearsInToolMenu
        })
        
        let events = pluginProvider.eventExtensions
        
        for toolGroup in toolGroups {
            if toolGroup.name == "TOOLS" {
                toolGroup.extensions = tools
            } else if toolGroup.name == "EVENTS" {
                toolGroup.extensions = events
            }
        }
        
        
        toolBrowserView.reloadData()
        
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSUserInterfaceItemIdentifier(_ input: String) -> NSUserInterfaceItemIdentifier {
	return NSUserInterfaceItemIdentifier(rawValue: input)
}
