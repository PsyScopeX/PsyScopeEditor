//
//  PSVariableTypeEntry.swift
//  PsyScopeEditor
//
//  Created by James on 20/04/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

public class PSVariableTypes {
    init(types : [PSVariableNamedType]) {
        self.types = types
    }
    var types : [PSVariableNamedType]
}

func TypeEntryToFullVariableType(_ typeEntry : Entry, scriptData : PSScriptData) -> PSVariableType? {
    switch(typeEntry.currentValue.lowercased()) {
    case "array":
        
        //set count if available
        var count = 1
        if let countSubEntry = scriptData.getSubEntry("Count",entry: typeEntry), let iVal = Int(countSubEntry.currentValue) {
            count = iVal
        }
        
        //set type if available
        var arrayType = PSVariableType() //default to this
        if let arrayTypeSubEntry = scriptData.getSubEntry("Type", entry: typeEntry),
            let givenType = TypeEntryToFullVariableType(arrayTypeSubEntry, scriptData: scriptData) {
                
            arrayType = givenType
        }
        
        return PSVariableType.Array(PSVariableArray(count: count, type: arrayType))
    case "record":
        //for a record all sub entries are fields
        let fieldEntries = typeEntry.subEntries.array as! [Entry]
        
        var fields : [PSVariableNamedType] = []
        for fieldEntry in fieldEntries {
            if let t = TypeEntryToFullVariableType(fieldEntry, scriptData: scriptData) {
                fields.append(PSVariableNamedType(name: fieldEntry.name, type: t))
            }
        }
        
        let record = PSVariableRecord(fields: fields)
        
        return PSVariableType.Record(record)
    case "integer":
        return PSVariableType.IntegerType()
    case "long_integer":
        return PSVariableType.LongIntegerType()
    case "float":
        return PSVariableType.FloatType()
    case "double":
        return PSVariableType.DoubleType()
    case "string":
        return PSVariableType.StringType()
    case "point":
        return PSPointVariableType()
    case "response":
        return PSResponseVariableType()
    case "input":
        return PSInputVariableType()
    case "": //lets assume empty means string
        return PSVariableType.StringType()
    default:
        //search for custom variable type
        if let customType = scriptData.getBaseEntry(typeEntry.currentValue) {
            return TypeEntryToFullVariableType(customType, scriptData: scriptData)
        }
    }
    return nil
}

func GetVariableTypeNames(_ scriptData : PSScriptData) -> [String] {
    return GetVariableTypeNames(GetCustomVariableTypes(scriptData))
}

func GetVariableTypeNames(_ customVariableTypes : PSVariableTypes) -> [String] {
    var typeStrings = ["Integer","Long_Integer", "Float", "Double", "Array", "Record", "String", "Point", "Record", "Input"]
    typeStrings += customVariableTypes.types.map({ $0.name })

    return typeStrings
}

func GetCustomVariableTypes(_ scriptData : PSScriptData) -> PSVariableTypes {
    let expEntry = scriptData.getMainExperimentEntry()
    if let expVariables = scriptData.getSubEntry("ExpTypes", entry: expEntry) {
        
            let list = PSStringList(entry: expVariables, scriptData: scriptData)
        
            let entries = list.stringListLiteralsOnly.map {
                (name : String) -> Entry? in
                return scriptData.getBaseEntry(name)
            }

            return PSVariableTypes(types: entries.filter({$0 != nil}).map { EntryToVariableNamedType($0!, scriptData: scriptData) } )
    }
    
    return PSVariableTypes(types: [])
}


//entry should be created and pre-named!
func VariableNamedTypeToEntry(_ namedType : PSVariableNamedType, entry : Entry, scriptData : PSScriptData) {
    //delete all existing sub entries and start again (could try to keep exisitng structure in future)
    let subEntries = entry.subEntries.array as! [Entry]
    subEntries.forEach( { scriptData.deleteSubEntryFromBaseEntry(entry, subEntry: $0) } )
    VariableTypeToEntry(namedType.type, entry: entry, scriptData: scriptData)
}

