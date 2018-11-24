//
//  PSVaryByViewController.swift
//  PsyScopeEditor
//
//  Created by James on 07/10/2014.
//

import Cocoa

class PSVaryByUnrepresentedEntry {
    init(entry : Entry) {
        self.entry = entry
    }
    var entry : Entry!
}

class PSVaryByAttribute {
    var name : String = ""
    var unrepresentedEntries : [PSVaryByUnrepresentedEntry] = []
}

//used to pick a suitable attribute of another object
class PSVaryByAttributePopup: PSAttributePopup, NSOutlineViewDataSource, NSOutlineViewDelegate {

    var scriptData : PSScriptData
    var emptyNSString: NSString = "" //prevents outlineview bug
    var type : String
    var entry : Entry
    @IBOutlet var outlineView : NSOutlineView!
    @IBOutlet var selectButton : NSButton!
    var selectedAttribute : PSVaryByAttribute? = nil
    
    var attributes : [PSVaryByAttribute] = []

    init(baseEntry : Entry, scriptData : PSScriptData, type : String, setCurrentValueBlock : ((PSEntryElement)->())?) {
        self.scriptData = scriptData
        self.type = type
        self.entry = baseEntry
        super.init(nibName: "VaryByAttributePopup", bundle: Bundle(for:type(of: self)), currentValue: .null, displayName: "", setCurrentValueBlock: setCurrentValueBlock)
        
        //get all blocks, that this attribute is linked to, and list attributes
        let parentLinks = scriptData.getLinkedParentEntriesOfType(type, entry: entry)
        
        //now get all attributes
        var suitableAttributes : [Entry] = []
        for link in parentLinks {
            suitableAttributes += link.getAttributes()
        }
        
        //now for each attribute check it is represented in all parents, and add to list
        for attribute in suitableAttributes {
            let new_attribute = PSVaryByAttribute()
            new_attribute.name = attribute.name
            for link in parentLinks {
                if link.attributeNamed(attribute.name) == nil {
                    new_attribute.unrepresentedEntries.append(PSVaryByUnrepresentedEntry(entry: link))
                }
            }
            attributes.append(new_attribute)
        }

        //TODO when linking to a new block, add an empty entry for that attribute automatically (tricky)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectButton.isEnabled = false
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        let selected_item : AnyObject? = outlineView.item(atRow: outlineView.selectedRow) as AnyObject
        
        //check if item is attribute (rather than a block)
        if let i = selected_item as? PSVaryByAttribute {
            selectButton.isEnabled = true
            selectedAttribute = i
        } else {
            selectButton.isEnabled = false
        }
    }
    
    @IBAction func select(_ sender : AnyObject) {
        self.currentValue = PSGetFirstEntryElementForStringOrNull(selectedAttribute!.name)
        self.closeMyCustomSheet(self)
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if (item == nil) {
            //return number of attributes
            return attributes.count
        }
        
        //if item is attribute return list of unrepresented entries
        if let i = item as? PSVaryByAttribute {
            return i.unrepresentedEntries.count
        }
        
        
        return 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if (item == nil) {
            //return attribute
            return attributes[index]
        }
        
        //if item is a block return attribute
        if let i = item as? PSVaryByAttribute {
            return i.unrepresentedEntries[index]
        }
        
        return emptyNSString
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        //return true if item is attribute with unrepresented entries
        if let i = item as? PSVaryByAttribute {
            if i.unrepresentedEntries.count > 0 {
                return true
            }
        }
        
        return false
    }
    
    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        
        //if item is block return block name
        if let i = item as? PSVaryByAttribute {
            return i.name
        }
        
        //if item is attribute return attribute name
        if let i = item as? PSVaryByUnrepresentedEntry {
            return i.entry.name
        }
        
        return emptyNSString
    }
}
