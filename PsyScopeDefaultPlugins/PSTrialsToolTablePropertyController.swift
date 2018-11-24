//
//  PSTrialsToolTablePropertyController.swift
//  PsyScopeEditor
//
//  Created by James on 11/06/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSTrialsToolTablePropertyController : PSToolTablePropertyController {
    
    @IBOutlet var trialsColumn : NSTableColumn!
    
    override func tableView(_ tableView: NSTableView, shouldEdit tableColumn: NSTableColumn?, row: Int) -> Bool {
        if convertFromNSUserInterfaceItemIdentifier(tableColumn!.identifier) == convertFromNSUserInterfaceItemIdentifier(trialsColumn.identifier) {
            return false
        }
        return super.tableView(tableView,shouldEdit:tableColumn,row: row)
    }
    
    override func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if convertFromNSUserInterfaceItemIdentifier(tableColumn!.identifier) == convertFromNSUserInterfaceItemIdentifier(trialsColumn.identifier) {
            //calculate number of trials   
            //entry name = stringList.stringListRawUnstripped[row]
            let entryName = stringList.stringListRawUnstripped[row]
            if let entry = scriptData.getBaseEntry(entryName) {
                return PSNumberOfTrialsInBlock(entry, scriptData: scriptData).toString() as AnyObject
            }
            
            return "?" as AnyObject
        }
        return super.tableView(tableView, objectValueFor: tableColumn, row: row)
    }
}

enum PSTrialCountType {
    case seconds(Int)
    case trials(Int)
    case fixedTrials(Int)
    case cycles(Int)
    case fixedCycles(Int)
    
    func toString() -> String {
        switch(self) {
        case let .seconds(secs):
            return "\(secs) secs"
        case let .trials(trials):
            return "\(trials) trials"
        case let .fixedTrials(trials):
            return "\(trials) trials"
        case let .cycles(cycles):
            return "\(cycles) cycles"
        case let .fixedCycles(cycles):
            return "\(cycles) cycles"
        }
    }
}



func PSNumberOfTrialsInBlock(_ blockEntry : Entry, scriptData : PSScriptData) -> PSTrialCountType {
    
    if let _ = scriptData.getSubEntry("Templates", entry: blockEntry) {  //block
        //get blockduration cycles or fixedcycles
        if let blockDuration = scriptData.getSubEntry("BlockDuration", entry: blockEntry) {
            if let intValue = Int(blockDuration.currentValue) {
                return PSTrialCountType.seconds(intValue)
            } else {
                return PSTrialCountType.seconds(0)
            }
        } else if let cycles = scriptData.getSubEntry("Cycles", entry: blockEntry) {
            if let intValue = Int(cycles.currentValue) {
                return PSTrialCountType.trials(intValue)
            } else {
                return PSTrialCountType.trials(0)
            }
        } else if let fixedCycles = scriptData.getSubEntry("FixedCycles", entry: blockEntry) {
            if let intValue = Int(fixedCycles.currentValue) {
                return PSTrialCountType.fixedTrials(intValue)
            } else {
                return PSTrialCountType.fixedTrials(0)
            }
        } else {
            return PSTrialCountType.trials(1)
        }
    } else if let _ = scriptData.getSubEntry("Blocks", entry: blockEntry) { //super block
        if let cycles = scriptData.getSubEntry("Cycles", entry: blockEntry) {
            
            var cycleCount : Int = 0
            if let intValue = Int(cycles.currentValue) {
                cycleCount = intValue
            }
            
            /*var scaleCount : Int = 1
            if let scaleBlocks = scriptData.getSubEntry("ScaleBlocks", entry: blockEntry), intValue = scaleBlocks.currentValue.toInt() {
                scaleCount = intValue
            }
            
            var totalCycles = cycleCount * scaleCount*/
            return PSTrialCountType.cycles(cycleCount)
            
        } else if let fixedCycles = scriptData.getSubEntry("FixedCycles", entry: blockEntry) {
            if let intValue = Int(fixedCycles.currentValue) {
                return PSTrialCountType.fixedCycles(intValue)
            } else {
                return PSTrialCountType.fixedCycles(0)
            }
        } else {
            return PSTrialCountType.cycles(1)
        }
    }
    
    return PSTrialCountType.cycles(1)
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSUserInterfaceItemIdentifier(_ input: NSUserInterfaceItemIdentifier) -> String {
	return input.rawValue
}
