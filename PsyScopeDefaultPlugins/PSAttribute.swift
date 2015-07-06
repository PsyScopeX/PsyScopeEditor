//
//  PSAttribute.swift
//  PsyScopeEditor
//
//  Created by James on 07/02/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAttributeAbstract : NSObject, PSAttributeInterface {
    var userFriendlyNameString : String
    var helpfulDescriptionString : String
    var codeNameString : String
    var attributeClass : NSObject.Type
    var classNameString : String
    var defaultValueString : String
    var toolsArray : [String]
    var keyValuesArray : [String]
    override init() {
        userFriendlyNameString = ""
        helpfulDescriptionString = ""
        codeNameString = ""
        attributeClass = PSAttributeParameter.self
        classNameString = ""
        defaultValueString = ""
        toolsArray = []
        keyValuesArray = []
        super.init()
    }
    
    func userFriendlyName() -> String! {
        return userFriendlyNameString
    }
    
    func helpfulDescription() -> String! {
        return helpfulDescriptionString
    }
    
    func codeName() -> String! {
        return codeNameString
    }
    
    /* func customAttributeDialog(currentValue: String!, withScriptData scriptData: PSScriptData!) -> PSAttributePopup! {
    fatalError("Tried to open a custom attribute view for PSExperimentAttribute: \(className())")
    return nil
    }*/
    
    func className() -> String! {
        return classNameString
    }
    
    func keyValues() -> [AnyObject]! {
        return keyValuesArray
    }
    
    func tools() -> [AnyObject]! {
        return toolsArray
    }
    
    func defaultValue() -> String! {
        return defaultValueString
    }
    
    
    func createCellView(entry: Entry!, scriptData: PSScriptData!) -> PSAttributeCellAbstractClass! {
        var cell = PSAttributeCell(frame: NSRect(x: 0, y: 0, width: 200, height: 30))
        cell.setup(entry, scriptData: scriptData)
        cell.autoresizesSubviews = true
        var attributeInstance = attributeClass()
        if let att = attributeInstance as? PSAttributeParameter {
            att.setupCell(userFriendlyNameString, cell: cell, y: 15, currentValue: entry.currentValue, scriptData: scriptData)
        }
        return cell
    }
    
}