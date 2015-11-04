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
    
    override func tableView(tableView: NSTableView, shouldEditTableColumn tableColumn: NSTableColumn?, row: Int) -> Bool {
        if tableColumn!.identifier == trialsColumn.identifier {
            return false
        }
        return super.tableView(tableView,shouldEditTableColumn:tableColumn,row: row)
    }
    
    override func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        if tableColumn!.identifier == trialsColumn.identifier {
            //calculate number of trials   
            //entry name = stringList.stringListRawUnstripped[row]
            let entryName = stringList.stringListRawUnstripped[row]
            if let entry = scriptData.getBaseEntry(entryName) {
                return PSNumberOfTrialsInBlock(entry, scriptData: scriptData).toString()
            }
            
            return "?"
        }
        return super.tableView(tableView, objectValueForTableColumn: tableColumn, row: row)
    }
}

enum PSTrialCountType {
    case Seconds(Int)
    case Trials(Int)
    case FixedTrials(Int)
    case Cycles(Int)
    case FixedCycles(Int)
    
    func toString() -> String {
        switch(self) {
        case let .Seconds(secs):
            return "\(secs) secs"
        case let .Trials(trials):
            return "\(trials) trials"
        case let .FixedTrials(trials):
            return "\(trials) trials"
        case let .Cycles(cycles):
            return "\(cycles) cycles"
        case let .FixedCycles(cycles):
            return "\(cycles) cycles"
        }
    }
}



func PSNumberOfTrialsInBlock(blockEntry : Entry, scriptData : PSScriptData) -> PSTrialCountType {
    
    if let _ = scriptData.getSubEntry("Templates", entry: blockEntry) {  //block
        //get blockduration cycles or fixedcycles
        if let blockDuration = scriptData.getSubEntry("BlockDuration", entry: blockEntry) {
            if let intValue = Int(blockDuration.currentValue) {
                return PSTrialCountType.Seconds(intValue)
            } else {
                return PSTrialCountType.Seconds(0)
            }
        } else if let cycles = scriptData.getSubEntry("Cycles", entry: blockEntry) {
            if let intValue = Int(cycles.currentValue) {
                return PSTrialCountType.Trials(intValue)
            } else {
                return PSTrialCountType.Trials(0)
            }
        } else if let fixedCycles = scriptData.getSubEntry("FixedCycles", entry: blockEntry) {
            if let intValue = Int(fixedCycles.currentValue) {
                return PSTrialCountType.FixedTrials(intValue)
            } else {
                return PSTrialCountType.FixedTrials(0)
            }
        } else {
            return PSTrialCountType.Trials(1)
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
            return PSTrialCountType.Cycles(cycleCount)
            
        } else if let fixedCycles = scriptData.getSubEntry("FixedCycles", entry: blockEntry) {
            if let intValue = Int(fixedCycles.currentValue) {
                return PSTrialCountType.FixedCycles(intValue)
            } else {
                return PSTrialCountType.FixedCycles(0)
            }
        } else {
            return PSTrialCountType.Cycles(1)
        }
    }
    
    return PSTrialCountType.Cycles(1)
}