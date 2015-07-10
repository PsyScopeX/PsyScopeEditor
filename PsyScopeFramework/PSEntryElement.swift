//
//  PSEntryElement.swift
//  ScriptScanner
//
//  Created by James on 24/03/2015.
//  Copyright (c) 2015 James Alvarez. All rights reserved.
//

import Foundation


public enum PSEntryElement : Equatable {
    case Null
    case StringToken(stringElement: PSStringElement)
    case List(stringListElement: PSStringListElement)
    case Function(functionElement: PSFunctionElement)
    
    func dumpElement(level : Int) -> String {
        var string = String(count: level * 4, repeatedValue: Character(" ")) + "-"
        switch (self) {
        case .StringToken(let stringElement):
            string = string + stringElement.value + "\n"
        case .Function(let functionElement):
            string = string + "Func: " + functionElement.functionName + "\n"
            for v in functionElement.values {
                string = string + v.dumpElement(level + 1)
            }
            
        case .Null:
            string = string + "NULL\n"
        case .List(let listElement):
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
}

public func ==(a: PSEntryElement, b: PSEntryElement) -> Bool {
    switch (a, b) {
    case (.Null, .Null):
        return true
    case (.StringToken(let a),   .StringToken(let b))   where a.value == b.value: return true
    default: return false
    }
}

public class PSStringElement {
    public enum Quotes {
        case None
        case Doubles
        case Singles
        case CurlyBrackets
    }
    public var value : String
    public var quotes : Quotes
    public var quotedValue : String {
        get {
            switch (quotes) {
            case .None:
                return value
            case .Doubles:
                return "\"" + value + "\""
            case .CurlyBrackets:
                return "{" + value + "}"
            case .Singles:
                return "'" + value + "'"
            }
        }
    }
    
    //prestrip all quotes and brackets on outside / make sure no curlies in there too
    public init?(strippedValue : String) {
        //use logic to decide what type
        
        
        if strippedValue.rangeOfCharacterFromSet(NSCharacterSet(charactersInString: "{}")) != nil {
            value = ""
            quotes = .None
            return nil
        }
        
        value = strippedValue
        let whiteSpaceRange = strippedValue.rangeOfCharacterFromSet(NSCharacterSet.whitespaceCharacterSet())
        let quoteRange = strippedValue.rangeOfString("\"")
        
        if quoteRange != nil {
            quotes = .CurlyBrackets
        } else if (whiteSpaceRange != nil) {
            quotes = .Doubles
        } else {
            quotes = .None
        }
    }
    
    public init(value : String, quotes : Quotes) {
        self.value = value
        self.quotes = quotes
    }
}

public class PSCompoundEntryElement : NSObject {
    
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
    
    public func setStringValues(stringList : [String]) {
        let value = " ".join(stringList)
        let parse = PSEntryValueParser(stringValue: value)
        self.values = parse.values
        self.foundErrors = parse.foundErrors
    }
    
    public func elementToString(element : PSEntryElement, stripped : Bool) -> String {
        switch (element) {
        case .StringToken(let string):
            // put in quotes if necessary
            if stripped {
                return string.value
            } else {
                return string.quotedValue
            }
        case .List(let stringList):
            // put in square brackets
            if stripped {
                return stringList.stringValue
            } else {
                return "[" + stringList.stringValue + "]"
            }
        case .Function(let function):
            //takes care of itself
            if stripped {
                return " ".join(function.getStringValues())
            } else {
                return function.stringValue
            }
        case .Null:
            return "NULL"
        }
    }
    
    //searches for stringTokens in tree return true if found
    public func searchForStringToken(token : String) -> Bool {
        for (index,val) in values.enumerate() {
            switch(val) {
            case .Null:
                break
            case let .StringToken(stringElement):
                if stringElement.value == token {
                    return true
                }
            case let .List(stringListElement):
                if stringListElement.searchForStringToken(token) {
                    return true
                }
            case let .Function(functionElement):
                if functionElement.searchForStringToken(token) {
                    return true
                }
            }
        }
        return false
    }
    
    //renames stringElements, and function names...
    public func renameAllStringTokens(oldName : String, newName : String) {
        for (index,val) in values.enumerate() {
            switch(val) {
            case .Null:
                break
            case let .StringToken(stringElement):
                if stringElement.value == oldName {
                    if let newElement = PSStringElement(strippedValue: newName) {
                        if stringElement.quotes != .None {
                            newElement.quotes = stringElement.quotes
                        }
                        values[index] = PSEntryElement.StringToken(stringElement: newElement)
                    } else {
                        PSModalAlert("Fatal Error due to funny name...")
                        fatalError("Funny name error")
                    }
                }
            case let .List(stringListElement):
                stringListElement.renameAllStringTokens(oldName, newName: newName)
            case let .Function(functionElement):
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

let whiteSpaceCharacterSet = NSCharacterSet.whitespaceCharacterSet()
let quoteCharacterSet = NSCharacterSet(charactersInString: "\"")
let whiteSpaceAndQuoteCharacterSet = NSMutableCharacterSet(charactersInString: " \t\"")
//trims whitespace
public func PSTrimWhiteSpace(string : String) -> String {
    return string.stringByTrimmingCharactersInSet(whiteSpaceCharacterSet)
}

//returns the string in quotes ONLY if it needs to be
public func PSQuotedString(string : String) -> String {
    let trimmed_string = PSTrimWhiteSpace(string)
    
    //detect internal whitespace (Try nsscanner??)
    let whiteSpaceRange = trimmed_string.rangeOfCharacterFromSet(whiteSpaceCharacterSet)
    
    if (whiteSpaceRange != nil) {
        return "\"" + trimmed_string + "\"" //return in quotes
    } else {
        return trimmed_string //return as it is
    }
}

//returns the string without surrounding quotes / brackets (but leaves them in if they are nested)
public func PSUnquotedString(string : String) -> String {
    return string.stringByTrimmingCharactersInSet(whiteSpaceAndQuoteCharacterSet)
}

public class PSStringListElement : PSCompoundEntryElement {
    
    override public var stringValue : String {
        get {
            let elements = getStringValues()
            return " ".join(elements)
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
    
    public class func InlineEntryNamed(name : String, values : [String]) -> PSEntryElement {
        var function = PSFunctionElement()
        function.functionName = name
        function.bracketType = .InlineEntry
        function.setStringValues(values)
        return PSEntryElement.Function(functionElement: function)
    }
    
    public var functionName : String = ""
    public enum Type {
        case Square
        case Round
        case Expression
        case InlineEntry
    }
    
    public var bracketType : Type = .Square
    
    public func getParametersStringValue() -> String {
        let elements = getStringValues()
        let seperator : String = " "
        return seperator.join(elements)
    }
    
    override public var stringValue : String {
        get {
            let elements = getStringValues()
            let seperator : String = " "
            
            switch(bracketType) {
            case .Square:
                return functionName + "[" + seperator.join(elements) + "]"
            case .Round:
                return functionName + "(" + seperator.join(elements) + ")"
            case .Expression:
                return seperator.join(elements)
            case .InlineEntry:
                return functionName + ":" + seperator.join(elements)
            }
        }
        set {
            //need to parse
            let parse = PSEntryValueParser(stringValue: newValue)
            
            if parse.values.count == 1 {
                switch(parse.values.first!) {
                case .Function(let functionElement):
                    self.bracketType = functionElement.bracketType
                    self.values = functionElement.values
                    self.functionName = functionElement.functionName
                    self.foundErrors = parse.foundErrors
                    return
                default:
                    break
                }
            }
            self.bracketType = .Square
            self.values = []
            self.functionName = ""
            self.foundErrors = true
            
        }
    }
}

