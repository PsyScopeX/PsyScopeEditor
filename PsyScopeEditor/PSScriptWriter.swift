//
//  PSScriptWriter.swift
//  PsyScopeEditor
//
//  Created by James on 05/08/2014.
//

import Cocoa
import AVFoundation

class PSScriptWriter: NSObject {
    
    init(scriptData : PSScriptData) {
        self.scriptData = scriptData
    }
    
    var scriptData : PSScriptData
    var new_line : String = "\n"
    
    
    func entryToText(_ entry : Entry, level : Int) -> String {
        var text : String = String(repeating: " ", count: 4 * level)
        text += entry.name + ":"
        if level == 0 { text += ":" }
        if level > 1 { text += String(repeating: ">", count: level - 1) }
        text += " " + entry.currentValue
        
        if entry.comments != "" {
            text += "#" + entry.comments
        }
            
        text += new_line
        let attribs = entry.subEntries.array as! [Entry]
        for a in attribs {
            text += entryToText(a, level: level + 1)
        }
        return text
    }
    
    func sectionToText(_ section : Section) -> String {
        
        var text : String = ""
        if section.sectionName != "Root" { text = "#> " + section.sectionName + new_line + new_line }
        let entries = section.objects.array as! [Entry]
        for entry in entries {
            text += entryToText(entry, level: 0) + new_line
        }
        return text
    }
    
    func generateScript() -> String {
        let initialLine = "# Created or modified with PsyEditor 0.2\n\n"
        var sections = scriptData.getSections()
        sections = sections.sorted(by: {
            (e1: Section, e2: Section) -> Bool in
            return e1.scriptOrder.uintValue < e2.scriptOrder.uintValue })
        var script : String = initialLine
        for section in sections {
            script += sectionToText(section) + new_line
        }
        return script.trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    func generatePsyScopeXScript() -> String {
        let script = "#PsyScope 1.0\n# Script template, Version 1.0\n\n" + generateScript()
        return script.replacingOccurrences(of: "\n", with: "\r")
    }
    
}
