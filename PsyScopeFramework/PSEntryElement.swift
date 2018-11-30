//
//  PSEntryElement.swift
//  ScriptScanner
//
//  Created by James on 24/03/2015.
//  Copyright (c) 2015 James Alvarez. All rights reserved.
//

import Foundation


public enum PSEntryElement : Equatable {
    case null
    case stringToken(stringElement: PSStringElement)
    case list(stringListElement: PSStringListElement)
    case function(functionElement: PSFunctionElement)
    
    func dumpElement(_ level : Int) -> String {
        var string = String(repeating: " ", count: level * 4) + "-"
        switch (self) {
        case .stringToken(let stringElement):
            string = string + stringElement.value + "\n"
        case .function(let functionElement):
            string = string + "Func: " + functionElement.functionName + "\n"
            for v in functionElement.values {
                string = string + v.dumpElement(level + 1)
            }
            
        case .null:
            string = string + "NULL\n"
        case .list(let listElement):
            string = string + "List: \n"
            for v in listElement.values {
                string = string + v.dumpElement(level + 1)
            }
        }
        return string
    }
    
    func dump() -> String {
        return self.dumpElement(0)
    }
    
    public func stringValue() -> String {
        switch (self) {
        case .stringToken(let stringElement):
            return stringElement.quotedValue
        case .function(let functionElement):
            return functionElement.stringValue
        case .null:
            return "NULL"
        case .list(let listElement):
            return listElement.stringValue
        }
    }
}

public func ==(a: PSEntryElement, b: PSEntryElement) -> Bool {
    switch (a, b) {
    case (.null, .null):
        return true
    case (.stringToken(let a),   .stringToken(let b))   where a.value == b.value: return true
    default: return false
    }
}

public class PSStringElement {
    public enum Quotes {
        case none
        case doubles
        case singles
        case curlyBrackets
    }
    public var value : String
    public var quotes : Quotes
    public var quotedValue : String {
        get {
            switch (quotes) {
            case .none:
                return value
            case .doubles:
                return "\"" + value + "\""
            case .curlyBrackets:
                return "{" + value + "}"
            case .singles:
                return "'" + value + "'"
            }
        }
    }
    
    //prestrip all quotes and brackets on outside / make sure no curlies in there too
    public init?(strippedValue : String) {
        //use logic to decide what type
        
        
        if strippedValue.rangeOfCharacter(from: CharacterSet(charactersIn: "{}")) != nil {
            value = ""
            quotes = .none
            return nil
        }
        
        value = strippedValue
        let whiteSpaceRange = strippedValue.rangeOfCharacter(from: CharacterSet.whitespaces)
        let quoteRange = strippedValue.range(of: "\"")
        
        if quoteRange != nil {
            quotes = .curlyBrackets
        } else if (whiteSpaceRange != nil) {
            quotes = .doubles
        } else {
            quotes = .none
        }
    }
    
    public init(value : String, quotes : Quotes) {
        self.value = value
        self.quotes = quotes
    }
}

open class PSCompoundEntryElement : NSObject {
    
    public var stringValue : String {
        get {
            fatalError("Cannot get string this abstract class PSCompoundEntryElement")
        }
        
        set {
            fatalError("Cannot parse this abstract class PSCompoundEntryElement")
        }
    }
    
    public func getStringValues() -> [String] {
        return values.map({
            self.elementToString($0, stripped: false)
        })
    }
    
    public func getStrippedStringValues() -> [String] {
        return values.map({
            self.elementToString($0, stripped: true)
        })
    }
    
    public func setStringValues(_ stringList : [String]) {
        let value = stringList.joined(separator: " ")
        let parse = PSEntryValueParser(stringValue: value)
        self.values = parse.values
        self.foundErrors = parse.foundErrors
    }
    
    public func elementToString(_ element : PSEntryElement, stripped : Bool) -> String {
        switch (element) {
        case .stringToken(let string):
            // put in quotes if necessary
            if stripped {
                return string.value
            } else {
                return string.quotedValue
            }
        case .list(let stringList):
            // put in square brackets
            if stripped {
                return stringList.stringValue
            } else {
                return "[" + stringList.stringValue + "]"
            }
        case .function(let function):
            //takes care of itself
            if stripped {
                return function.getStringValues().joined(separator: " ")
            } else {
                return function.stringValue
            }
        case .null:
            return "NULL"
        }
    }
    
    //searches for stringTokens in tree return true if found
    public func searchForStringToken(_ token : String) -> Bool {
        for val in values {
            switch(val) {
            case .null:
                break
            case let .stringToken(stringElement):
                if stringElement.value == token {
                    return true
                }
            case let .list(stringListElement):
                if stringListElement.searchForStringToken(token) {
                    return true
                }
            case let .function(functionElement):
                if functionElement.searchForStringToken(token) {
                    return true
                }
            }
        }
        return false
    }
    
