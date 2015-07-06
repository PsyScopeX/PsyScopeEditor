//
//  PSGroup.swift
//  PsyScopeEditor
//
//  Created by James on 23/05/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

public class PSGroup {
    
    let entry : Entry
    let scriptData : PSScriptData
    
    public init(entry : Entry, scriptData : PSScriptData) {
        self.entry = entry
        self.scriptData = scriptData
    }
    
    public func getCriteria() -> [(variable: PSSubjectVariable,value: String)] {
        
        var existingCriteria : [(variable: PSSubjectVariable,value: String)] = []
        
        if let criteria = scriptData.getSubEntry("Criteria", entry: entry) {
            
            let subjectInformation = PSSubjectInformation(scriptData: scriptData)
            subjectInformation.updateVariablesFromScript()
            
            for subEntry in criteria.subEntries.array as! [Entry] {
                for subjectVariable in subjectInformation.subjectVariables {
                    if subEntry.name == subjectVariable.name {
                        //var newExistingCriteria =
                        existingCriteria.append(variable: subjectVariable, value: subEntry.currentValue as String)
                    }
                }
            }
            
        }
        return existingCriteria
    }
    
    public func setCriteria(criteria : [(variable: PSSubjectVariable,value: String)]) {
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
    
    public func addCriteria(variable: PSSubjectVariable,value: String) {
        addCriteria(variable.name, value: value)
    }
    
    public func addCriteria(name : String, value: String) {
        
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
    
    public func removeCriteria(name : String) {
        if let criteriaEntry = scriptData.getSubEntry("Criteria", entry: entry) {
            scriptData.deleteNamedSubEntryFromParentEntry(criteriaEntry, name: name)
        }
        
        
    }
    
    public func valueForCriteria(name : String) -> String{

        if let criteriaEntry = scriptData.getSubEntry("Criteria", entry: entry),
         valueEntry = scriptData.getSubEntry(name, entry: criteriaEntry) {
            return valueEntry.currentValue
        }
        return ""
    }
}