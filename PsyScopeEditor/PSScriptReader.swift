//
//  PSScriptReader.swift
//  PsyScopeEditor
//
//  Created by James on 09/04/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

//parses script on construction
public class PSScriptReader {
    
    
    let debugMode : Bool = false
    
    var script : String
    
    public init(script : String) {
        self.script = script
        self.errors = []
        readScript()
    }
    
    var errors : [PSScriptError]
    
    
    //parsing variables
    var attributedString : NSMutableAttributedString = NSMutableAttributedString()
    var bad_token_string : String = ""
    var ghostScript : PSGhostScript = PSGhostScript()
    var previousGhostEntry : PSGhostEntry = PSGhostEntry()
    var newGhostEntry : PSGhostEntry = PSGhostEntry()
    
    
    //constsnts
    private let justCheck = true
    private let fullScan = false
    
    private let hashtag = NSCharacterSet(charactersInString: "#")
    private let newline = NSCharacterSet(charactersInString: "\n\r")
    private let allCharactersButNewline = NSCharacterSet(charactersInString: "\n\r").invertedSet
    private let allCharactersButColonHashtag = NSCharacterSet(charactersInString: ":#").invertedSet
    private let allCharactersButColonHashtagNewline = NSCharacterSet(charactersInString: ":#\n\r").invertedSet
    private let allCharactersButColonHashtagNewlineGt = NSCharacterSet(charactersInString: ":>#\n\r").invertedSet
    private let allCharactersButHashtagNewline = NSCharacterSet(charactersInString: "#\n\r").invertedSet
    private let entryDefiningCharacters = NSCharacterSet(charactersInString: ":>")
    private let gt = NSCharacterSet(charactersInString: ">")
    private let colon = NSCharacterSet(charactersInString: ":")
    private let quote = NSCharacterSet(charactersInString: "\"")
    private let space = NSCharacterSet.whitespaceCharacterSet()
    private let whiteSpace = NSCharacterSet.whitespaceAndNewlineCharacterSet()
    private let openBracket = NSCharacterSet(charactersInString: "[")
    private let closeBracket = NSCharacterSet(charactersInString: "[")
    
    lazy var entryNameCharacterSet : NSCharacterSet = {
        () -> NSCharacterSet in
        var allowed_characters = NSMutableCharacterSet(charactersInString: " _\"")
        allowed_characters.formUnionWithCharacterSet(NSCharacterSet.alphanumericCharacterSet())
        return allowed_characters
        }()
    
    
    //the parsing colours the code and populatess the ghost script
    //the user then applies a succesfully parsed code into true objects (compiling?)
    //both stages can produce different errors, e.g. lack of 'Experiments' token / key attributes is
    //currently found in the second stage, but may be worth building into the first
    func readScript() {
        
        let fixedString = "\(script)\n"
        let scanner = NSScanner(string: fixedString)
        attributedString = NSMutableAttributedString(string: fixedString)
        scanner.charactersToBeSkipped = NSCharacterSet(charactersInString: "")
        
        //new ghost script
        ghostScript = PSGhostScript()
        newGhostEntry = PSGhostEntry()
        previousGhostEntry = PSGhostEntry()
        
        //parse string (which populates entries and attributesForEntry
        while(!scanner.atEnd) {
            var success = false
            success = success || scanNextComment(scanner, justACheck: fullScan, addToEntry: false)
            success = success || scanNextEntry(scanner, justACheck: fullScan)
            
            if (!success) {
                //error, there is something not in an entry or a line, lets just eat it and color it red
                let prevValue = newGhostEntry.currentValue
                let startErrorLocation = scanner.scanLocation
                scanEntryValue(scanner, justACheck: fullScan)
                newGhostEntry.currentValue = prevValue
                formatRange(startErrorLocation, end: scanner.scanLocation,color: PSConstants.Fonts.scriptErrorColor)
                errors.append(PSErrorUnknownSyntax(prevValue))
            }
        }
        
        //make everything correct font
        attributedString.addAttribute(NSFontAttributeName, value: PSConstants.Fonts.scriptFont, range: NSMakeRange(0,attributedString.length))
        
        if (debugMode) { dumpGhostScript() }
    }
    
    func formatRange(start : Int, end : Int, color : NSColor){
        let range : NSRange = NSMakeRange(start, end - start)
        attributedString.addAttribute(NSForegroundColorAttributeName, value: color, range: range)
    }
    
