//
//  PSImportFileToolBrowser.swift
//  PsyScopeEditor
//
//  Created by James on 17/02/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation


@objc class PSImportFileBrowserViewDelegate : NSObject, NSTableViewDelegate {
    
    @IBOutlet var objectTableView : NSTableView!
    @IBOutlet var arrayController : NSArrayController!
    
    var tableCellViewIdentifier = "PSToolBrowserViewItem"
    var content : [PSExtension] = []
    var pluginProvider : PSPluginProvider!
    
    func setup(pluginProvider : PSPluginProvider) {
        self.pluginProvider = pluginProvider
        let nib = NSNib(nibNamed: "ToolBrowserViewItem", bundle: NSBundle(forClass:self.dynamicType))
        objectTableView.registerNib(nib!, forIdentifier: tableCellViewIdentifier)
        refresh()
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let new_view  = objectTableView.makeViewWithIdentifier(tableCellViewIdentifier, owner: self) as! PSToolBrowserViewItem
        return new_view
    }
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return PSConstants.Spacing.objectTableViewRowHeight
    }
    
    
    
    func setPossibleTypes(tools : [PSToolInterface]) {
        possTypes = []
        for t in tools {
            for pse in pluginProvider.eventExtensions {
                if pse.type == t.type() {
                    possTypes.append(pse)
                }
            }
        }
    }
    
    var possTypes : [PSExtension] = []
    
    func refresh() {
        arrayController.content = possTypes
        objectTableView.reloadData()
    }
    
}