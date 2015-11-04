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
    case StringType,Integer,Rational,Number
    case CheckBoxes([String])
    case RadioButtons([String])
    
    
    func saveToScript(entry : Entry, scriptData : PSScriptData) {
        let dialogSubEntry = scriptData.getOrCreateSubEntry("Dialog", entry: entry, isProperty: true)
        
        removeCheckBoxOrRadioButtonsEntries(entry, scriptData: scriptData)
        var valueString : String
        var typeString : String
        
        switch(self) {
        case .StringType:
            valueString = "Standard"
            typeString = ""
        case .Integer:
            valueString = "Standard"
            typeString = "Int"
        case .Rational:
            valueString = "Standard"
            typeString = "Rational"
        case .Number:
            valueString = "Standard"
            typeString = "Number"
        case let .CheckBoxes(values):
            valueString = "CheckBoxes"
            typeString = ""
            addCheckBoxes(values, entry: entry, scriptData: scriptData)
        case let .RadioButtons(values):
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
    
    private func removeCheckBoxOrRadioButtonsEntries(entry : Entry, scriptData : PSScriptData) {
        scriptData.deleteNamedSubEntryFromParentEntry(entry, name: "Msg")
        scriptData.deleteNamedSubEntryFromParentEntry(entry, name: "Buttons")
        scriptData.deleteNamedSubEntryFromParentEntry(entry, name: "Default")
        scriptData.deleteNamedSubEntryFromParentEntry(entry, name: "CheckBoxes")
    }
    
    private func addCheckBoxes(checkBoxes : [String], entry : Entry, scriptData : PSScriptData) {
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
    
    private func addRadioButtons(radioButtons : [String], entry : Entry, scriptData : PSScriptData) {
        _ = scriptData.getOrCreateSubEntry("Msg", entry: entry, isProperty: true)
        let buttonsList = PSStringList(entry: scriptData.getOrCreateSubEntry("Buttons", entry: entry, isProperty: true), scriptData: scriptData)
        let defaultEntry = PSStringList(entry: scriptData.getOrCreateSubEntry("Default", entry: entry, isProperty: true), scriptData: scriptData)
        
        buttonsList.stringValue = ""
        defaultEntry.stringValue = ""
        
        for cb in radioButtons {
            buttonsList.appendAsString(cb)
        }
    }
    
    static func fromEntry(entry : Entry, scriptData : PSScriptData) -> PSSubjectVariableType {
        var dialogType = PSSubjectVariableType.StringType
        if let dialogSubEntry = scriptData.getSubEntry("Dialog", entry: entry) {
            switch dialogSubEntry.currentValue.lowercaseString {
            case "value":
                if let typeSubEntry = scriptData.getSubEntry("Type",entry: entry) {
                    switch (typeSubEntry.currentValue.lowercaseString) {
                    case "int":
                        dialogType = .Integer
                    case "rational":
                        dialogType = .Rational
                    case "number":
                        dialogType = .Number
                    default:
                        dialogType = .Integer
                    }
                } else {
                    dialogType = .Integer
                }
            case "buttons":
                if let buttonsEntry = scriptData.getSubEntry("Buttons", entry: entry) {
                    let buttonsList = PSStringList(entry: buttonsEntry, scriptData: scriptData)
                    dialogType = .RadioButtons(buttonsList.stringListRawStripped)
                } else {
                    dialogType = .RadioButtons([])
                }
                
            case "checkboxes":
                if let checkBoxesEntry = scriptData.getSubEntry("CheckBoxes", entry: entry) {
                    let checkBoxesList = PSStringList(entry: checkBoxesEntry, scriptData: scriptData)
                    dialogType = .CheckBoxes(checkBoxesList.stringListRawStripped)
                } else {
                    dialogType = .CheckBoxes([])
                }
            default:
                break
            }
        }
        return dialogType
    }
}