func VariableTypeToEntry(_ type : PSVariableType, entry : Entry, scriptData : PSScriptData) {
    //name of entry is already set when here
    
    switch (type.type) {
    case .integerType:
        entry.currentValue = "Integer"
    case .longIntegerType:
        entry.currentValue = "Long_Integer"
    case .floatType:
        entry.currentValue = "Float"
    case .doubleType:
        entry.currentValue = "Double"
    case .stringType:
        entry.currentValue = "String"
    case let .defined(definedName):
        entry.currentValue = definedName
    case let .array(variableArray):
        entry.currentValue = "Array"
        let countEntry = scriptData.getOrCreateSubEntry("Count", entry: entry, isProperty: true)
        countEntry.currentValue = variableArray.count.description
        let typeEntry = scriptData.getOrCreateSubEntry("Type", entry: entry, isProperty: true)
        VariableTypeToEntry(variableArray.type, entry: typeEntry, scriptData: scriptData)
    case let .record(variableRecord):
        entry.currentValue = "Record"
        for field in variableRecord.fields {
            if scriptData.getSubEntryNames(entry).contains(field.name) {
                field.name = scriptData.getNextFreeSubEntryName(field.name, parentEntry: entry)
            }
            
            let fieldEntry = scriptData.getOrCreateSubEntry(field.name, entry: entry, isProperty: true)
            VariableNamedTypeToEntry(field, entry: fieldEntry,scriptData: scriptData)
        }
    }
}


func EntryToVariableNamedType(_ entry : Entry, scriptData : PSScriptData) -> PSVariableNamedType {
    let name = entry.name
    let type = EntryToVariableType(entry, scriptData: scriptData)
    return PSVariableNamedType(name: name!, type: type)
}

func EntryToVariableType(_ entry : Entry, scriptData : PSScriptData) -> PSVariableType {
    switch(entry.currentValue.lowercased()) {
    case "array":
        
        //set count if available
        var count = 1
        if let countSubEntry = scriptData.getSubEntry("Count",entry: entry), let iVal = Int(countSubEntry.currentValue) {
            count = iVal
        }
        
        //set type if available
        var arrayType = PSVariableType() //default to this
        if let arrayTypeSubEntry = scriptData.getSubEntry("Type", entry: entry) {
            arrayType = EntryToVariableType(arrayTypeSubEntry, scriptData: scriptData)
        }
        
        return PSVariableType.Array(PSVariableArray(count: count, type: arrayType))
    case "record":
        //for a record all sub entries are fields
        let fields = entry.subEntries.array as! [Entry]
        
        let record = PSVariableRecord(fields: fields.map({
            (entry : Entry) -> PSVariableNamedType in
            return EntryToVariableNamedType(entry, scriptData: scriptData)
        }))
        
        return PSVariableType.Record(record)
    case "integer":
        return PSVariableType.IntegerType()
    case "long_integer":
        return PSVariableType.LongIntegerType()
    case "float":
        return PSVariableType.FloatType()
    case "double":
        return PSVariableType.DoubleType()
    case "string":
        return PSVariableType.StringType()
    case "": //lets assume empty means string
        return PSVariableType.StringType()
    default:
        return PSVariableType.Defined(entry.currentValue)
    }
}

public func PSPointVariableType() -> PSVariableType {
    return PSVariableType.Record(PSVariableRecord(fields:
            [PSVariableNamedType(name: "X", type: PSVariableType.IntegerType()), PSVariableNamedType(name: "Y", type: PSVariableType.IntegerType())
            ]))
}

public func PSInputVariableType() -> PSVariableType {
    return PSVariableType.Record(PSVariableRecord(fields:[
        PSVariableNamedType(name: "InputType", type: PSVariableType.IntegerType()),
        PSVariableNamedType(name: "Time", type: PSVariableType.LongIntegerType()),
        PSVariableNamedType(name: "state", type: PSVariableType.IntegerType()),
        PSVariableNamedType(name: "key", type: PSVariableType.IntegerType()),
        PSVariableNamedType(name: "keymap", type: PSVariableType.Array(
            PSVariableArray(count: 4, type: PSVariableType.LongIntegerType()))),
        PSVariableNamedType(name: "where", type: PSPointVariableType()),
        PSVariableNamedType(name: "button", type: PSVariableType.IntegerType())]))
}

public func PSResponseVariableType() -> PSVariableType {
    return PSVariableType.Record(PSVariableRecord(fields:[
        PSVariableNamedType(name: "PutUpByEvent", type: PSVariableType.IntegerType()),
        PSVariableNamedType(name: "DuringEvent", type: PSVariableType.IntegerType()),
        PSVariableNamedType(name: "RemovedByEvent", type: PSVariableType.IntegerType()),
        PSVariableNamedType(name: "RelativeEvent", type: PSVariableType.IntegerType()),
        PSVariableNamedType(name: "Label", type: PSVariableType.IntegerType()),
        PSVariableNamedType(name: "Input", type: PSInputVariableType())]))
}

class PSVariableTypeEntry : NSObject {
    init(entry : Entry, scriptData : PSScriptData) {
        self.entry = entry
        self.scriptData = scriptData
        self.type = EntryToVariableNamedType(entry, scriptData: scriptData)
    }
    
    let scriptData : PSScriptData
    let entry : Entry
    
    var type : PSVariableNamedType
}
