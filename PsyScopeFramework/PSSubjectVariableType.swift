//
//  PSSubjectVariableType.swift
//  PsyScopeEditor
//
//  Created by James on 12/05/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation
import Cocoa

public enum PSSubjectVariableType {
    case stringType,integer,rational,number
    case checkBoxes([String])
    case radioButtons([String])
    
    
    func saveToScript(_ entry : Entry, scriptData : PSScriptData) {
        let dialogSubEntry = scriptData.getOrCreateSubEntry("Dialog", entry: entry, isProperty: true)
        
        removeCheckBoxOrRadioButtonsEntries(entry, scriptData: scriptData)
        var valueString : String
        var typeString : String
        
        switch(self) {
        case .stringType:
            valueString = "Standard"
            typeString = ""
        case .integer:
            valueString = "Standard"
            typeString = "Int"
        case .rational:
            valueString = "Standard"
            typeString = "Rational"
        case .number:
            valueString = "Standard"
            typeString = "Number"
        case let .checkBoxes(values):
            valueString = "CheckBoxes"
            typeString = ""
            addCheckBoxes(values, entry: entry, scriptData: scriptData)
        case let .radioButtons(values):
            valueString = "Buttons"
            typeString = ""
            addRadioButtons(values, entry: entry, scriptData: scriptData)
        }
        
        if typeString != "" {
            let typeSubEntry = scriptData.getOrCreateSubEntry("Type", entry: entry, isProperty: true)
            typeSubEntry.currentValue = typeString
        } else {
            scriptData.deleteNamedSubEntryFromParentEntry(entry, name: "Type")
        }
        
        dialogSubEntry.currentValue = valueString
    }
    
    fileprivate func removeCheckBoxOrRadioButtonsEntries(_ entry : Entry, scriptData : PSScriptData) {
        scriptData.deleteNamedSubEntryFromParentEntry(entry, name: "Msg")
        scriptData.deleteNamedSubEntryFromParentEntry(entry, name: "Buttons")
        scriptData.deleteNamedSubEntryFromParentEntry(entry, name: "Default")
        scriptData.deleteNamedSubEntryFromParentEntry(entry, name: "CheckBoxes")
    }
    
    fileprivate func addCheckBoxes(_ checkBoxes : [String], entry : Entry, scriptData : PSScriptData) {
        _ = scriptData.getOrCreateSubEntry("Msg", entry: entry, isProperty: true)
        let checkBoxList = PSStringList(entry: scriptData.getOrCreateSubEntry("CheckBoxes", entry: entry, isProperty: true), scriptData: scriptData)
        let defaultEntry = PSStringList(entry: scriptData.getOrCreateSubEntry("Default", entry: entry, isProperty: true), scriptData: scriptData)
        
        checkBoxList.stringValue = ""
        defaultEntry.stringValue = ""
        
        for cb in checkBoxes {
            checkBoxList.appendAsString(cb)
        }
        
        if let firstCheckBox = checkBoxes.first {
            defaultEntry.appendAsString(firstCheckBox)
        }
    }
    
    fileprivate func addRadioButtons(_ radioButtons : [String], entry : Entry, scriptData : PSScriptData) {
        _ = scriptData.getOrCreateSubEntry("Msg", entry: entry, isProperty: true)
        let buttonsList = PSStringList(entry: scriptData.getOrCreateSubEntry("Buttons", entry: entry, isProperty: true), scriptData: scriptData)
        let defaultEntry = PSStringList(entry: scriptData.getOrCreateSubEntry("Default", entry: entry, isProperty: true), scriptData: scriptData)
        
        buttonsList.stringValue = ""
        defaultEntry.stringValue = ""
        
        for cb in radioButtons {
            buttonsList.appendAsString(cb)
        }
    }
    
    static func fromEntry(_ entry : Entry, scriptData : PSScriptData) -> PSSubjectVariableType {
        var dialogType = PSSubjectVariableType.stringType
        if let dialogSubEntry = scriptData.getSubEntry("Dialog", entry: entry) {
            switch dialogSubEntry.currentValue.lowercased() {
            case "value":
                if let typeSubEntry = scriptData.getSubEntry("Type",entry: entry) {
                    switch (typeSubEntry.currentValue.lowercased()) {
                    case "int":
                        dialogType = .integer
                    case "rational":
                        dialogType = .rational
                    case "number":
                        dialogType = .number
                    default:
                        dialogType = .integer
                    }
                } else {
                    dialogType = .integer
                }
            case "buttons":
                if let buttonsEntry = scriptData.getSubEntry("Buttons", entry: entry) {
                    let buttonsList = PSStringList(entry: buttonsEntry, scriptData: scriptData)
                    dialogType = .radioButtons(buttonsList.stringListRawStripped)
                } else {
                    dialogType = .radioButtons([])
                }
                
            case "checkboxes":
                if let checkBoxesEntry = scriptData.getSubEntry("CheckBoxes", entry: entry) {
                    let checkBoxesList = PSStringList(entry: checkBoxesEntry, scriptData: scriptData)
                    dialogType = .checkBoxes(checkBoxesList.stringListRawStripped)
                } else {
                    dialogType = .checkBoxes([])
                }
            default:
                break
            }
        }
        return dialogType
    }
}
