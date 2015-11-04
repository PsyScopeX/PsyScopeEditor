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
    var currentWeights : [Int]?
    var levelsStringList : PSStringList
    
    init(scriptData : PSScriptData, listEntry : Entry) {
        
        self.scriptData = scriptData
        self.listEntry = listEntry
        
        
        //assert correct list things //WARNING MAY TRIGGER A REFRESH
        let is_list = scriptData.getOrCreateSubEntry("IsList", entry: listEntry, isProperty: true)
        if is_list.currentValue != "True" { is_list.currentValue = "True" }
        let levels = scriptData.getOrCreateSubEntry("Levels", entry: listEntry, isProperty: true)
        
        
        //get levels entry (contains names of items)
        levelsStringList = PSStringList(entry: levels, scriptData: scriptData)
        
        super.init()
        
        //get each field entry (any entry which isn't levels or islist)
        let sub_entries = listEntry.subEntries.array as! [Entry]
        for sub_entry in sub_entries {
            if sub_entry.name != "Levels" && sub_entry.name != "IsList" {
                let attributetype = PSAttributeType(fullType: sub_entry.type)
                
                //get correct interface for type
                let interface = scriptData.getAttributeInterfaceForFullType(attributetype.fullType)
                
                //create field
                let new_field = PSField(entry: sub_entry, list: self, interface: interface, scriptData: scriptData)
                fields.append(new_field)
            }
        }
        
        //get weights if they are there
        self.currentWeights = weightsColumn
        
        
    }

    
    var name : String {
        get {
            return listEntry.name
        }
        set {
            scriptData.renameEntry(listEntry, nameSuggestion: newValue)
        }
    }
    
    var hasWeights : Bool {
        get {
            if let levels = scriptData.getSubEntry("Levels", entry: listEntry) {
                return scriptData.getSubEntry("Weights", entry: levels) != nil
            }
            return false
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
            weights.currentValue = newWeights.map({ String($0) }).joinWithSeparator(" ")
        }
    }
    
    func weightForRow(row : Int) -> Int {
        if let currentWeights = currentWeights where row < currentWeights.count && row > -1 {
            return currentWeights[row]
        } else {
            return 1
        }
    }

    
    func setWeightsValueForRow(value : String, row: Int) {
        
        guard let intValue = Int(value) else { return }
        
        let nRows : Int = levelsStringList.count
        var newWeights : [Int] = []
        var oldWeights : [Int] = []
        if let weightsColumn = self.weightsColumn {
            oldWeights = weightsColumn
        }
        
        
        
        if nRows > 0 {
            for index in 0...(nRows - 1) {
                if index == row {
                    newWeights.append(intValue)
                }else if index < oldWeights.count {
                    newWeights.append(oldWeights[index])
                } else {
                    newWeights.append(1)
                }
            }
        }
        
        self.weightsColumn = newWeights
    }
    
    func addNewItem() {
        var number = levelsStringList.count + 1
        var name = "Item\(number)"
        while (levelsStringList.contains(name)) {
            number++
            name = "Item\(number)"
        }
        
        scriptData.beginUndoGrouping("Add New Item")
        levelsStringList.appendAsString(name)
        updateBlankEntries()
        scriptData.endUndoGrouping()
    }
    
    
    
    func updateBlankEntries() {
        let n_fields = levelsStringList.count
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
        
        if row < (levelsStringList.count) && !levelsStringList.contains(name){
            scriptData.beginUndoGrouping("Edit Level Name")
            levelsStringList[row] = name
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
        if row < (levelsStringList.count) {
            return levelsStringList[row]
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
        get { return levelsStringList.count }
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
        for (index, item) in levelsStringList.stringListRawUnstripped.enumerate() {
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
            levelsStringList.remove(name)
            updateBlankEntries()
            scriptData.endUndoGrouping()
        }
    }
    
    func fieldNames() -> [String] {
        return fields.map({ $0.entry.name })
    }
    
}