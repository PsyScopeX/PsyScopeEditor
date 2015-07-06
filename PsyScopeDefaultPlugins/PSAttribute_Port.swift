//
//  PSAttribute_Port.swift
//  PsyScopeEditor
//
//  Created by James on 24/09/2014.
//

import Cocoa

public class PSAttribute_Port: PSAttributeGeneric {
    
    
    public override init() {
        super.init()
        userFriendlyNameString = "Port"
        helpfulDescriptionString = "Describes a shape to contain and position stimuli such as as text or pictures"
        codeNameString = "Port"
        toolsArray = [PSTextEvent().type(), PSPictureEvent().type(), PSKeySequenceEvent().type(), PSMovieEvent().type(), PSDocumentEvent().type(), PSParagraphEvent().type()]
        defaultValueString = PSDefaultConstants.DefaultAttributeValues.PSAttribute_Port
        
        attributeClass = PSAttributeParameter_Custom.self
        customAttributeParameterAction = { (before : String, scriptData: PSScriptData, window: NSWindow, setCurrentValueBlock : ((String) -> ())?) -> () in
            let popup = PSPortBuilderController(currentValue: before, scriptData: scriptData, positionMode: false, setCurrentValueBlock: setCurrentValueBlock)
            popup.showAttributeModalForWindow(window)
        }
        
        displayValueTransformer = { (before : String) in
            let functionElement = PSFunctionElement()
            functionElement.stringValue = before
            if functionElement.functionName == "PortName" && !functionElement.foundErrors {
                return " ".join(functionElement.getStrippedStringValues())
            } else {
                return before
            }
        }
        
        sectionName = "PortDefinitions"
        sectionZ = 14
    }
    
    public override func identifyEntries(ghostScript: PSGhostScript!) -> [AnyObject]! {
        
        //remember pasteboard port attribute inherits this so, make sure it is compatible by using codeNameString
        //next find portNames entry, plus identify all entries associated with that
        var errors : [PSScriptError] = []
        errors += super.identifyEntries(ghostScript) as! [PSScriptError]
        var portNamesEntry : PSStringListCachedContainer!
        var portNamesGE : PSGhostEntry!
        for ge in ghostScript.entries as [PSGhostEntry] {
            if ge.name == "PortNames" {
                portNamesEntry = PSStringListCachedContainer()
                portNamesEntry.stringValue = ge.currentValue
                portNamesGE = ge
                if (ge.type.isEmpty || ge.type == "Port") {
                    ge.type = "Port"
                } else {
                    errors.append(PSErrorPortNamesEntryTypeMismatch(ge.type, range: ge.range))
                }
                break
            }
        }
        
        if let ports = portNamesEntry {
            for portName in ports.stringListLiteralsOnly {
                
                var found_port = false
                for ge in ghostScript.entries as [PSGhostEntry] {
                    if ge.name == portName {
                        if (ge.type.isEmpty || ge.type == "Port") {
                            
                            ge.type = "Port"
                            found_port = true
                            
                            //now identify positions
                            errors += identifyPositions(ge, ghostScript: ghostScript)
                            break
                        } else {
                            errors.append(PSErrorPortEntryTypeMismatch(ge.name, incorrectType: ge.type, range: ge.range))
                        }
                    }
                }
                
                if (!found_port) {
                    errors.append(PSErrorMissingPortEntry(portName, range: portNamesGE.range))
                }
                
            }
        }
        
        return errors
    }
    
    
    func identifyPositions(portGhostEntry : PSGhostEntry, ghostScript: PSGhostScript) -> [PSScriptError] {
        //find portNames entry, plus identify all entries associated with that
        var errors : [PSScriptError] = []
        var positionNamesEntry : PSStringListCachedContainer!
        var positionNamesGE : PSGhostEntry!
        for ge in portGhostEntry.subEntries as [PSGhostEntry] {
            if ge.name == "Points" {
                positionNamesEntry = PSStringListCachedContainer()
                positionNamesEntry.stringValue = ge.currentValue
                positionNamesGE = ge
                break
            }
        }
        
        if let positions = positionNamesEntry {
            for positionName in positions.stringListLiteralsOnly {
                
                var found_position = false
                for ge in ghostScript.entries as! [PSGhostEntry] {
                    if ge.name == positionName {
                        if (ge.type.isEmpty || ge.type == "Port") {
                            
                            ge.type = "Port"
                            found_position = true
                            
                            break
                        } else {
                            errors.append(PSErrorPositionEntryTypeMismatch(ge.name, port: portGhostEntry.name, incorrectType: ge.type, range: ge.range))
                        }
                    }
                }
                
                if (!found_position) {
                    errors.append(PSErrorMissingPositionEntry(positionName, port: portGhostEntry.name, range: positionNamesGE.range))
                }
                
            }
        }
        
        return errors
    }
    
    func PSErrorMissingPositionEntry(name : String, port : String, range : NSRange) -> PSScriptError {
        let description = "No entry for the position named: \(name) could be found"
        let solution = "Check the entry is not misspelled, or remove the reference from the Port: \(port)"
        return PSScriptError(errorDescription: "Missing Position Entry", detailedDescription: description, solution: solution, range: range)
    }
    
    func PSErrorPositionEntryTypeMismatch(name : String, port : String, incorrectType : String, range : NSRange) -> PSScriptError {
        let description = "The entry named: \(name) was identified as a \(incorrectType), yet was listed as a port in Port: \(port)"
        let solution = "Check the entry is not referenced incorrectly elsewhere, or remove from PortNames"
        return PSScriptError(errorDescription: "Position Entry Mismatch", detailedDescription: description, solution: solution, range: range)
    }
    
    func PSErrorMissingPortEntry(name : String, range : NSRange) -> PSScriptError {
        let description = "No entry for the port named: \(name) could be found"
        let solution = "Check the entry is not misspelled, or remove the reference from PortNames"
        return PSScriptError(errorDescription: "Missing Port Entry", detailedDescription: description, solution: solution, range: range)
    }
    
    func PSErrorPortEntryTypeMismatch(name : String, incorrectType : String, range : NSRange) -> PSScriptError {
        let description = "The entry named: \(name) was identified as a \(incorrectType), yet was listed as a port in PortNames entry"
        let solution = "Check the entry is not referenced incorrectly elsewhere, or remove from PortNames"
        return PSScriptError(errorDescription: "Port Entry Mismatch", detailedDescription: description, solution: solution, range: range)
    }
    
    func PSErrorPortNamesEntryTypeMismatch(incorrectType : String, range : NSRange) -> PSScriptError {
        let description = "The reserved PortNames entry was misidentified as a \(incorrectType)"
        let solution = "Remove unecessary attributes and check the entry is not referenced incorrectly elsewhere"
        return PSScriptError(errorDescription: "PortNames Entry Mismatch", detailedDescription: description, solution: solution, range: range)
    }

}
