//
//  PSVaryByListPopup.swift
//  PsyScopeEditor
//
//  Created by James on 08/10/2014.
//

import Cocoa

//used to pick a suitable attribute from a list
class PSVaryByListPopup: PSAttributePopup, NSOutlineViewDataSource, NSOutlineViewDelegate {
    
    var scriptData : PSScriptData
    var emptyNSString: NSString = "" //prevents outlineview bug
    var entry : Entry
    @IBOutlet var outlineView : NSOutlineView!
    @IBOutlet var selectButton : NSButton!
    var selectedField : PSField? = nil
    var selectedList : PSList? = nil
    
    var lists : [PSList] = []
    
    init(baseEntry : Entry, scriptData : PSScriptData, setCurrentValueBlock : ((PSEntryElement)->())?) {
        self.scriptData = scriptData
        self.entry = baseEntry
        super.init(nibName: "VaryByListPopup", bundle: Bundle(for:type(of: self)), currentValue: .null, displayName: "", setCurrentValueBlock: setCurrentValueBlock)
        
        //get all lists
        let all_lists = scriptData.getBaseEntriesOfType(PSType.List)
        
        for list in all_lists {
            let l = PSList(scriptData: scriptData, listEntry: list)
            lists.append(l)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectButton.isEnabled = false
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        let selected_item : AnyObject? = outlineView.item(atRow: outlineView.selectedRow) as AnyObject
        
        //check if item is attribute (rather than a block)
        if let i = selected_item as? PSList {
            selectButton.isEnabled = false
            selectedList = i
            selectedField = nil
        } else if let i = selected_item as? PSField {
            selectButton.isEnabled = true
            selectedList = i.list
            selectedField = i
        } else {
            selectButton.isEnabled = false
            selectedList = nil
            selectedField = nil
        }
    }
    
    @IBAction func select(_ sender : AnyObject) {
        self.currentValue = PSGetFirstEntryElementForStringOrNull("FactorAttrib(\(selectedList!.name),\(selectedField!.entry.name))")
        self.closeMyCustomSheet(self)
    }
    
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if (item == nil) {
            //return number of attributes
            return lists.count
        }
        
        //if item is attribute return list of unrepresented entries
        if let i = item as? PSList {
            return i.fields.count
        }
        
        
        return 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if (item == nil) {
            //return attribute
            return lists[index]
        }
        
        //if item is a block return attribute
        if let i = item as? PSList {
            return i.fields[index]
        }
        
        return emptyNSString
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        //return true if item is attribute with unrepresented entries
        if let i = item as? PSList {
            if i.fields.count > 0 {
                return true
            }
        }
        
        return false
    }
    
    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        
        //if item is block return block name
        if let i = item as? PSList {
            return i.name
        }
        
        //if item is attribute return attribute name
        if let i = item as? PSField {
            return i.entry.name
        }
        
        return emptyNSString
    }
}
