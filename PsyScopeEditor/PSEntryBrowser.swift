//
//  PSEntryBrowser.swift
//  PsyScopeEditor
//
//  Created by James on 16/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSEntryBrowserCategory: Hashable, Equatable {
    var name : String
    var icon : NSImage?
    var entries : [Entry]
    init (name: String, icon: NSImage?, entries: [Entry]) {
        self.name = name
        self.icon = icon
        self.entries = entries
    }
    
    var hashValue: Int { return name.hashValue }
    
}

func ==(lhs: PSEntryBrowserCategory, rhs: PSEntryBrowserCategory) -> Bool {
    return lhs.hashValue == rhs.hashValue
}


class PSEntryBrowser : NSObject, NSOutlineViewDataSource, NSOutlineViewDelegate {
    @IBOutlet var outlineView : NSOutlineView!
    @IBOutlet var scriptView : NSTextView!
    @IBOutlet var searchController : PSEntryBrowserSearchController!
    
    var scriptData : PSScriptData!
    var categories : [PSEntryBrowserCategory] = []
    
    func setup(scriptData : PSScriptData) {
        self.scriptData = scriptData
        let nib = NSNib(nibNamed: "PSEntryBrowserCell", bundle: NSBundle(forClass:self.dynamicType))!
        outlineView.registerNib(nib, forIdentifier: "PSEntryBrowserCell")
    }
    
    func update() {
        let entries = scriptData.getBaseEntries()
 
        var current_categories = Set<PSEntryBrowserCategory>()
        for entry in entries {
            current_categories.insert(categoryForType(entry.type))
        }
        
        for cat in current_categories {
            cat.entries = []
        }
        
        for entry in entries {
            
            categoryForType(entry.type).entries.append(entry)
        }
        
        for cat in current_categories {
            cat.entries = cat.entries.sort({ (s1: Entry, s2: Entry) -> Bool in
                return s1.name < s2.name })
        }
        
        categories = Array(current_categories)
        
        categories = categories.sort({ (s1: PSEntryBrowserCategory, s2: PSEntryBrowserCategory) -> Bool in
            return s1.name < s2.name })
        
        var iconForName : [String : NSImage] = [:]
        
        for cat in categories {
            for entry in cat.entries {
                iconForName[entry.name] = cat.icon
            }
        }
        
        searchController.update(iconForName)

        outlineView.reloadData()
    }
    
    //stored display info
    var icons : [String : NSImage] = [:]
    var categoryDictionary : [String : PSEntryBrowserCategory] = [:]
    var typeToCategoryName : [String : String] = [:]
    
    func categoryForType(type : String) -> PSEntryBrowserCategory {
        //search for pre stored
        if let categoryName = typeToCategoryName[type], category = categoryDictionary[categoryName] {
            return category
        }
        
        if let plugin = scriptData.pluginProvider.toolPlugins[type] {
            icons[type] = plugin.icon()
            return categoryForCategoryName(plugin.type(), associateType: type, icon: icons[type]!)
        }
        
        if let event = scriptData.pluginProvider.eventPlugins[type] {
            icons[type] = event.icon()
            return categoryForCategoryName("Event", associateType: type, icon: icons[type]!)
        }
        
        if icons[type] == nil {
            icons[type] = NSImage(named: NSImageNameActionTemplate)
        }
        return categoryForCategoryName("Other", associateType: type, icon: icons[type]!)
    }
    
    func categoryForCategoryName(name : String, associateType : String?, icon: NSImage) -> PSEntryBrowserCategory {
        if let type = associateType {
            typeToCategoryName[type] = name
            
        }
        if let category = categoryDictionary[name] {
            return category
        } else {
            let category = PSEntryBrowserCategory(name: name, icon: icon, entries: [])
            categoryDictionary[name] = category
            return category
        }
    }
    
    func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        if item == nil {
            return categories[index]
        } else if let category = item as? PSEntryBrowserCategory {
            return category.entries[index]
        }
        return 0
    }
    
    func outlineView(outlineView: NSOutlineView, isGroupItem item: AnyObject) -> Bool {
        if item is PSEntryBrowserCategory {
            return true
        }
        
        return false
    }
    
    func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
        if let category = item as? PSEntryBrowserCategory {
            if category.entries.count > 0 {
                return true
            }
        }
        return false
    }
    
    func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
        if item == nil {
            return categories.count
        } else if let category = item as? PSEntryBrowserCategory {
            return category.entries.count
        }
        return 0
    }
    
    func outlineView(outlineView: NSOutlineView, viewForTableColumn tableColumn: NSTableColumn?, item: AnyObject) -> NSView? {
        let view = outlineView.makeViewWithIdentifier("PSEntryBrowserCell", owner: nil) as! NSTableCellView
        if let category = item as? PSEntryBrowserCategory {
            view.textField?.stringValue = category.name
            view.imageView!.image = category.icon
            
        } else if let entry = item as? Entry {
            view.textField?.stringValue = entry.name
            view.imageView!.image = icons[entry.type]
        }
        return view
    }
    
    func outlineView(outlineView: NSOutlineView, shouldSelectItem item: AnyObject) -> Bool {
        if let entry = item as? Entry {
            scriptData.selectionInterface.selectEntry(entry)
            
        }
        return true
    }
}