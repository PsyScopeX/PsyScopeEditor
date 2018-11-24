//
//  PSTobiiSetupController.swift
//  PsyScopeEditor
//
//  Created by James on 15/01/2016.
//  Copyright © 2016 James. All rights reserved.
//

import Foundation

class PSTobiiSetupController : NSObject {
    @IBOutlet var tobiiSetup : PSTobiiSetup!
    @IBOutlet var useTobiiCheck : NSButton!
    
    var scriptData : PSScriptData!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.scriptData = tobiiSetup.scriptData
    }
    
    func refresh() {
        //detect whether tobii device is active
        guard let experimentEntry = scriptData.getMainExperimentEntryIfItExists() else { return }
        
        if let inputDevices = scriptData.getSubEntry("InputDevices", entry: experimentEntry) {
            let inputDevicesList = PSStringList(entry: inputDevices, scriptData: scriptData)
            useTobiiCheck.state = NSControl.StateValue(rawValue: inputDevicesList.contains("TobiiPlus") ? 1 : 0)
        } else {
            useTobiiCheck.state = convertToNSControlStateValue(0)
        }
    }
    
    @IBAction func useTobiiCheckClicked(_:AnyObject) {
        let experimentEntry = scriptData.getMainExperimentEntry()
        let inputDevices = scriptData.getOrCreateSubEntry("InputDevices", entry: experimentEntry, isProperty: true)
        let inputDevicesList = PSStringList(entry: inputDevices, scriptData: scriptData)
        if useTobiiCheck.state.rawValue == 1 {
            if !inputDevicesList.contains("TobiiPlus") {
                inputDevicesList.appendAsString("TobiiPlus")
            }
        } else {
            inputDevicesList.remove("TobiiPlus")
        }
        
        
    }
}
// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSControlStateValue(_ input: Int) -> NSControl.StateValue {
	return NSControl.StateValue(rawValue: input)
}
