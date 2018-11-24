//
//  PSScript.swift
//  PsyScopeEditor
//
//  Created by James on 05/08/2014.
//

import Cocoa

//runs PSScriptReader as an operation and allows access to token string and errors
class PSScriptReaderOperation: Operation {
    
    //mode with scriptWriter
    init(scriptWriter : PSScriptWriter) {
        self.scriptWriter = scriptWriter
        self.script = ""
        super.init()
    }
    
    //mode with ready string
    init(script : String) {
        self.scriptWriter = nil
        self.script = script
        super.init()
    }
    
    var script : String
    var scriptWriter : PSScriptWriter?
    var scriptReader : PSScriptReader?
    
    var valueRefersToEntry : Bool = false
    
    override func main() {
        if self.isCancelled { return }
        
        if let sw = scriptWriter {
            self.script = sw.generateScript()
        }
        if self.isCancelled { return }
        scriptReader = PSScriptReader(script: self.script)
    }
    
    var attributedString : NSAttributedString {
        get {
            if let sr = scriptReader {
                return sr.attributedString
            } else {
                return NSAttributedString(string: script)
            }
        }
    }
    
    var errors : [PSScriptError] {
        get {
            if let sr = scriptReader {
                return sr.errors
            } else {
                return []
            }
        }
    }
}



