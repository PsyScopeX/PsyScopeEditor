//
//  PSAttribute.swift
//  PsyScopeEditor
//
//  Created by James on 07/02/2015.
//

import Foundation

open class PSAttributeGeneric : NSObject, PSAttributeInterface {


    open var userFriendlyNameString : String
    open var helpfulDescriptionString : String
    open var codeNameString : String
    open var attributeClass : NSObject.Type
    open var classNameString : String
    open var defaultValueString : String
    open var toolsArray : [String]
    open var keyValuesArray : [String]
    open var customAttributeParameterAction : ((PSEntryElement,PSScriptData,NSWindow,((PSEntryElement) -> ())?) -> ())?
    open var displayValueTransformer : ((PSEntryElement) -> String)?
    open var section : PSSection
    open var reservedEntryNames : [String]
    open var illegalEntryNames : [String]
    override public init() {
        userFriendlyNameString = ""
        helpfulDescriptionString = ""
        codeNameString = ""
        attributeClass = PSAttributeParameter_String.self
        classNameString = NSStringFromClass(type(of: self))
        defaultValueString = ""
        toolsArray = []
        keyValuesArray = []
        section = PSSection.UndefinedEntries
        reservedEntryNames = []
        illegalEntryNames = []
        super.init()
    }
    
    open func userFriendlyName() -> String! {
        return userFriendlyNameString
    }
    
    open func helpfulDescription() -> String! {
        return helpfulDescriptionString
    }
    
    open func codeName() -> String! {
        return codeNameString
    }
    
    open func psclassName() -> String! {
        return classNameString
    }
    
    open func keyValues() -> [Any]! {
        return keyValuesArray
    }
    
    open func tools() -> [Any]! {
        return toolsArray
    }
    
    open func defaultValue() -> String! {
        return defaultValueString
    }
    
    open func attributeParameter() -> Any! {
        let newAP = attributeClass.init() as! PSAttributeParameter
        if let customAP = newAP as? PSAttributeParameter_Custom {
            customAP.customButtonAction = customAttributeParameterAction!
            customAP.displayValueTransformer = displayValueTransformer
            return customAP
        } else {
            return newAP
        }
        
    }
    
    open func identifyEntries(_ ghostScript: PSGhostScript!) -> [Any]! {
        //find all sub entries named codeNameString, in entries of valid type
        for ge in ghostScript.entries as [PSGhostEntry] {
            for type in toolsArray {
                if type == ge.type {
                    for ga in ge.subEntries {
                        if ga.name == codeNameString {
                            ga.type = PSAttributeType(name: codeNameString, parentType: PSType.FromName(type)).fullType
                            break
                        }
                    }
                }
                break
            }
        }
        return []
    }
    
    open func createBaseEntries(withGhostEntries entries: [Any]!, withScript scriptData: PSScriptData!) -> [Any]! {
        for ent in entries {
            if let e = ent as? PSGhostEntry {
                let new_blank_obj = scriptData.getOrCreateBaseEntry(e.name, type: PSType.FromName(e.type), section: section)
                update(new_blank_obj, with: e, scriptData: scriptData)
            }
        }
        //normally attributes wont create any layoutobjects
        return []
    }
    
    open func update(_ realEntry: Entry!, with ghostEntry: PSGhostEntry!, scriptData: PSScriptData!) {
        PSUpdateEntryWithGhostEntry(realEntry, ghostEntry: ghostEntry, scriptData: scriptData)
    }
    
    open func getReservedEntryNames() -> [Any]! {
        return reservedEntryNames
    }
    open func getIllegalEntryNames() -> [Any]! {
        return illegalEntryNames
    }
}
