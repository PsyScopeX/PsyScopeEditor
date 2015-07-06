//
//  PluginTools.swift
//  PsyScopeEditor
//
//  Created by James on 31/07/2014.
//  Copyright (c) 2014 James. All rights reserved.
//

import Cocoa

//if a line has 3 components it deals with the entry
//Entryname, value, isMainEntry

//returns the main Entry

class PSErrorAlreadyDefinedType : PSPluginScriptError {
    init(name : NSString, type1 : String) {
        var d = "The entry " + name + " has already been defined as a " + type1 + " double definition is illegal"
        var s = "Check syntax"
        super.init(errorDescription: "Double Definition Error", detailedDescription: d, solution: s)
    }
}

class PSErrorAmbiguousType : PSPluginScriptError {
    init(name : NSString, type1 : String, type2 : NSString) {
        var d = "The entry " + name + " can be defined as either a " + type1 + " or a " + type2
        var s = "Check syntax"
        super.init(errorDescription: "Ambiguous Type Error", detailedDescription: d, solution: s)
    }
}

class PSErrorEntryNotFound : PSPluginScriptError {
    init(name : String, parentEntry : String, subEntry : String) {
        var d = "The entry " + name + " is referenced in " + parentEntry + "." + parentEntry + " but cannot be found"
        var s = "Create entry or check existing entries for typographical error"
        super.init(errorDescription:"Entry Not Found Error", detailedDescription: d, solution: s)
    }
}

class PluginTools: NSObject {
    
    class func updateEntry(realEntry: Entry!, withGhostEntry ghostEntry: PSGhostEntry!, scriptData: PSScriptData!) {
        //use ghost entry to populate real entry stuff, check for essential properties etc
        realEntry.name = ghostEntry.name
        realEntry.currentValue = ghostEntry.currentValue
        realEntry.removeSubEntries(realEntry.subEntries)
        for ga in ghostEntry.subEntries as [PSGhostEntry] {
            var new_sub_entry = scriptData.getOrCreateSubEntry(ga.name, entry: realEntry, defaultSubEntry: { (sub_entry: Entry) -> Entry in
                sub_entry.userFriendlyName = ga.name
                sub_entry.name = ga.name
                return sub_entry })
            updateEntry(new_sub_entry, withGhostEntry: ga, scriptData: scriptData) //recursion for sub entries
            new_sub_entry.currentValue = ga.currentValue
            
            //TODO check that all essentials are ticked and present etc
        }
        
        ghostEntry.instantiated = true
    }
    
    //loads sub_entries into existing entry
    
    class func loadCSVIntoSubEntries(csvPath : String, entry : Entry, scriptData : PSScriptData) {
        var formatter = NSNumberFormatter()
        var sub_entries : [Entry] = []
        var theFile : String = String.stringWithContentsOfFile(csvPath, encoding: NSUTF8StringEncoding, error: nil)!
        var lines : [[String]] = []
        
        //format entries
        theFile.enumerateLines({
            (line: String, inout stop: Bool) -> () in
            var formatted_line = line.stringByReplacingOccurrencesOfString("\t", withString: " ")
            var lineComponents : [String] = formatted_line.componentsSeparatedByString(",")
            if (lineComponents.count == 7) {
                var components = lineComponents.map({
                    (linec : String) -> String in
                    return linec.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                })
                lines.append(components)} else {
                println("Incorrect format for sub_entries")
            }
        })
        
        for line in lines {
            var new_sub_entry = scriptData.insertNewSubEntryForEntry(entry)
            new_sub_entry.name = line[0]
            new_sub_entry.set = line[1]
            new_sub_entry.userFriendlyName = line[2]
            new_sub_entry.defaultValue = line[4]
            new_sub_entry.currentValue = line[3]
            new_sub_entry.isEssential = (formatter.numberFromString(line[5])!.isEqualToNumber(1))
            //var num = formatter.numberFromString(line[5])
            //var isone = num.isEqualToNumber(1)
            new_sub_entry.isProperty = (formatter.numberFromString(line[6])!.isEqualToNumber(1))
        }
    }
    
    //this will populate the 'type' of ghost entries indentified by OWN keyAttribute as type
    class func identifyEntriesByKeyAttribute(ghostScript: PSGhostScript!, keyAttribute: String, type : String) -> [PSPluginScriptError] {
        var errors : [PSPluginScriptError] = []
        
        for ge in ghostScript.entries as [PSGhostEntry] {
            for a in ge.subEntries as [PSGhostEntry] {
                if (a.name == keyAttribute) {
                    //found a blocks sub_entry, label entries found
                    if (ge.type.isEmpty || ge.type == type) {
                        ge.type = type
                        
                    } else {
                        
                        println("Error here: \(ge.type) key type already defined")
                        errors.append(PSErrorAmbiguousType(name: ge.name,type1: ge.type,type2: type))
                    }
                    
                    
                }
            }
        }
        return errors
    }
    //this will populate the 'type' of ghost entries identified in OTHER entries keyAttribute, to type - throwing errors if already defined...
    class func identifyEntriesOfWithKeyAttribute(ghostScript: PSGhostScript!, keyAttribute: String, type : String) -> [PSPluginScriptError] {
        var errors : [PSPluginScriptError] = []
        
        for ge in ghostScript.entries as [PSGhostEntry] {
            for a in ge.subEntries as [PSGhostEntry] {
                if (a.name == keyAttribute) {
                    //found a blocks sub_entry, label entries found
                    var current_blocks : [String] = a.currentValue.componentsSeparatedByString(" ")
                    for block_name in current_blocks {
                        var found_block_name = false
                        for ge2 in ghostScript.entries as [PSGhostEntry] {
                            if ge2.name == block_name {
                                //found the block name, label it
                                found_block_name = true
                                if (ge2.type.isEmpty || ge2.type == type) {
                                    ge2.type = type
                                    
                                    //create link
                                    ge.links.append(ge2)
                                    
                                } else {
                                    
                                    println("Error here: \(ge2.type) key type already defined")
                                    errors.append(PSErrorAmbiguousType(name: ge2.name,type1: ge2.type,type2: type))
                                }
                                
                            }
                        }
                        
                        if (!found_block_name) {
                            errors.append(PSErrorEntryNotFound(name: block_name, parentEntry: ge.name, subEntry: a.name))
                        }
                    }
                }
            }
        }
        return errors
    }
    
    class func ImageNamed(image_name : String) -> NSImage {
        return NSImage(contentsOfFile: NSBundle(forClass: PluginTools.self).pathForImageResource(image_name))
    }
    
}

extension NSManagedObjectContext {
    func getAllObjectsOfEntity(name : String) -> [NSManagedObject] {
        var fetch = NSFetchRequest()
        fetch.entity = NSEntityDescription.entityForName(name, inManagedObjectContext: self)
        
        var error : NSError? = nil
        
        var results : [NSManagedObject] = self.executeFetchRequest(fetch, error: &error) as [NSManagedObject]
        if let e = error {
            
            println(e)
        }
        return results
    }
    
    func insertNewObjectOfEntity(name : String) -> NSManagedObject {
        return NSEntityDescription.insertNewObjectForEntityForName(name, inManagedObjectContext: self) as NSManagedObject
    }
    
}
