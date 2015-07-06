//
//  PSList.swift
//  PsyScopeEditor
//
//  Created by James on 13/02/2015.
//

import Foundation

class PSList : NSObject {
    var scriptData : PSScriptData!
    var listEntry : Entry!
    var fields : [PSField] = []
    var levelsEntry : PSStringList! = nil
    
    
    class func initializeEntry(entry : Entry, scriptData : PSScriptData) {
        var is_list = scriptData.getOrCreateSubEntry("IsList", entry: entry, isProperty: true)
        is_list.currentValue = "True"
        
        var levels = scriptData.getOrCreateSubEntry("Levels", entry: entry, isProperty: true)
    }
    
    init?(scriptData : PSScriptData, listEntry : Entry) {
        super.init()
        self.scriptData = scriptData
        self.listEntry = listEntry
        
        //1. check for existing list
        if scriptData.getSubEntry("IsList", entry: listEntry) == nil {
            return nil
        }
        
        var levels : Entry! = scriptData.getSubEntry("Levels", entry: listEntry)!
        if levels == nil {
            return nil
        }
        
        levelsEntry = PSStringList(entry: levels, scriptData: scriptData)
        var sub_entries = listEntry.subEntries.array as! [Entry]
        for sub_entry in sub_entries {
            if sub_entry.name != "Levels" && sub_entry.name != "IsList" {
                var attributetype = PSAttributeType(fullType: sub_entry.type)
                var interface : PSAttributeInterface! = nil
                //get correct interface for type
                for attribute in scriptData.pluginProvider.attributes {
                    //println("\(attribute.fullType) =? \(attributetype.fullType)")
                    if attribute.fullType == attributetype.fullType {
                        interface = attribute.interface
                        break
                    }
                }
                
                if interface == nil {
                    interface = PSAttributeGeneric()
                }
                
                var new_field = PSField(entry: sub_entry, list: self, interface: interface, scriptData: scriptData)
                fields.append(new_field)
            }
        }
        
        
    }
    
    var name : String {
        get {
            return listEntry.name
        }
        set {
            scriptData.renameEntry(listEntry, nameSuggestion: newValue)
        }
    }
    
    func addNewItem() {
        var number = levelsEntry.count + 1
        var name = "Item\(number)"
        while (levelsEntry.contains(name)) {
            number++
            name = "Item\(number)"
        }
        levelsEntry.appendAsString(name)
        updateBlankEntries()
    }
    
    
    
    func updateBlankEntries() {
        var n_fields = levelsEntry.count
        for field in fields {
            var n_missing_values = n_fields - field.count
            if n_missing_values > 0 {
                for index in 1...n_missing_values {
                    field.appendAsString("NULL")
                }
            }
        }
    }
    
    func addNewField(new_type : PSAttributeType, interface : PSAttributeInterface?) -> PSField {
        
        var new_entry = scriptData.getOrCreateSubEntry(new_type.name, entry: listEntry, isProperty: true)
        if let int = interface {
            new_entry.currentValue = int.defaultValue()
        } else {
            new_entry.currentValue = "NULL"
        }
        
        new_entry.type = new_type.fullType
        
        var new_field = PSField(entry: new_entry, list: self, interface: interface, scriptData: scriptData)
        fields.append(new_field)
        updateBlankEntries()
        return new_field
    }
    
    func setName(name : String, forRow row : Int) -> Bool {
        
        if row < (levelsEntry.count) && !levelsEntry.contains(name){
            levelsEntry[row] = name
            return true
        }
        return false
    }
    
    func nameForColumn(col : Int) -> String {
        if col < fields.count {
            return fields[col].entry.name
        }
        return ""
    }
    
    func nameForRow(row : Int) -> String {
        if row < (levelsEntry.count) {
            return levelsEntry[row]
        } else {
            return ""
        }
    }
    
    func setItem(item : AnyObject, forCol col: Int, andRow row: Int) {
        if col < fields.count && row < (fields[col].count) {
            fields[col][row] = item as! String
        }
    }
    
    func itemAtColumn(col : Int, andRow row: Int) -> AnyObject {
        if col < fields.count && row < (fields[col].count) {
            var return_val = fields[col][row]
            return return_val
        } else {
            return ""
        }
    }
    
    var count : Int {
        get { return levelsEntry.count }
    }
    
    func deleteColumn(col : Int) {
        var toDelete = fields[col]
        scriptData.deleteSubEntryFromBaseEntry(toDelete.entry.parentEntry, subEntry: toDelete.entry)
        fields = fields.filter({ $0 != toDelete })
        updateBlankEntries()
    }
    
    func deleteColumnByName(name : String) {
        var to_remove : [PSField] = []
        for f in fields {
            if f.entry.name == name {
                scriptData.deleteSubEntryFromBaseEntry(f.entry.parentEntry, subEntry:f.entry)
                to_remove.append(f)
            }
        }
        
        for tr in to_remove {
            fields = fields.filter({ $0 != tr })
        }
        updateBlankEntries()
    }
    
    func typeAtColumn(col : Int) -> PSAttributeType {
        if col < fields.count {
            var return_val = fields[col].type
            return return_val
        } else {
            return PSAttributeType(fullType: "")
        }
    }
    func deleteRowByName(name : String) {
        for (index, item) in levelsEntry.stringListRawUnstripped.enumerate() {
            if item == name {
                for field in fields {
                    field.removeAtIndex(index)
                }
            }
        }
        levelsEntry.remove(name)
        updateBlankEntries()
    }
    
    func deleteRow(row : Int) {
        levelsEntry.removeAtIndex(row)
    }
    
    func fieldNames() -> [String] {
        var names : [String] = []
        for field in fields {
            names.append(field.entry.name)
        }
        return names
    }
    
}