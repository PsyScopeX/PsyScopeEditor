//
//  PSEntryValueChecker.swift
//  PsyScopeEditor
//
//  Created by James on 01/06/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSEntryValueChecker {
    
    let scriptData : PSScriptData
    var errors : [PSScriptError]
    
    init(scriptData : PSScriptData) {
        self.scriptData = scriptData
        self.errors = []
    }
    
    func checkScriptEntryValuesAsync(_ errorHandler : PSScriptErrorViewController) {
        DispatchQueue.main.async {
            self.checkScriptEntryValues(errorHandler)
        }
    }
    
    
    func checkScriptEntryValues(_ errorHandler : PSScriptErrorViewController) {
        
        let baseEntries = scriptData.getBaseEntries()
        for baseEntry in baseEntries {
            checkEntryValueSyntax(baseEntry)
        }
        for error in errors {
            errorHandler.newError(error)
        }
        errorHandler.presentErrors()
    }
    
    
    func checkEntryValueSyntax(_ entry : Entry) {
        
        let parser = PSEntryValueParser(stringValue: entry.currentValue)
        if parser.foundErrors {
            self.errors.append(PSEntryValueSyntaxError(entry))
        }
        for ge in entry.subEntries.array as! [Entry] {
            checkEntryValueSyntax(ge)
        }
    }
    
}

func PSEntryValueSyntaxError(_ entry : Entry) -> PSScriptError {
    let description = "A syntax error was detected on the entry named \(String(describing: entry.name)).  The line \"\(String(describing: entry.currentValue))\" has caused a syntax error."
    let solution = "Check the entire value for correct syntax."
    let new_error = PSScriptError(errorDescription: "Syntax Error", detailedDescription: description, solution: solution, entryName: entry.name)
    return new_error
}
