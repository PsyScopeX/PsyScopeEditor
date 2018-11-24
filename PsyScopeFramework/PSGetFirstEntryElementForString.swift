//
//  PSGetFirstEntryElementForString.swift
//  PsyScopeEditor
//
//  Created by James on 17/12/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation


//often we have a string that we want in entryElement form, and to exlude lists....
public func PSGetFirstEntryElementForString(_ string : String) -> PSEntryElement? {
    let parser = PSEntryValueParser(stringValue: string)
    
    if parser.foundErrors {
        return nil
    } else {
        if case .list(let listElement) = parser.listElement {
            if let firstValue = listElement.values.first {
                return firstValue
            }
        }
    }
    
    return nil
}

public func PSGetFirstEntryElementForStringOrNull(_ string : String) -> PSEntryElement {
    if let entryElement = PSGetFirstEntryElementForString(string) {
        return entryElement
    } else {
        return PSEntryElement.null
    }
}


public func PSStringTokenFromString(_ string : String) -> PSEntryElement {
    return .stringToken(stringElement: PSStringElement(value: string, quotes: .none))
}

public func PSGetListElementForString(_ string : String) -> PSEntryElement {
    let parser = PSEntryValueParser(stringValue: string)
    if parser.foundErrors {
        return .null
    } else {
        return parser.listElement
    }
}

public func PSGetEntryElementAsStringList(_ entryElement : PSEntryElement) -> PSStringListElement {
    switch(entryElement) {
    case .null:
        let stringListElement = PSStringListElement()
        stringListElement.stringValue = "NULL"
        return stringListElement
    case let .list(stringListElement):
        return stringListElement
    case let .function(functionElement):
        let stringListElement = PSStringListElement()
        stringListElement.stringValue = functionElement.stringValue
        return stringListElement
    case let .stringToken(stringElement):
        let stringListElement = PSStringListElement()
        stringListElement.stringValue = stringElement.quotedValue
        return stringListElement
    }
}

//if list needs to appear as a sub list, then enclose it
public func PSConvertListElementToStringElement(_ element : PSEntryElement) -> PSEntryElement {
    if case .list(let stringListElement) = element {
        if stringListElement.values.count > 1 {
            //enclose
            return .stringToken(stringElement: PSStringElement(value: element.stringValue(), quotes: .curlyBrackets))
        } else if let first = stringListElement.values.first {
            return first
        } else {
            return element
        }
    } else {
        return element
    }
}
