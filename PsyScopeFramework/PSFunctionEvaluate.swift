//
//  PSFunctionEvaluate.swift
//  PsyScopeEditor
//
//  Created by James on 18/12/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation
//Tries to get a value - much work to do....
public func PSFunctionEvaluate(entryElement : PSEntryElement, scriptData : PSScriptData) -> String {
    switch (entryElement) {
    case .Null:
        break
    case .List(let stringListElement):
        if let first = stringListElement.values.first {
            return PSFunctionEvaluate(first, scriptData: scriptData)
        }
    case .Function(let functionElement):
        if functionElement.bracketType == .Expression {
            switch functionElement.values.count {
            case 2:
                //unary
                if functionElement.values[0].stringValue() == "@" {
                    if let referencedEntry = scriptData.getBaseEntry(functionElement.values[1].stringValue()) {
                        return PSCurrentValueEvaluate(referencedEntry.currentValue, scriptData: scriptData)
                    }
                }
            case 3:
                //binary
                
                break
            default:
                break
            }
        }
        break
    case .StringToken(let stringElement):
        return stringElement.value
    }
    return "NULL"
}

public func PSCurrentValueEvaluate(currentValue : String, scriptData : PSScriptData) -> String {
    let parser = PSEntryValueParser(stringValue: currentValue)
    if parser.foundErrors { return "NULL" }
    
    return PSFunctionEvaluate(parser.listElement, scriptData: scriptData)
}