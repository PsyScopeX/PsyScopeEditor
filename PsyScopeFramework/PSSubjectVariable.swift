//
//  PSSubjectVariable.swift
//  PsyScopeEditor
//
//  Created by James on 11/05/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

public final class PSSubjectVariable : Equatable {
    
    public class func NewSubjectVariable(_ scriptData : PSScriptData) -> PSSubjectVariable {
        let newEntryName = scriptData.getNextFreeBaseEntryName("Item")
        let newEntry = scriptData.getOrCreateBaseEntry(newEntryName, type: PSType.SubjectInfo)
        let newSubjectVariable = PSSubjectVariable(entry: newEntry, scriptData: scriptData)
        newSubjectVariable.storageOptions = PSSubjectVariableStorageOptions(all: true)
        newSubjectVariable.dialogType = .stringType
        newSubjectVariable.isGroupingVariable = false
        newSubjectVariable.saveToScript()
        return newSubjectVariable
    }
    
    public class func NewGroupingVariable(_ scriptData : PSScriptData) -> PSSubjectVariable {
        let newGroupingVariable = NewSubjectVariable(scriptData)
        newGroupingVariable.isGroupingVariable = true
        return newGroupingVariable
    }

    public init(entry : Entry, scriptData : PSScriptData) {
        self.initialised = false
        self.entry = entry
        self.scriptData = scriptData
        self.dialogType = PSSubjectVariableType.fromEntry(entry, scriptData: scriptData)
        self.storageOptions = PSSubjectVariableStorageOptions.fromEntry(entry, scriptData: scriptData)
        self.isGroupingVariable = false
        
        //will call didSet now whence using initialised variable to prevent updating script
        self.isGroupingVariable = detectIfGroupingVariable()
        self.initialised = true
    }
    
    public let entry : Entry
    let scriptData : PSScriptData
    var initialised : Bool //to prevent updating script when setting up variable
    
    public var dialogType : PSSubjectVariableType {
        didSet {
            saveToScript()
        }
    }
    public var storageOptions : PSSubjectVariableStorageOptions {
        didSet {
            saveToScript()
        }
    }

    public var isGroupingVariable : Bool {
        didSet {
            saveToScript()
        }
    }
    
    public var name : String {
        get {
            return entry.name
        }
        
        set {
            scriptData.beginUndoGrouping("Rename variable")
            let success = scriptData.renameEntry(entry, nameSuggestion: newValue)
            scriptData.endUndoGrouping(success)
        }
    }
    
    public var currentValue : String {
        get {
            return entry.currentValue
        }
        set {
            scriptData.beginUndoGrouping("Change value")
            entry.currentValue = newValue
            scriptData.endUndoGrouping(true)
        }
    }
    
    
    fileprivate func detectIfGroupingVariable() -> Bool {
        //get group variable names
        if let subjectNumAndGroup = scriptData.getBaseEntry("SubjectNumAndGroup"),
            groupSpecs = scriptData.getSubEntry("GroupSpecs", entry: subjectNumAndGroup) {
                
                let groupsSpecsValue = PSStringList(entry: groupSpecs, scriptData: scriptData)
                
                for listValue in groupsSpecsValue.values {
                    switch(listValue) {
                    case let .stringToken(stringValue):
                        if stringValue.value == entry.name {
                            return true
                        }//found a reference to a group entry
                    default:
                        break
                    }
                }
        }
        return false
    }
    
    public func saveToScript() {
        //saves type (type sub entry)
        self.dialogType.saveToScript(entry, scriptData: scriptData)
        
        //save storage options (e.g. DataHeader and DataVariables)
        self.storageOptions.saveToScript(entry, scriptData: scriptData)
        
        //get the GroupSpecs attribute
        let subjectNumAndGroup = scriptData.getOrCreateBaseEntry("SubjectNumAndGroup", type: PSType.SubjectInfo)
        let groupSpecs = scriptData.getOrCreateSubEntry("GroupSpecs", entry: subjectNumAndGroup, isProperty: true)
        
        //Get the current variables which are grouping variables (those in group specs)
        let groupsSpecsValue = PSStringList(entry: groupSpecs, scriptData: scriptData)
        var groupVarNames : Set<String> = Set()
        for listValue in groupsSpecsValue.values {
            switch(listValue) {
            case let .stringToken(stringValue):
                groupVarNames.insert(stringValue.value) //found a reference to a group entry
            default:
                break
            }
        }
        
        //Update the Set (either add or remove)
        if isGroupingVariable {
            groupVarNames.insert(entry.name)
        } else {
            groupVarNames.remove(entry.name)
        }
        
        //Recreate the grouping variables value
        var newValues : [String] = []
        for groupVarName in groupVarNames {
            
            if let stringElement = PSStringElement(strippedValue: groupVarName) {
                newValues.append(stringElement.quotedValue)
                newValues.append("@\"\(groupVarName)\"")
            }
        }
        groupsSpecsValue.stringListRawUnstripped = newValues
    }
    
    public func removeFromScript() {
        self.isGroupingVariable = false
        self.storageOptions = PSSubjectVariableStorageOptions(all: false)
        self.saveToScript() //to remove all references in other entries
        
        //also need to delete from menus
        let menuStructure = PSMenuStructure(scriptData: scriptData)
        menuStructure.removeSubjectVariable(self)
        menuStructure.saveToScript()
        
        scriptData.deleteBaseEntry(entry)
    }
}

public func ==(lhs: PSSubjectVariable, rhs: PSSubjectVariable) -> Bool {
    return lhs.name == rhs.name
}
