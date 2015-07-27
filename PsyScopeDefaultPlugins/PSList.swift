//
//  PSList.swift
//  PsyScopeEditor
//
//  Created by James on 13/02/2015.
//

import Foundation

class PSList : NSObject {
    var scriptData : PSScriptData
    var listEntry : Entry
    var fields : [PSField] = []
    var levelsEntry : PSStringList! = nil
    
    init?(scriptData : PSScriptData, listEntry : Entry) {
        
        self.scriptData = scriptData
        self.listEntry = listEntry
        super.init()
        
        //check for existing list / levels sub entries
        if scriptData.getSubEntry("IsList", entry: listEntry) == nil { return nil }
        guard let levels : Entry = scriptData.getSubEntry("Levels", entry: listEntry) else { return nil }
        
        //get levels entry (contains names of items)
        levelsEntry = PSStringList(entry: levels, scriptData: scriptData)
        
        //get each field entry (any entry which isn't levels or islist)
        let sub_entries = listEntry.subEntries.array as! [Entry]
        for sub_entry in sub_entries {
            if sub_entry.name != "Levels" && sub_entry.name != "IsList" {
                var attributetype = PSAttributeType(fullType: sub_entry.type)
                
                //get correct interface for type
                let interface = scriptData.getAttributeInterfaceForFullType(attributetype.fullType)
                
                //create field
                let new_field = PSField(entry: sub_entry, list: self, interface: interface, scriptData: scriptData)
                fields.append(new_field)
            }
        }
        
        
    }
    
    func assertEntryIsList(entry : Entry, scriptData : PSScriptData) {
        let is_list = scriptData.getOrCreateSubEntry("IsList", entry: entry, isProperty: true)
        if is_list.currentValue != "True" { is_list.currentValue = "True" }
        scriptData.getOrCreateSubEntry("Levels", entry: entry, isProperty: true)
    }
    
    var name : String {
        get {
            return listEntry.name
        }
        set {
            scriptData.renameEntry(listEntry, nameSuggestion: newValue)
        }
    }
    
    var weightsColumn : [Int]? {
        
        get {
            if let levels = scriptData.getSubEntry("Levels", entry: listEntry),
                weights = scriptData.getSubEntry("Weights", entry: levels) {
                    
                    return weights.currentValue.componentsSeparatedByString(" ").map({
                        if let i = Int($0){
                            return i
                        }else {
                            return 1
                        }
                    })
            }
            return nil
        }
        
        set {
            scriptData.beginUndoGrouping("Edit Weights")
            defer { scriptData.endUndoGrouping() }
            
            let levels = scriptData.getOrCreateSubEntry("Levels", entry: listEntry, isProperty: true)
            
            guard let newWeights = newValue else {
                scriptData.deleteNamedSubEntryFromParentEntry(levels, name: "Weights")
                return
            }
            
            let weights = scriptData.getOrCreateSubEntry("Weights", entry: levels, isProperty: true)
            weights.currentValue = " ".join(newWeights.map({ String($0) }))
        }
    }
    
    func addNewItem() {
        var number = levelsEntry.count + 1
        var name = "Item\(number)"
        while (levelsEntry.contains(name)) {
            number++
            name = "Item\(number)"
        }
        
        scriptData.beginUndoGrouping("Add New Item")
        levelsEntry.appendAsString(name)
        updateBlankEntries()
        scriptData.endUndoGrouping()
    }
    
    
    
    func updateBlankEntries() {
        let n_fields = levelsEntry.count
        for field in fields {
            let n_missing_values = n_fields - field.count
            if n_missing_values > 0 {
                for _ in 1...n_missing_values {
                    field.appendAsString("NULL")
                }
            } else if n_missing_values < 0 {
                for _ in 1...abs(n_missing_values) {
                    //remove last
                    field.removeAtIndex(field.count - 1)
                }
            }
        }
    }
    
    func addNewField(new_type : PSAttributeType, interface : PSAttributeInterface?) -> PSField {
        scriptData.beginUndoGrouping("Add New Field")
        let new_entry = scriptData.getOrCreateSubEntry(new_type.name, entry: listEntry, isProperty: true)
        if let int = interface {
            new_entry.currentValue = int.defaultValue()
        } else {
            new_entry.currentValue = "NULL"
        }
        
        new_entry.type = new_type.fullType
        
        let new_field = PSField(entry: new_entry, list: self, interface: interface, scriptData: scriptData)
        fields.append(new_field)
        updateBlankEntries()
        scriptData.endUndoGrouping()
        return new_field
    }
    
    func setItemName(name : String, forRow row : Int) -> Bool {
        
        if row < (levelsEntry.count) && !levelsEntry.contains(name){
            scriptData.beginUndoGrouping("Edit Level Name")
            levelsEntry[row] = name
            scriptData.endUndoGrouping()
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
            scriptData.beginUndoGrouping("Edit Item")
            fields[col][row] = item as! String
            scriptData.endUndoGrouping()
        }
    }
    
    func itemAtColumn(col : Int, andRow row: Int) -> AnyObject {
        if col < fields.count && row < (fields[col].count) {
            let return_val = fields[col][row]
            return return_val
        } else {
            return ""
        }
    }
    
    var count : Int {
        get { return levelsEntry.count }
    }
    
    func removeField(col : Int) {
        if col < fields.count && col > 0 {
            let toDelete = fields[col]
            scriptData.beginUndoGrouping("Remove Field")
            scriptData.deleteSubEntryFromBaseEntry(toDelete.entry.parentEntry, subEntry: toDelete.entry)
            fields = fields.filter({ $0 != toDelete })
            updateBlankEntries()
            scriptData.endUndoGrouping()
        }
    }
    
    func removeFieldByName(name : String) {
        for (index, field) in fields.enumerate() {
            if field.entry.name == name {
                removeField(index)
                return
            }
        }
    }
    
    func typeAtColumn(col : Int) -> PSAttributeType {
        if col < fields.count && col > 0 {
            return fields[col].type
        } else {
            return PSAttributeType(fullType: "")
        }
    }
    
    func removeRowByName(name : String) {
        for (index, item) in levelsEntry.stringListRawUnstripped.enumerate() {
            if item == name {
                removeRow(index)
                return
            }
        }
        
    }
    
    func removeRow(row : Int) {
        for field in fields {
            scriptData.beginUndoGrouping("Remove Level")
            field.removeAtIndex(row)
            levelsEntry.remove(name)
            updateBlankEntries()
            scriptData.endUndoGrouping()
        }
    }
    
    func fieldNames() -> [String] {
        return fields.map({ $0.entry.name })
    }
    
}