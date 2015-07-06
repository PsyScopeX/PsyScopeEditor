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

    init(baseEntry : Entry, scriptData : PSScriptData, type : String, setCurrentValueBlock : ((String)->())?) {
        self.scriptData = scriptData
        self.type = type
        self.entry = baseEntry
        super.init(nibName: "VaryByAttributePopup", bundle: NSBundle(forClass:self.dynamicType), currentValue: "", displayName: "", setCurrentValueBlock: setCurrentValueBlock)
        
        //get all blocks, that this attribute is linked to, and list attributes
        var parentLinks = scriptData.getLinkedParentEntriesOfType(type, entry: entry)
        
        //now get all attributes
        var suitableAttributes : [Entry] = []
        for link in parentLinks {
            suitableAttributes += link.getAttributes()
        }
        
        //now for each attribute check it is represented in all parents, and add to list
        for attribute in suitableAttributes {
            var new_attribute = PSVaryByAttribute()
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
        selectButton.enabled = false
    }
    
    func outlineViewSelectionDidChange(notification: NSNotification!) {
        let selected_item : AnyObject? = outlineView.itemAtRow(outlineView.selectedRow)
        
        //check if item is attribute (rather than a block)
        if let i = selected_item as? PSVaryByAttribute {
            selectButton.enabled = true
            selectedAttribute = i
        } else {
            selectButton.enabled = false
        }
    }
    
    @IBAction func select(sender : AnyObject) {
        self.currentValue = selectedAttribute!.name
        self.closeMyCustomSheet(self)
    }
    
    
    func outlineView(outlineView: NSOutlineView!, numberOfChildrenOfItem item: AnyObject!) -> Int {
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
    
    func outlineView(outlineView: NSOutlineView!, child index: Int, ofItem item: AnyObject!) -> AnyObject! {
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
    
    func outlineView(outlineView: NSOutlineView!, isItemExpandable item: AnyObject!) -> Bool {
        //return true if item is attribute with unrepresented entries
        if let i = item as? PSVaryByAttribute {
            if i.unrepresentedEntries.count > 0 {
                return true
            }
        }
        
        return false
    }
    
    func outlineView(outlineView: NSOutlineView!, objectValueForTableColumn tableColumn: NSTableColumn!, byItem item: AnyObject!) -> AnyObject! {
        
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