    //renames stringElements, and function names...
    public func renameAllStringTokens(_ oldName : String, newName : String) {
        for (index,val) in values.enumerated() {
            switch(val) {
            case .null:
                break
            case let .stringToken(stringElement):
                if stringElement.value == oldName {
                    if let newElement = PSStringElement(strippedValue: newName) {
                        if stringElement.quotes != .none {
                            newElement.quotes = stringElement.quotes
                        }
                        values[index] = PSEntryElement.stringToken(stringElement: newElement)
                    } else {
                        PSModalAlert("Fatal Error due to funny name...")
                        fatalError("Funny name error")
                    }
                }
            case let .list(stringListElement):
                stringListElement.renameAllStringTokens(oldName, newName: newName)
            case let .function(functionElement):
                if functionElement.functionName == oldName {
                    functionElement.functionName = newName
                }
                functionElement.renameAllStringTokens(oldName, newName: newName)
            }
        }
    }
    
    public var values : [PSEntryElement] = []
    public var foundErrors : Bool = false
}

let whiteSpaceCharacterSet = CharacterSet.whitespaces
let quoteCharacterSet = CharacterSet(charactersIn: "\"")
let whiteSpaceAndQuoteCharacterSet = NSMutableCharacterSet(charactersIn: " \t\"")
//trims whitespace
public func PSTrimWhiteSpace(_ string : String) -> String {
    return string.trimmingCharacters(in: whiteSpaceCharacterSet)
}

//returns the string in quotes ONLY if it needs to be
public func PSQuotedString(_ string : String) -> String {
    let trimmed_string = PSTrimWhiteSpace(string)
    
    //detect internal whitespace (Try nsscanner??)
    let whiteSpaceRange = trimmed_string.rangeOfCharacter(from: whiteSpaceCharacterSet)
    
    if (whiteSpaceRange != nil) {
        return "\"" + trimmed_string + "\"" //return in quotes
    } else {
        return trimmed_string //return as it is
    }
}

//returns the string without surrounding quotes / brackets (but leaves them in if they are nested)
public func PSUnquotedString(_ string : String) -> String {
    return string.trimmingCharacters(in: whiteSpaceAndQuoteCharacterSet as CharacterSet)
}

open class PSStringListElement : PSCompoundEntryElement {
    
    override open var stringValue : String {
        get {
            let elements = getStringValues()
            return elements.joined(separator: " ")
        }
        
        set {
            //need to parse
            let parse = PSEntryValueParser(stringValue: newValue)
            self.values = parse.values
            self.foundErrors = parse.foundErrors
        }
    }
    
    
}


public class PSFunctionElement : PSCompoundEntryElement {
    
    public class func InlineEntryNamed(_ name : String, values : [String]) -> PSEntryElement {
        let function = PSFunctionElement()
        function.functionName = name
        function.bracketType = .inlineEntry
        function.setStringValues(values)
        return PSEntryElement.function(functionElement: function)
    }
    
    public class func FromStringValue(_ stringValue : String) -> PSFunctionElement {
        let function = PSFunctionElement()
        function.stringValue = stringValue
        return function
    }
    
    public var functionName : String = ""
    public enum FType {
        case square
        case round
        case expression
        case inlineEntry
    }
    
    public var bracketType : FType = .square
    
    public func getParametersStringValue() -> String {
        let elements = getStringValues()
        let seperator : String = " "
        var stringValue = elements.joined(separator: seperator)
        
        //@ should be attached directly to front (no seperator) .
        stringValue = stringValue.replacingOccurrences(of: "@ ", with: "@")
        
        //~ should be attached directly to front and back.
        stringValue = stringValue.replacingOccurrences(of: " ~ ", with: "~")
        return stringValue
    }
    
    override public var stringValue : String {
        get {
            let joinedElements = getParametersStringValue()
            
            switch(bracketType) {
            case .square:
                return functionName + "[" + joinedElements + "]"
            case .round:
                return functionName + "(" + joinedElements + ")"
            case .expression:
                return joinedElements
            case .inlineEntry:
                return functionName + ":" + joinedElements
            }
        }
        set {
            //need to parse
            let parse = PSEntryValueParser(stringValue: newValue)
            
            if parse.values.count == 1 {
                switch(parse.values.first!) {
                case .function(let functionElement):
                    self.bracketType = functionElement.bracketType
                    self.values = functionElement.values
                    self.functionName = functionElement.functionName
                    self.foundErrors = parse.foundErrors
                    return
                default:
                    break
                }
            }
            self.bracketType = .square
            self.values = []
            self.functionName = ""
            self.foundErrors = true
            
        }
    }
}

