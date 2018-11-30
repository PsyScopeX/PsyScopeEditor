//
//  PSObjectParser.swift
//  ScriptScanner
//
//  Created by James on 10/03/2015.
//  Copyright (c) 2015 James Alvarez. All rights reserved.
//

import Foundation




enum PSTokenType : Int {
    case openRoundBracket = 1
    case closeRoundBracket
    case openSquareBracket
    case closeSquareBracket
    case quoteString
    case singleQuoteString
    case curlyBracketString
    case value
    case binaryOperator
    case unaryOperator
    case whiteSpace
    case inlineAttributeSymbol
    case functionEvaluationSymbol
}

struct PSToken{
    let type : PSTokenType
    let value : String?
}

class PSTokenizer {
    
    init(string : String) {
        scanner = Scanner(string: string)
        scanner.charactersToBeSkipped = nil
        tokens = []
        tokenize()
    }
    
    var tokens : [PSToken]
    let scanner : Scanner
    var error = false
    
    func tokenize() {
        
        
        while (scanner.isAtEnd == false) {
            var not_found = true
            not_found = !tokenizeDoubleSymbol()
            not_found = not_found && !tokenizeSingleSymbol()
            not_found = not_found && !tokenizeCurlyBracketString()
            not_found = not_found && !tokenizeQuoteString()
            not_found = not_found && !tokenizeBrackets()
            not_found = not_found && !tokenizeValue()
            not_found = not_found && !tokenizeWhitespace()
            
            if (not_found) {
                AddError("Unknown Symbol")
            }
            
            if (error) { break }
        }
    }
    
    func dumpTokens() -> String {
        let tokensAsStrings : [String] = tokens.map({
            if let s = $0.value {
                return s
            } else {
                return ""
            }})
        
        return tokensAsStrings.joined(separator: " / ")
    }
    
    let whiteSpaceNewLine = CharacterSet.whitespacesAndNewlines
    lazy var validValueCharacters : CharacterSet = {
        var set : NSMutableCharacterSet = NSMutableCharacterSet.alphanumeric()
        set.addCharacters(in: "_")
        set.addCharacters(in: "%")
        return set as CharacterSet
        }()
    
    func tokenizeStringArray(_ array : [String], type: PSTokenType) -> Bool {
        for str in array {
            if scanner.scanString(str, into: nil) {
                tokens.append(PSToken(type: type, value: str))
                return true
            }
        }
        return false
    }
    
    func tokenizeValue() -> Bool {
        var value : NSString?
        if scanner.scanCharacters(from: validValueCharacters, into: &value) {
            tokens.append(PSToken(type: .value, value : value as String?))
            return true
        }
        return false
    }
    
    func tokenizeWhitespace() -> Bool {
        var value : NSString?
        if scanner.scanCharacters(from: whiteSpaceNewLine, into: &value) {
            tokens.append(PSToken(type: .whiteSpace, value : value as String?))
            return true
        } else if scanner.scanString(commaToken, into: &value) {
            tokens.append(PSToken(type: .whiteSpace, value : value as String?))
            return true
        }
        return false
    }
    
    func tokenizeDoubleSymbol() -> Bool {
        if tokenizeStringArray(doubleSymbolBinaryTokens, type: .binaryOperator) {
            return true
        } else if tokenizeStringArray(doubleSymbolUnaryTokens, type: .unaryOperator) {
            return true
        } else if tokenizeStringArray(functionEvaluationTokens, type: .functionEvaluationSymbol) {
            return true
        } /*else if tokenizeStringArray(symbolValueTokens, type: .Value) {
            return true
        }*/
        return false
    }
    
    func tokenizeSingleSymbol() -> Bool {
        if tokenizeStringArray(singleSymbolBinaryTokens, type: .binaryOperator) {
            return true
        } else if tokenizeStringArray(singleSymbolUnaryTokens, type: .unaryOperator) {
            return true
        } else if scanner.scanString(inlineAttributeToken, into: nil) {
            tokens.append(PSToken(type: .inlineAttributeSymbol, value: inlineAttributeToken))
            return true
        }
        return false
    }
    
    func tokenizeCurlyBracketString() -> Bool {
        
        if scanner.scanString("{", into: nil) {
            var nestedLevel = 1
            var fullValue : String = ""
            
            var scannedAll = false
            
            while (!scannedAll) {
            
                var value : NSString?
                scanner.scanUpToCharacters(from: CharacterSet(charactersIn: "{}"), into: &value)
                if let v = value {
                    fullValue += v as String
                }
            
                if scanner.scanString("{", into: nil) {
                    fullValue += "{"
                    nestedLevel += 1
                } else if scanner.scanString("}", into: nil) {
                    if nestedLevel > 1 {
                        fullValue += "}"
                    }
                    nestedLevel -= 1
                } else {
                    
                }
        
                if nestedLevel == 0 {
                    scannedAll = true
                } else if scanner.isAtEnd {
                    AddError("No matching close bracket for curly bracket string before end of file")
                    return true
                }
                
            
            }
            
            
            tokens.append(PSToken(type: .curlyBracketString, value: fullValue))
            return true
        }
        return false
    }
    
    func tokenizeQuoteString() -> Bool {
        if scanner.scanString("\"", into: nil) {
            var value : NSString?
            scanner.scanUpTo("\"", into: &value)
            
            if value == nil {
                value = ""
            }
            
            if scanner.scanString("\"", into: nil) {
                tokens.append(PSToken(type: .quoteString, value: value as String?))
                return true
            } else {
                AddError("No matching close quote for double quote string")
                return true
            }
        } else  if scanner.scanString("'", into: nil) {
                var value : NSString?
                scanner.scanUpTo("'", into: &value)
                
                if value == nil {
                    value = ""
                }
                
                if scanner.scanString("'", into: nil) {
                    tokens.append(PSToken(type: .singleQuoteString, value: value as String?))
                    return true
                } else {
                    AddError("No matching close quote for single quote string")
                    return true
                }
            }
        return false
    }
    
    func tokenizeBrackets() -> Bool {
        if scanner.scanString("(", into: nil) {
            tokens.append(PSToken(type: .openRoundBracket, value: "("))
            return true
        } else if scanner.scanString(")", into: nil) {
            tokens.append(PSToken(type: .closeRoundBracket, value: ")"))
            return true
        } else if scanner.scanString("[", into: nil) {
            tokens.append(PSToken(type: .openSquareBracket, value: "["))
            return true
        } else if scanner.scanString("]", into: nil) {
            tokens.append(PSToken(type: .closeSquareBracket, value: "]"))
            return true
        }
        return false
    }
    
    
    
    func AddError(_ description : String) {
        error = true
        print("ERROR: " + description)
    }
    
    //func**(value1, value2, ...valuen) evaluates func(value1), func(value2), ... func(valuen). Built-in function names cannot be used for func, only script-de- fined functions.
    //func*!(ref1, ref2, ...refn) evaluates func(@ref1), func(@ref2), ... func(@refn). Built-in function names cannot be used for func, only script-defined functions.
    
    //let symbolValueTokens = ["=>"]
    let functionEvaluationTokens = ["**","*!"]
    let commaToken = ","
    let doubleSymbolBinaryTokens = ["==",">=","!=","||","&&","$+","$-","-$","//",">>","->","..","=>"]
    let inlineAttributeToken = ":"
    let singleSymbolBinaryTokens = ["~","%",".","|","$","*","/","+","-","<",">","="]
    let doubleSymbolUnaryTokens = ["f@"]
    let singleSymbolUnaryTokens = ["^","@","`","?"]
}




