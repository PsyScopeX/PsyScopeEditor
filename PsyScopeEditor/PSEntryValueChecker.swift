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
    
    func checkScriptEntryValuesAsync(errorHandler : PSScriptErrorViewController) {
        dispatch_async(dispatch_get_main_queue()) {
            self.checkScriptEntryValues(errorHandler)
        }
    }
    
    
    func checkScriptEntryValues(errorHandler : PSScriptErrorViewController) {
        
        let baseEntries = scriptData.getBaseEntries()
        for baseEntry in baseEntries {
            checkEntryValueSyntax(baseEntry)
        }
        for error in errors {
            errorHandler.newError(error)
        }
        errorHandler.presentErrors()
    }
    
    
    func checkEntryValueSyntax(entry : Entry) {
        
        let parser = PSEntryValueParser(stringValue: entry.currentValue)
        if parser.foundErrors {
            self.errors.append(PSEntryValueSyntaxError(entry))
        }
        for ge in entry.subEntries.array as! [Entry] {
            checkEntryValueSyntax(ge)
        }
    }
    
}

func PSEntryValueSyntaxError(entry : Entry) -> PSScriptError {
    let description = "A syntax error was detected on the entry named \(entry.name).  The line \"\(entry.currentValue)\" has caused a syntax error."
    let solution = "Check the entire value for correct syntax."
    let new_error = PSScriptError(errorDescription: "Syntax Error", detailedDescription: description, solution: solution, range: PSNullRange(), entry : entry)
    return new_error
}