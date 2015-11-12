//
//  PSAttribute.swift
//  PsyScopeEditor
//
//  Created by James on 07/02/2015.
//

import Foundation

public class PSAttributeGeneric : NSObject, PSAttributeInterface {
    public var userFriendlyNameString : String
    public var helpfulDescriptionString : String
    public var codeNameString : String
    public var attributeClass : NSObject.Type
    public var classNameString : String
    public var defaultValueString : String
    public var toolsArray : [String]
    public var keyValuesArray : [String]
    public var customAttributeParameterAction : ((String,PSScriptData,NSWindow,((String) -> ())?) -> ())?
    public var displayValueTransformer : (String -> String)?
    public var section : PSSection
    public var reservedEntryNames : [String]
    public var illegalEntryNames : [String]
    override public init() {
        userFriendlyNameString = ""
        helpfulDescriptionString = ""
        codeNameString = ""
        attributeClass = PSAttributeParameter_String.self
        classNameString = NSStringFromClass(self.dynamicType)
        defaultValueString = ""
        toolsArray = []
        keyValuesArray = []
        section = PSSections.UndefinedEntries
        reservedEntryNames = []
        illegalEntryNames = []
        super.init()
    }
    
    public func userFriendlyName() -> String! {
        return userFriendlyNameString
    }
    
    public func helpfulDescription() -> String! {
        return helpfulDescriptionString
    }
    
    public func codeName() -> String! {
        return codeNameString
    }
    
    public func psclassName() -> String! {
        return classNameString
    }
    
    public func keyValues() -> [AnyObject]! {
        return keyValuesArray
    }
    
    public func tools() -> [AnyObject]! {
        return toolsArray
    }
    
    public func defaultValue() -> String! {
        return defaultValueString
    }
    
    public func attributeParameter() -> AnyObject! {
        let newAP = attributeClass.init() as! PSAttributeParameter
        if let customAP = newAP as? PSAttributeParameter_Custom {
            customAP.customButtonAction = customAttributeParameterAction!
            customAP.displayValueTransformer = displayValueTransformer
            return customAP
        } else {
            return newAP
        }
        
    }
    
    public func identifyEntries(ghostScript: PSGhostScript!) -> [AnyObject]! {
        //find all sub entries named codeNameString, in entries of valid type
        for ge in ghostScript.entries as [PSGhostEntry] {
            for type in toolsArray {
                if type == ge.type {
                    for ga in ge.subEntries {
                        if ga.name == codeNameString {
                            ga.type = PSAttributeType(name: codeNameString, type: type).fullType
                            break
                        }
                    }
                }
                break
            }
        }
        return []
    }
    
    public func createBaseEntriesWithGhostEntries(entries: [AnyObject]!, withScript scriptData: PSScriptData!) -> [AnyObject]! {
        for ent in entries {
            if let e = ent as? PSGhostEntry {
                let new_blank_obj = scriptData.getOrCreateBaseEntry(e.name, type: e.type, section: section)
                updateEntry(new_blank_obj, withGhostEntry: e, scriptData: scriptData)
            }
        }
        //normally attributes wont create any layoutobjects
        return []
    }
    
    public func updateEntry(realEntry: Entry!, withGhostEntry ghostEntry: PSGhostEntry!, scriptData: PSScriptData!) {
        PSUpdateEntryWithGhostEntry(realEntry, ghostEntry: ghostEntry, scriptData: scriptData)
    }
    
    public func getReservedEntryNames() -> [AnyObject]! {
        return reservedEntryNames
    }
    public func getIllegalEntryNames() -> [AnyObject]! {
        return illegalEntryNames
    }
}