    func dumpGhostScript() {
        print("PARSE COMPLETE - GHOST SCRIPT:")
        for e in ghostScript.entries {
            print("\(e.name) :: \(e.currentValue)")
            let ee : [PSGhostEntry] = e.subEntries
            for e2 in ee as [PSGhostEntry] {
                print("  \(e2.name) : \(e2.currentValue)")
                for e3 in e2.subEntries {
                    print("    \(e3.name) :> \(e3.currentValue)")
                    for e4 in e3.subEntries {
                        print("      \(e4.name) :>> \(e4.currentValue)")
                        
                        
                    }
                    
                }
                
            }
        }
    }
    
    
    //if a hashtag, eats all text up to newline then puts you at the next nonwhitespace character
    func scanNextComment(scanner : NSScanner, justACheck : Bool, addToEntry : Bool) -> Bool {
        
        let scanLocation = scanner.scanLocation
        var dump : NSString?
        
        if scanner.scanCharactersFromSet(hashtag, intoString: &dump) {
            
            //found a comment scan to newline
            var comments : NSString?
            if scanner.scanCharactersFromSet(allCharactersButNewline, intoString: &comments) {
                if (!justACheck && addToEntry) {
                    newGhostEntry.comments = comments! as String
                }
            }
            
            //eat the whitespace until next line
            scanner.scanCharactersFromSet(whiteSpace, intoString: &dump)
            
            if (justACheck) {
                scanner.scanLocation = scanLocation //reset to previous position
            } else {
                
                formatRange(scanLocation,end: scanner.scanLocation,color: PSConstants.Fonts.scriptCommentColor)
            }
            
            return true
        }
        return false
    }
    
    //if an entry is present, eats it into a ghost entry
    func scanNextEntry(scanner : NSScanner, justACheck : Bool) -> Bool {
        
        let startScanLocation = scanner.scanLocation
        
        var success = true
        var name : NSString?
        //var entryToken : NSString?
        
        //scans everything up to colon/hashtag/newline/gt into name
        success = scanner.scanCharactersFromSet(entryNameCharacterSet, intoString: &name)
        
        
        if success {
            //trim spaces
            name = name!.stringByTrimmingCharactersInSet(space)
            
            //check for valid name i.e. matched quotes on outside or no quotes.
            if name!.containsString("\"") {
                let trimmedName : NSString = name!.stringByTrimmingCharactersInSet(quote)
                if (trimmedName.length == name!.length - 2) && !trimmedName.containsString("\"") {
                    success = true
                } else {
                    success = false // either too many quotes or quotes actually in name...
                }
            }
        }
        
        //store name if good format and position
        if (!justACheck && success) { newGhostEntry.name = name as! String }
        let entryNameLocation = scanner.scanLocation
        
        //scan the token  (i.e. :: :> etc)
        //var level : Int?
        success = success && scanNextEntryToken(scanner, justACheck: justACheck)
        
        
        //we have all information we need to know if entry is here
        if (justACheck) {
            //arriving here means we definitely have an entry so can return true
            scanner.scanLocation = startScanLocation
            return success
        }
        
        if (success) {
            
            let entryTokenLocation = scanner.scanLocation
            //scan the value
            scanEntryValue(scanner, justACheck: fullScan)
            
            //populate the entry
            let newEntryLevel = Int(newGhostEntry.level)
            if (debugMode) { print("NEW ENTRY: \(name!) LEVEL: \(newEntryLevel)") }
            //newGhostEntry.range = NSMakeRange(startScanLocation,scanner.scanLocation - startScanLocation)
            
            if newEntryLevel == 0 {
                //base entry
                ghostScript.entries.append(newGhostEntry)
                formatRange(startScanLocation,end: entryNameLocation,color: PSConstants.Fonts.scriptEntryColor)
                previousGhostEntry = newGhostEntry
                newGhostEntry = PSGhostEntry()
            } else if newEntryLevel > Int(previousGhostEntry.level) + 1 {
                // error as entry is too far inwards
                formatRange(entryNameLocation,end: entryTokenLocation,color: PSConstants.Fonts.scriptErrorColor)
                
                //get base entry
                var parentGhostEntry = previousGhostEntry
                while (0 < Int(parentGhostEntry.level)) {
                    parentGhostEntry = parentGhostEntry.parent!
                }
                
                errors.append(PSErrorDeepEntryToken(parentGhostEntry.name, subEntryName: name! as String))
            } else {
                //entry has a valid parent
                var parentGhostEntry = previousGhostEntry
                if newEntryLevel == Int(previousGhostEntry.level) + 1 {
                    //child of previous entry
                    parentGhostEntry = previousGhostEntry
                } else if newEntryLevel <= Int(previousGhostEntry.level) {
                    //child of one of the previous entries
                    while (newEntryLevel <= Int(parentGhostEntry.level)) {
                        parentGhostEntry = parentGhostEntry.parent!
                    }
                    
                }
                
                //this entry will be stored
                newGhostEntry.parent = parentGhostEntry
                parentGhostEntry.subEntries.append(newGhostEntry)
                formatRange(startScanLocation,end: entryNameLocation,color: PSConstants.Fonts.scriptAttributeColor)
                previousGhostEntry = newGhostEntry
                newGhostEntry = PSGhostEntry()
            }
            
            
            //succesfully parsed an entry (with or without errors)
        } else {
            //did not parse an entry here - so reset nsscanner
            scanner.scanLocation = startScanLocation
        }
        return success
    }
    
