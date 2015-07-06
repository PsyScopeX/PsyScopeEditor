//
//  PSScriptWriter.swift
//  PsyScopeEditor
//
//  Created by James on 05/08/2014.
//

import Cocoa
import AVFoundation

class PSScriptWriter: NSObject {
    
    init(scriptData : PSScriptData, responder : NSResponder) {
        self.scriptData = scriptData
        self.responder = responder
    }
    
    var scriptData : PSScriptData
    var responder : NSResponder
    var new_line : String = "\n"
    
    
    func entryToText(entry : Entry, level : Int) -> String {
        var text : String = String(count: 4 * level, repeatedValue: Character(" "))
        text += entry.name + ":"
        if level == 0 { text += ":" }
        if level > 1 { text += String(count: level - 1, repeatedValue: Character(">")) }
        text += " " + entry.currentValue
        
        if entry.comments != "" {
            text += "#" + entry.comments
        }
            
        text += new_line
        var attribs = entry.subEntries.array as! [Entry]
        for a in attribs {
            text += entryToText(a, level: level + 1)
        }
        return text
    }
    
    func sectionToText(section : Section) -> String {
        
        var text : String = ""
        if section.sectionName != "Root" { text = "#> " + section.sectionName + new_line + new_line }
        var entries = section.objects.array as! [Entry]
        for entry in entries {
            text += entryToText(entry, level: 0) + new_line
        }
        return text
    }
    
    func generateScript() -> String {
        var sections = scriptData.getSections()
        sections = sections.sort({
            (e1: Section, e2: Section) -> Bool in
            return e1.scriptOrder.unsignedIntegerValue < e2.scriptOrder.unsignedIntegerValue })
        var script : String = ""
        for section in sections {
            script += sectionToText(section) + new_line
        }
        return script.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    
    
}
