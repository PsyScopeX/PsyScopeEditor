//
//  PSScriptErrors.swift
//  PsyScopeEditor
//
//  Created by James on 11/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation


public class PSScriptError : NSObject {
    public var errorDescription : NSString = ""
    public var detailedDescription : NSString = ""
    public var solution : NSString = ""
    public var range : NSRange = NSMakeRange(0, 0)
    public var entry : Entry?
    public init(errorDescription : NSString, detailedDescription : NSString, solution : NSString, range : NSRange, entry : Entry? = nil) {
        self.entry = entry
        self.errorDescription = errorDescription
        self.detailedDescription = detailedDescription
        self.solution = solution
        self.range = range
        super.init()
    }
}


//Parse errors

public func PSErrorEntryName(nameOfDoubledEntry: NSString, range : NSRange) -> PSScriptError {
    let description = "The name for entry: " + (nameOfDoubledEntry as String) + " : must consist of just one word"
    let solution = "Rename the entries named: " + (nameOfDoubledEntry as String) + " :to something that is just one word"
    return PSScriptError(errorDescription: "Entry Name Error", detailedDescription: description, solution: solution, range: range)
}


//Structure errors

public func PSErrorDoubleEntry(nameOfDoubledEntry: NSString, range : NSRange) -> PSScriptError  {
        let description = "There are two entries named: " + (nameOfDoubledEntry as String)
        let solution = "Rename one of the entries named " + (nameOfDoubledEntry as String) + " to something different, or delete it"
    return PSScriptError(errorDescription: "Double Entry Error", detailedDescription: description, solution: solution, range: range)
    }


public func PSErrorNoEntries() -> PSScriptError  {
        let description = "A parsing error occurred - there are no entries"
        let solution = "Can't parse without any entries"
    return PSScriptError(errorDescription: "No Entries Error", detailedDescription: description, solution: solution, range: NSMakeRange(0,0))
    }



public func PSErrorUnknownSyntax(range : NSRange) -> PSScriptError  {
        let d = "There is unknown syntax at beginning of script."
        let s = "Check syntax"
        return PSScriptError(errorDescription: "Unknown syntax error", detailedDescription: d, solution: s, range: range)
    }


public func PSErrorInvalidEntryToken(name : NSString, range : NSRange)  -> PSScriptError {
        let d = "The entry " + (name as String) + " has an invalid token type"
        let s = "Check syntax"
        return PSScriptError(errorDescription: "Invalid Entry Token Error", detailedDescription: d, solution: s, range: range)
    }


public func PSErrorDeepEntryToken(name : NSString, range : NSRange) -> PSScriptError {
        let d = "The entry " + (name as String) + " cannot be a sub entry of any preceeding entries, as it's token suggests it is a level deeper than expected."
        let s = "Check syntax"
        return PSScriptError(errorDescription: "Deep Entry Error", detailedDescription: d, solution: s, range: range)
    }



public func PSErrorAlreadyDefinedType(name : NSString, type1 : String, range : NSRange) -> PSScriptError {
        let d = "The entry " + (name as String) + " has already been defined as a " + type1 + " double definition is illegal"
        let s = "Check syntax"
        return PSScriptError(errorDescription: "Double Definition Error", detailedDescription: d, solution: s, range: range)
    }


public func PSErrorAmbiguousType(name : NSString, type1 : String, type2 : NSString, range : NSRange) -> PSScriptError {
        let d = "The entry " + (name as String) + " can be defined as either a " + type1 + " or a " + (type2 as String)
        let s = "Check syntax"
        return PSScriptError(errorDescription: "Ambiguous Type Error", detailedDescription: d, solution: s, range: range)
    }


public func PSErrorEntryNotFound(name : String, parentEntry : String, subEntry : String, range : NSRange) -> PSScriptError {
    var entryLocation = parentEntry
    if subEntry != "" {
        entryLocation = entryLocation + "->" + subEntry
    }
    
    let d = "The entry " + name + " is referenced in " + entryLocation + " but cannot be found"
    let s = "Create entry or check existing entries for typographical error"
    return PSScriptError(errorDescription:"Entry Not Found Error", detailedDescription: d, solution: s, range: range)
}

//Name Error

public func PSErrorIllegalEntryName(nameOfEntry: NSString, range : NSRange) -> PSScriptError  {
    let description = "The name: \(nameOfEntry as String) is illegal for entries in this version of PsyScope"
    let solution = "Please rename all references to this entry to a new name"
    return PSScriptError(errorDescription: "Illegal Name Error", detailedDescription: description, solution: solution, range: range)
}
