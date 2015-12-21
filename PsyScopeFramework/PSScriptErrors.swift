//
//  PSScriptErrors.swift
//  PsyScopeEditor
//
//  Created by James on 11/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation


public class PSScriptError : NSObject {
    public var errorDescription : String = ""
    public var detailedDescription : String = ""
    public var solution : String = ""
    public var entryName : String?
    public var searchString : String? //the string to search for and highlight within entry
    public init(errorDescription : String, detailedDescription : String, solution : String, entryName : String? = nil, searchString : String? = nil) {
        self.searchString = entryName
        self.searchString = searchString
        self.errorDescription = errorDescription
        self.detailedDescription = detailedDescription
        self.solution = solution
        super.init()
    }
}


//Parse errors

public func PSErrorEntryName(nameOfIllegalEntry: String) -> PSScriptError {
    let description = "The name for entry: " + nameOfIllegalEntry + " : must consist of just one word"
    let solution = "Rename the entries named: " + nameOfIllegalEntry + " :to something that is just one word"
    return PSScriptError(errorDescription: "Entry Name Error", detailedDescription: description, solution: solution, entryName: nameOfIllegalEntry)
}


//Structure errors

public func PSErrorDoubleEntry(nameOfDoubledEntry: String) -> PSScriptError  {
        let description = "There are two entries named: " + nameOfDoubledEntry
        let solution = "Rename one of the entries named " + nameOfDoubledEntry + " to something different, or delete it"
    return PSScriptError(errorDescription: "Double Entry Error", detailedDescription: description, solution: solution, entryName: nameOfDoubledEntry)
    }


public func PSErrorNoEntries() -> PSScriptError  {
        let description = "A parsing error occurred - there are no entries"
        let solution = "Can't parse without any entries"
    return PSScriptError(errorDescription: "No Entries Error", detailedDescription: description, solution: solution)
    }



public func PSErrorUnknownSyntax(searchString : String) -> PSScriptError  {
        let d = "There is unknown syntax at beginning of script."
        let s = "Check syntax"
        return PSScriptError(errorDescription: "Unknown syntax error", detailedDescription: d, solution: s, searchString: searchString)
    }


public func PSErrorInvalidEntryToken(name : String, searchString : String?)  -> PSScriptError {
        let d = "The entry " + name + " has an invalid token type"
        let s = "Check syntax"
    return PSScriptError(errorDescription: "Invalid Entry Token Error", detailedDescription: d, solution: s, entryName: name, searchString: searchString)
    }


public func PSErrorDeepEntryToken(entryName : String, subEntryName : String) -> PSScriptError {
        let d = "The sub entry " + subEntryName + " cannot be a sub entry of any preceeding entries, as it's token suggests it is a level deeper than expected."
        let s = "Check syntax"
    return PSScriptError(errorDescription: "Deep Entry Error", detailedDescription: d, solution: s, entryName: entryName, searchString: subEntryName)
    }



public func PSErrorAlreadyDefinedType(entryName : String, type1 : String) -> PSScriptError {
        let d = "The entry " + entryName + " has already been defined as a " + type1 + " double definition is illegal"
        let s = "Check syntax"
        return PSScriptError(errorDescription: "Double Definition Error", detailedDescription: d, solution: s, entryName: entryName)
    }


public func PSErrorAmbiguousType(entryName : String, type1 : String, type2 : String) -> PSScriptError {
        let d = "The entry " + entryName + " can be defined as either a " + type1 + " or a " + type2
        let s = "Check syntax"
        return PSScriptError(errorDescription: "Ambiguous Type Error", detailedDescription: d, solution: s, entryName: entryName)
    }


public func PSErrorEntryNotFound(entryName : String, parentEntry : String, subEntry : String) -> PSScriptError {
    var entryLocation = parentEntry
    if subEntry != "" {
        entryLocation = entryLocation + "->" + subEntry
    }
    
    let d = "The entry " + entryName + " is referenced in " + entryLocation + " but cannot be found"
    let s = "Create entry or check existing entries for typographical error"
    return PSScriptError(errorDescription:"Entry Not Found Error", detailedDescription: d, solution: s, entryName: parentEntry, searchString: subEntry)
}

//Name Error

public func PSErrorIllegalEntryName(nameOfEntry: String) -> PSScriptError  {
    let description = "The name: \(nameOfEntry) is illegal for entries in this version of PsyScope"
    let solution = "Please rename all references to this entry to a new name"
    return PSScriptError(errorDescription: "Illegal Name Error", detailedDescription: description, solution: solution, entryName: nameOfEntry)
}
