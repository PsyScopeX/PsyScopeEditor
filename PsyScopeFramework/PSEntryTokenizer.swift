//
//  PSObjectParser.swift
//  ScriptScanner
//
//  Created by James on 10/03/2015.
//  Copyright (c) 2015 James Alvarez. All rights reserved.
//

import Foundation




enum PSTokenType : Int {
    case OpenRoundBracket = 1
    case CloseRoundBracket
    case OpenSquareBracket
    case CloseSquareBracket
    case QuoteString
    case SingleQuoteString
    case CurlyBracketString
    case Value
    case BinaryOperator
    case UnaryOperator
    case WhiteSpace
    case InlineAttributeSymbol
    case FunctionEvaluationSymbol
}

struct PSToken{
    let type : PSTokenType
    let value : String?
}

class PSTokenizer {
    
    init(string : String) {
        scanner = NSScanner(string: string)
        scanner.charactersToBeSkipped = nil
        tokens = []
        tokenize()
    }
    
    var tokens : [PSToken]
    let scanner : NSScanner
    var error = false
    
    func tokenize() {
        
        
        while (scanner.atEnd == false) {
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
        
        return tokensAsStrings.joinWithSeparator(" / ")
    }
    
    let whiteSpaceNewLine = NSCharacterSet.whitespaceAndNewlineCharacterSet()
    lazy var validValueCharacters : NSCharacterSet = {
        var set : NSMutableCharacterSet = NSMutableCharacterSet.alphanumericCharacterSet()
        set.addCharactersInString("_")
        set.addCharactersInString("%")
        return set
        }()
    
    func tokenizeStringArray(array : [String], type: PSTokenType) -> Bool {
        for str in array {
            if scanner.scanString(str, intoString: nil) {
                tokens.append(PSToken(type: type, value: str))
                return true
            }
        }
        return false
    }
    
    func tokenizeValue() -> Bool {
        var value : NSString?
        if scanner.scanCharactersFromSet(validValueCharacters, intoString: &value) {
            tokens.append(PSToken(type: .Value, value : value as? String))
            return true
        }
        return false
    }
    
    func tokenizeWhitespace() -> Bool {
        var value : NSString?
        if scanner.scanCharactersFromSet(whiteSpaceNewLine, intoString: &value) {
            tokens.append(PSToken(type: .WhiteSpace, value : value as? String))
            return true
        } else if scanner.scanString(commaToken, intoString: &value) {
            tokens.append(PSToken(type: .WhiteSpace, value : value as? String))
            return true
        }
        return false
    }
    
    func tokenizeDoubleSymbol() -> Bool {
        if tokenizeStringArray(doubleSymbolBinaryTokens, type: .BinaryOperator) {
            return true
        } else if tokenizeStringArray(doubleSymbolUnaryTokens, type: .UnaryOperator) {
            return true
        } else if tokenizeStringArray(functionEvaluationTokens, type: .FunctionEvaluationSymbol) {
            return true
        } /*else if tokenizeStringArray(symbolValueTokens, type: .Value) {
            return true
        }*/
        return false
    }
    
    func tokenizeSingleSymbol() -> Bool {
        if tokenizeStringArray(singleSymbolBinaryTokens, type: .BinaryOperator) {
            return true
        } else if tokenizeStringArray(singleSymbolUnaryTokens, type: .UnaryOperator) {
            return true
        } else if scanner.scanString(inlineAttributeToken, intoString: nil) {
            tokens.append(PSToken(type: .InlineAttributeSymbol, value: inlineAttributeToken))
            return true
        }
        return false
    }
    
    func tokenizeCurlyBracketString() -> Bool {
        
        if scanner.scanString("{", intoString: nil) {
            var nestedLevel = 1
            var fullValue : String = ""
            
            var scannedAll = false
            
            while (!scannedAll) {
            
                var value : NSString?
                scanner.scanUpToCharactersFromSet(NSCharacterSet(charactersInString: "{}"), intoString: &value)
                if let v = value {
                    fullValue += v as String
                }
            
                if scanner.scanString("{", intoString: nil) {
                    fullValue += "{"
                    nestedLevel++
                } else if scanner.scanString("}", intoString: nil) {
                    if nestedLevel > 1 {
                        fullValue += "}"
                    }
                    nestedLevel--
                } else {
                    
                }
        
                if nestedLevel == 0 {
                    scannedAll = true
                } else if scanner.atEnd {
                    AddError("No matching close bracket for curly bracket string before end of file")
                    return true
                }
                
            
            }
            
            
            tokens.append(PSToken(type: .CurlyBracketString, value: fullValue))
            return true
        }
        return false
    }
    
    func tokenizeQuoteString() -> Bool {
        if scanner.scanString("\"", intoString: nil) {
            var value : NSString?
            scanner.scanUpToString("\"", intoString: &value)
            
            if value == nil {
                value = ""
            }
            
            if scanner.scanString("\"", intoString: nil) {
                tokens.append(PSToken(type: .QuoteString, value: value as? String))
                return true
            } else {
                AddError("No matching close quote for double quote string")
                return true
            }
        } else  if scanner.scanString("'", intoString: nil) {
                var value : NSString?
                scanner.scanUpToString("'", intoString: &value)
                
                if value == nil {
                    value = ""
                }
                
                if scanner.scanString("'", intoString: nil) {
                    tokens.append(PSToken(type: .SingleQuoteString, value: value as? String))
                    return true
                } else {
                    AddError("No matching close quote for single quote string")
                    return true
                }
            }
        return false
    }
    
    func tokenizeBrackets() -> Bool {
        if scanner.scanString("(", intoString: nil) {
            tokens.append(PSToken(type: .OpenRoundBracket, value: "("))
            return true
        } else if scanner.scanString(")", intoString: nil) {
            tokens.append(PSToken(type: .CloseRoundBracket, value: ")"))
            return true
        } else if scanner.scanString("[", intoString: nil) {
            tokens.append(PSToken(type: .OpenSquareBracket, value: "["))
            return true
        } else if scanner.scanString("]", intoString: nil) {
            tokens.append(PSToken(type: .CloseSquareBracket, value: "]"))
            return true
        }
        return false
    }
    
    
    
    func AddError(description : String) {
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




