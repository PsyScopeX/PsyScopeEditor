//
//  PSLogFileNameController.swift
//  PsyScopeEditor
//
//  Created by James on 29/07/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

class PSLogFileNameController : NSObject {
    @IBOutlet var logFileTextField : NSTextField!
    var scriptData : PSScriptData! //gets populated by subjectvariablescontroller
    
    func reload() {
        logFileTextField.stringValue = PSGetLogFileName(scriptData)
    }
    
    func controlTextDidBeginEditing(_ obj: Notification) {
        scriptData.beginUndoGrouping("Edit Log File Name")
    }
    
    func controlTextDidChange(_ obj: Notification) {
        let logfile = scriptData.getOrCreateBaseEntry("Log File", type: PSType.Logging)
        
        logfile.currentValue = "\"\(logFileTextField.stringValue)\""
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
        scriptData.endUndoGrouping()
    }
}

func PSGetLogFileName(_ scriptData : PSScriptData) -> String {
    if let logFile = scriptData.getBaseEntry("Log File") {
        return logFile.currentValue.trimmingCharacters(in: CharacterSet(charactersIn: "\" "))
    } else {
        return "PsyScope.psylog"
    }
}