    // gets the level of given token, or nil if it is not valid
    func scanNextEntryToken(scanner : NSScanner, justACheck : Bool) -> Bool {
        let startScanLocation = scanner.scanLocation
        var entryToken : NSString?
        var level : Int
        var success = scanner.scanCharactersFromSet(entryDefiningCharacters, intoString: &entryToken)
        
        if (!success) { return false }
        
        let token = entryToken! as String
        
        if success && token == "::" {
            level = 0
        } else if success && token == ":" {
            level = 1
        } else {
            
            //need to check it consists of a : followed by x amount of >s
            if success && token[token.startIndex.advancedBy(0)] != ":" {
                success = false
            }
            let gts = token.stringByTrimmingCharactersInSet(colon)
            let cls = gts.stringByTrimmingCharactersInSet(gt)
            if success &&  (gts.characters.count + 1 != token.characters.count || cls.characters.count != 0) {
                success  = false
            }
            level = Int(1 + gts.characters.count)
        }
        
        if (justACheck) {
            scanner.scanLocation = startScanLocation
        } else {
            if (success) {
                newGhostEntry.level = level
            } else {
                //error with getting entry level, so don't store the entry
                formatRange(startScanLocation,end: scanner.scanLocation,color: PSConstants.Fonts.scriptErrorColor)
                errors.append(PSErrorInvalidEntryToken(newGhostEntry.name, searchString: token))
            }
        }
        
        return success
    }
    
    //scans everything up to a new entry definition, alongside comments
    func scanEntryValue(scanner : NSScanner, justACheck : Bool) -> Bool {
        let startScanLocation = scanner.scanLocation
        //each new line check for new entry
        
        var metNextEntryOrEnd = false
        var fvalue : String = ""
        var whiteSpaceTemp : NSString? = NSString(UTF8String: "")
        var valueTemp : NSString?
        var inQuotes : Bool = false
        var inBrackets : Int = 0
        var inCurlyQuotes : Int = 0
        var startingNewLine = false
        
        while (!metNextEntryOrEnd) {
            
            if !inQuotes && inBrackets == 0 && inCurlyQuotes == 0 && scanNextEntry(scanner, justACheck: justCheck) || scanner.atEnd {
                //found an entry or at end, return
                if inQuotes || inBrackets != 0 || inCurlyQuotes != 0 {
                    return false
                }
                
                metNextEntryOrEnd = true
            } else {
                //if we had previous white space - add this to the value
                if let ws = whiteSpaceTemp {
                    fvalue = fvalue + (ws as String)
                }
                //add following stuff to the value
                if scanner.scanCharactersFromSet(allCharactersButHashtagNewline, intoString: &valueTemp) {
                    fvalue = fvalue  + (valueTemp! as String)
                    
                    
                    //scan new value for brackets and quotes
                    for char in (valueTemp! as String).characters {
                        if inCurlyQuotes == 0 && !inQuotes {
                            if char == "[" {
                                inBrackets++
                            } else if char == "]" {
                                inBrackets--
                            } else if char == "{" {
                                inCurlyQuotes++
                            } else if char == "}" {
                                inCurlyQuotes--
                            } else if char == "\"" {
                                inQuotes = true
                            }
                        } else if inQuotes && inCurlyQuotes == 0 && char == "\"" {
                            inQuotes = false
                        } else if !inQuotes {
                            if char == "{" {
                                inCurlyQuotes++
                            } else if char == "}" {
                                inCurlyQuotes--
                            }
                        }
                        
                        if inCurlyQuotes < 0 || inBrackets < 0 {
                            //error
                            return false
                        }
                    }
                    
                    startingNewLine = false
                }
                
                //comments don't count inside quotes or curly quotes
                if (!inQuotes && inCurlyQuotes == 0) {
                    var newLines : NSString?
                    if startingNewLine || scanner.scanCharactersFromSet(newline, intoString: &newLines) {
                        scanNextComment(scanner, justACheck: justACheck, addToEntry: false)
                        startingNewLine = true
                    } else {
                        scanNextComment(scanner, justACheck: justACheck, addToEntry: true)
                        startingNewLine = true
                    }
                } else {
                    if scanner.scanCharactersFromSet(hashtag, intoString: &valueTemp) {
                        fvalue = fvalue  + (valueTemp! as String)
                    }
                }
                scanner.scanCharactersFromSet(whiteSpace, intoString: &whiteSpaceTemp) //collect following whitespace
                //this whitespace is only added, if there is more value coming...
            }
        }
        
        if (!justACheck) {
            if (debugMode) { print("VALUE: \(fvalue)") }
            newGhostEntry.currentValue = fvalue.stringByTrimmingCharactersInSet(whiteSpace)
        } else {
            scanner.scanLocation = startScanLocation
        }
        return true
    }
}