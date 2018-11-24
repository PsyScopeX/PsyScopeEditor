//
//  PSGroup.swift
//  PsyScopeEditor
//
//  Created by James on 23/05/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

open class PSGroup {
    
    let entry : Entry
    let scriptData : PSScriptData
    
    public init(entry : Entry, scriptData : PSScriptData) {
        self.entry = entry
        self.scriptData = scriptData
    }
    
    open func getCriteria() -> [(variable: PSSubjectVariable,value: String)] {
        
        var existingCriteria : [(variable: PSSubjectVariable,value: String)] = []
        
        if let criteria = scriptData.getSubEntry("Criteria", entry: entry) {
            
            let subjectInformation = PSSubjectInformation(scriptData: scriptData)
            
            for subEntry in criteria.subEntries.array as! [Entry] {
                for subjectVariable in subjectInformation.allVariables {
                    if subEntry.name == subjectVariable.name {
                        //var newExistingCriteria =
                        existingCriteria.append(variable: subjectVariable, value: subEntry.currentValue as String)
                    }
                }
            }
            
        }
        return existingCriteria
    }
    
    open func setCriteria(_ criteria : [(variable: PSSubjectVariable,value: String)]) {
        if criteria.count == 0 {
            scriptData.deleteNamedSubEntryFromParentEntry(entry, name: "Criteria")
        } else {
            let criteriaEntry = scriptData.getOrCreateSubEntry("Criteria", entry: entry, isProperty: true)
            scriptData.deleteSubEntries(criteriaEntry)
            
            let conditionEntry = scriptData.getOrCreateSubEntry("Condition", entry: criteriaEntry, isProperty: true)
            conditionEntry.currentValue = entry.name
            let conditionAtEntry = scriptData.getOrCreateSubEntry("\"@\"", entry: conditionEntry, isProperty: true)
            conditionAtEntry.currentValue = "Condition"
            
            for (variable, value) in criteria {
                addCriteria(variable, value: value)
            }
        }
    }
    
    open func addCriteria(_ variable: PSSubjectVariable,value: String) {
        addCriteria(variable.name, value: value)
    }
    
    open func addCriteria(_ name : String, value: String) {
        
        var criteriaEntry : Entry
        if let existingCriteriaEntry = scriptData.getSubEntry("Criteria", entry: entry) {
            criteriaEntry = existingCriteriaEntry
        } else {
            criteriaEntry = scriptData.getOrCreateSubEntry("Criteria", entry: entry, isProperty: true)
            let conditionEntry = scriptData.getOrCreateSubEntry("Condition", entry: criteriaEntry, isProperty: true)
            conditionEntry.currentValue = entry.name
            let conditionAtEntry = scriptData.getOrCreateSubEntry("\"@\"", entry: conditionEntry, isProperty: true)
            conditionAtEntry.currentValue = "Condition"
        }
        

        let newSubEntry = scriptData.getOrCreateSubEntry(name, entry: criteriaEntry, isProperty: true)
        newSubEntry.currentValue = value
        let atSubEntry = scriptData.getOrCreateSubEntry("\"@\"", entry: newSubEntry, isProperty: true)
        atSubEntry.currentValue = name
    }
    
    open func removeCriteria(_ name : String) {
        if let criteriaEntry = scriptData.getSubEntry("Criteria", entry: entry) {
            scriptData.deleteNamedSubEntryFromParentEntry(criteriaEntry, name: name)
        }
        
        
    }
    
    open func valueForCriteria(_ name : String) -> String{

        if let criteriaEntry = scriptData.getSubEntry("Criteria", entry: entry),
         let valueEntry = scriptData.getSubEntry(name, entry: criteriaEntry) {
            return valueEntry.currentValue
        }
        return ""
    }
}
