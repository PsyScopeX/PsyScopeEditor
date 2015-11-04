//
//  PSVariableValues.swift
//  PsyScopeEditor
//
//  Created by James on 23/04/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSVariableValues : NSObject {
    
    init(label : String, type : ValuesType) {
        self.label = label
        self.currentValue = "NULL"
        self.subValues = []
        self.type = type
        super.init()
    }
    
    let type : ValuesType
    let label : String
    var currentValue : String
    var subValues : [PSVariableValues]

    enum ValuesType {
        case Record
        case Array
        case SingleValue
    }
}

//MARK: Entry -> Values


func UpdateVariableValuesWithInlineEntryCurrentValues(stringValue : String, values : PSVariableValues) {
    switch(values.type) {
    case .Record:
        
        let stringList = PSStringListCachedContainer()
        stringList.stringValue = stringValue

        if let inlineEntryFunction = stringList.values.first {
            switch(inlineEntryFunction) {
            case let .Function(functionElement):
                if functionElement.bracketType == .Square {
                    for inlineElement in functionElement.values {
                        switch(inlineElement) {
                        case let .Function(inlineEntryFunctionElement):
                            if inlineEntryFunctionElement.bracketType == .InlineEntry {
                                
                                for field in values.subValues {
                                    if inlineEntryFunctionElement.functionName == field.label {
                                        //we have a match!
                                        //output values to string
                                        let parameters = inlineEntryFunctionElement.getParametersStringValue()
                                        UpdateVariableValuesWithInlineEntryCurrentValues(parameters, values: field)
                                    }
                                }
                                
                                
                            }
                        default:
                            break
                        }
                    }
                }
                
            default:
                //ignore
                break
            }
        }
   
        values.currentValue = "Not implemented"
    case .Array:
        let stringList = PSStringListCachedContainer()
        stringList.stringValue = stringValue
    
        var stringValues = stringList.stringListRawUnstripped
        
        let arraySizeDifference = values.subValues.count - stringValues.count
        
        if arraySizeDifference > 0 {
            for _ in 1...arraySizeDifference {
                stringValues.append("NULL")
            }
        }
        
        for (index,subValue) in values.subValues.enumerate() {
            UpdateVariableValuesWithInlineEntryCurrentValues(stringValues[index], values: subValue)
        }
    case .SingleValue:
        let stringList = PSStringListCachedContainer()
        stringList.stringValue = stringValue
        
        if let strippedValue = stringList.stringListRawStripped.first {
            values.currentValue = strippedValue
        } else {
            values.currentValue = "NULL"
        }
    }
}

func UpdateVariableValuesWithEntryCurrentValues(baseEntry : Entry, values : PSVariableValues, scriptData : PSScriptData) {
    switch(values.type) {
    case .Record:
        for subValue in values.subValues {
            if let subEntry = scriptData.getSubEntry(subValue.label, entry: baseEntry) {
                UpdateVariableValuesWithEntryCurrentValues(subEntry, values: subValue, scriptData: scriptData)
            }
        }
    case .Array:
        let stringList = PSStringListCachedContainer()
        stringList.stringValue = baseEntry.currentValue
        
        var stringValues = stringList.stringListRawUnstripped
        
        let arraySizeDifference = values.subValues.count - stringValues.count
        
        if arraySizeDifference > 0 {
            for _ in 1...arraySizeDifference {
                stringValues.append("NULL")
            }
        }
        
        for (index,subValue) in values.subValues.enumerate() {
            UpdateVariableValuesWithInlineEntryCurrentValues(stringValues[index], values: subValue)
        }
    case .SingleValue:
        
        let stringList = PSStringListCachedContainer()
        stringList.stringValue = baseEntry.currentValue
        
        if let strippedValue = stringList.stringListRawStripped.first {
            values.currentValue = strippedValue
        } else {
            values.currentValue = "NULL"
        }
    }
}

//MARK: Values -> Entry

func UpdateInlineEntryCurrentValuesWithVariableValues(values : PSVariableValues) -> String {
    switch(values.type) {
    case .Record:
        var inlineEntry : String = "["
        for subValue in values.subValues {
            inlineEntry += subValue.label + ": "
            inlineEntry += UpdateInlineEntryCurrentValuesWithVariableValues(subValue) + " "
        }
        inlineEntry += "]"
        return inlineEntry
    case .Array:
        return values.subValues.map { UpdateInlineEntryCurrentValuesWithVariableValues($0) }.joinWithSeparator(" ")
    case .SingleValue:
        if let stringElement = PSStringElement(strippedValue: values.currentValue) {
            return stringElement.quotedValue
        } else {
            //syntax error so....
            return ""
        }
    }
}


func UpdateEntryCurrentValuesWithVariableValues(baseEntry : Entry, values : PSVariableValues, scriptData : PSScriptData) {
    switch(values.type) {
    case .Record:
        var subEntryNamesToKeep : [String] = ["Type"]
        for subValue in values.subValues {
            subEntryNamesToKeep.append(subValue.label)
            let subEntry = scriptData.getOrCreateSubEntry(subValue.label, entry: baseEntry, isProperty: true)
            UpdateEntryCurrentValuesWithVariableValues(subEntry, values: subValue, scriptData: scriptData)
        }
        
        for entry in baseEntry.subEntries.array as! [Entry] {
            if !subEntryNamesToKeep.contains(entry.name) {
                scriptData.deleteSubEntryFromBaseEntry(baseEntry, subEntry: entry)
            }
        }
        
        baseEntry.currentValue = ""
    case .Array:
        let stringList = values.subValues.map { UpdateInlineEntryCurrentValuesWithVariableValues($0) }.joinWithSeparator(" ")
        baseEntry.currentValue = stringList
    case .SingleValue:
        baseEntry.currentValue = values.currentValue
    }
}

//MARK: Type -> Values

func PSVariableValuesFromVariableType(name : String, variableType : PSVariableType) -> PSVariableValues {
    switch (variableType.type) {
    case let .Array(variableArray):
        let values = PSVariableValues(label: name, type: .Array)
        for index in 1...variableArray.count {
            let arrayValueName = "[\(index)]"
            let arrayValueType = variableArray.type
            values.subValues.append(PSVariableValuesFromVariableType(arrayValueName, variableType: arrayValueType))
        }
        return values
    case let .Record(variableRecord):
        let values = PSVariableValues(label: name, type: .Record)
        for field in variableRecord.fields {
            let fieldName = field.name
            let fieldType = field.type
            values.subValues.append(PSVariableValuesFromVariableType(fieldName, variableType: fieldType))
        }
        return values
    default:
        return PSVariableValues(label: name, type: .SingleValue)
    }
}