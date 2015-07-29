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
        if let logFile = scriptData.getBaseEntry("Log File") {
            logFileTextField.stringValue = logFile.currentValue
        } else {
            logFileTextField.stringValue = "PsyScope.psylog"
        }
    }
    
    override func controlTextDidBeginEditing(obj: NSNotification) {
        scriptData.beginUndoGrouping("Edit Log File Name")
    }
    
    override func controlTextDidChange(obj: NSNotification) {
        let logfile = scriptData.getOrCreateBaseEntry("Log File", type: "Log File", user_friendly_name: "Log File", section_name: "Log File", zOrder: 77)
        
        logfile.currentValue = logFileTextField.stringValue
    }
    
    override func controlTextDidEndEditing(obj: NSNotification) {
        scriptData.endUndoGrouping()
    }
}