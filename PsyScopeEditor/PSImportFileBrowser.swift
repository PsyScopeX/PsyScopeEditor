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
    
    func setup(_ pluginProvider : PSPluginProvider) {
        self.pluginProvider = pluginProvider
        let nib = NSNib(nibNamed: "ToolBrowserViewItem", bundle: Bundle(for:type(of: self)))
        objectTableView.register(nib!, forIdentifier: convertToNSUserInterfaceItemIdentifier(tableCellViewIdentifier))
        refresh()
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let new_view  = objectTableView.makeView(withIdentifier: convertToNSUserInterfaceItemIdentifier(tableCellViewIdentifier), owner: self) as! PSToolBrowserViewItem
        return new_view
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return PSConstants.Spacing.objectTableViewRowHeight
    }
    
    
    
    func setPossibleTypes(_ tools : [PSToolInterface]) {
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSUserInterfaceItemIdentifier(_ input: String) -> NSUserInterfaceItemIdentifier {
	return NSUserInterfaceItemIdentifier(rawValue: input)
}
