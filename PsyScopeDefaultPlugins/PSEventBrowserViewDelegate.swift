//
//  PSEventBrowserViewDelegate.swift
//  PsyScopeEditor
//
//  Created by James on 29/10/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

class PSEventBrowserViewDelegate : NSObject, NSTableViewDelegate {
    
    @IBOutlet var objectTableView : PSEventBrowserView!
    @IBOutlet var arrayController : NSArrayController!
    
    var tableCellViewIdentifier = "PSToolBrowserViewItem"
    var content : [PSExtension] = []
    var pluginProvider : PSPluginProvider!
    
    func setup(_ pluginProvider : PSPluginProvider) {
        self.pluginProvider = pluginProvider
        let nib = NSNib(nibNamed: "ToolBrowserViewItem", bundle: Bundle(for:type(of: self)))
        objectTableView.register(nib!, forIdentifier: tableCellViewIdentifier)
        refresh()
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let new_view  = objectTableView.make(withIdentifier: tableCellViewIdentifier, owner: self) as! PSToolBrowserViewItem
        return new_view
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return PSConstants.Spacing.objectTableViewRowHeight
    }
    
    
    
    func refresh() {
        //get only tools that should appear in side bar
        _ = pluginProvider.eventPlugins
        
        //because sometimes they are not there when this call is made
        
        
        arrayController.content = pluginProvider.eventExtensions
        objectTableView.reloadData()
    }
    
}
