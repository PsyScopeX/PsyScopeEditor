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
    
    override func controlTextDidBeginEditing(obj: NSNotification) {
        scriptData.beginUndoGrouping("Edit Log File Name")
    }
    
    override func controlTextDidChange(obj: NSNotification) {
        let logfile = scriptData.getOrCreateBaseEntry("Log File", type: "LogFile", user_friendly_name: "Log File", section_name: "LogFile", zOrder: 77)//messy logfile vs log file
        
        logfile.currentValue = "\"\(logFileTextField.stringValue)\""
    }
    
    override func controlTextDidEndEditing(obj: NSNotification) {
        scriptData.endUndoGrouping()
    }
}

func PSGetLogFileName(scriptData : PSScriptData) -> String {
    if let logFile = scriptData.getBaseEntry("Log File") {
        return logFile.currentValue.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "\" "))
    } else {
        return "PsyScope.psylog"
    }
}