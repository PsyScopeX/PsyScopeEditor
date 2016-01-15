//
//  PSGetFirstEntryElementForString.swift
//  PsyScopeEditor
//
//  Created by James on 17/12/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation


//often we have a string that we want in entryElement form, and to exlude lists....
public func PSGetFirstEntryElementForString(string : String) -> PSEntryElement? {
    let parser = PSEntryValueParser(stringValue: string)
    
    if parser.foundErrors {
        return nil
    } else {
        if case .List(let listElement) = parser.listElement {
            if let firstValue = listElement.values.first {
                return firstValue
            }
        }
    }
    
    return nil
}

public func PSGetFirstEntryElementForStringOrNull(string : String) -> PSEntryElement {
    if let entryElement = PSGetFirstEntryElementForString(string) {
        return entryElement
    } else {
        return PSEntryElement.Null
    }
}


public func PSStringTokenFromString(string : String) -> PSEntryElement {
    return .StringToken(stringElement: PSStringElement(value: string, quotes: .None))
}

public func PSGetListElementForString(string : String) -> PSEntryElement {
    let parser = PSEntryValueParser(stringValue: string)
    if parser.foundErrors {
        return .Null
    } else {
        return parser.listElement
    }
}

public func PSGetEntryElementAsStringList(entryElement : PSEntryElement) -> PSStringListElement {
    switch(entryElement) {
    case .Null:
        let stringListElement = PSStringListElement()
        stringListElement.stringValue = "NULL"
        return stringListElement
    case let .List(stringListElement):
        return stringListElement
    case let .Function(functionElement):
        let stringListElement = PSStringListElement()
        stringListElement.stringValue = functionElement.stringValue
        return stringListElement
    case let .StringToken(stringElement):
        let stringListElement = PSStringListElement()
        stringListElement.stringValue = stringElement.quotedValue
        return stringListElement
    }
}

//if list needs to appear as a sub list, then enclose it
public func PSConvertListElementToStringElement(element : PSEntryElement) -> PSEntryElement {
    if case .List(let stringListElement) = element {
        if stringListElement.values.count > 1 {
            //enclose
            return .StringToken(stringElement: PSStringElement(value: element.stringValue(), quotes: .CurlyBrackets))
        } else if let first = stringListElement.values.first {
            return first
        } else {
            return element
        }
    } else {
        return element
    }
}