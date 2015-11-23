//
//  PSSubjectVariables.swift
//  PsyScopeEditor
//
//  Created by James on 11/05/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

public class PSSubjectInformation : NSObject {
    public init(scriptData : PSScriptData) {
        self.scriptData = scriptData
        self.runStartVariables = []
        self.runEndVariables = []
        self.neverRunVariables = []
        super.init()
        updateVariablesFromScript()
    }
    
    let scriptData : PSScriptData
    public var runStartVariables : [PSSubjectVariable]
    public var runEndVariables : [PSSubjectVariable]
    public var neverRunVariables : [PSSubjectVariable]
    
    public var groupVariables : [PSSubjectVariable] {
        get {
            return allVariables.filter({ $0.isGroupingVariable})
        }
    }
    
    public var allVariables : [PSSubjectVariable] {
        return runStartVariables + runEndVariables + neverRunVariables
    }
    
    public func updateVariablesFromScript() {
        runStartVariables = []
        runEndVariables = []
        neverRunVariables = []
        

        //get all base entries which are dialogs, and are run at some point of the experiment
        var dialogVariables = scriptData.getBaseEntriesOfType(PSType.SubjectInfo).filter({
            if let dialogSubEntry = scriptData.getSubEntry("Dialog", entry: $0) {
                if ["Standard","CheckBoxes","Buttons"].contains(dialogSubEntry.currentValue) {
                    return true
                }
            }
            return false
        }).map { PSSubjectVariable(entry: $0, scriptData: self.scriptData) }
        
        var runStartStringList : [String] = []
        var runEndStringList : [String] = []

        if let runStartList = PSStringList(baseEntryName: "RunStart", scriptData: scriptData) {
            runStartStringList = runStartList.stringListRawStripped
        }
        
        if let runEndList = PSStringList(baseEntryName: "RunEnd", scriptData: scriptData) {
            runEndStringList = runEndList.stringListRawStripped
        }
        
        
        // populate into correct positions
        for runStartEntryName in runStartStringList {
            guard let runStartVariable = dialogVariables.filter({ $0.name == runStartEntryName }).first else { continue }
            runStartVariables.append(runStartVariable)
            dialogVariables.removeAtIndex(dialogVariables.indexOf(runStartVariable)!)
        }
        
        for runEndEntryName in runEndStringList {
            guard let runEndVariable = dialogVariables.filter({ $0.name == runEndEntryName }).first else { continue }
            runEndVariables.append(runEndVariable)
            dialogVariables.removeAtIndex(dialogVariables.indexOf(runEndVariable)!)
        }
        
        
        // remainder are never run
        neverRunVariables = dialogVariables
    }
    
    public func addNewVariable(isGroupingVariable : Bool) {
        if isGroupingVariable {
            runStartVariables.append(PSSubjectVariable.NewGroupingVariable(scriptData))
        } else {
            runStartVariables.append(PSSubjectVariable.NewSubjectVariable(scriptData))
        }
        updateScriptFromVariables()
    }
    
    public func removeVariable(variable : PSSubjectVariable) {
        variable.removeFromScript()
    }
    
    public func updateScriptFromVariables() {
        for subjectVariable in allVariables { subjectVariable.saveToScript() }
    }
    
    public func moveVariable(variable : PSSubjectVariable, schedule: PSSubjectVariableSchedule, position: Int) {
        //print("Moving variable \(variable.name) to list \(schedule) at position \(position)")
        scriptData.beginUndoGrouping("Change variable")
        if variable.storageOptions.schedule != schedule {
            //move to new schedule
            var storageOptions = variable.storageOptions
            storageOptions.schedule = schedule
            variable.storageOptions = storageOptions
        } else if schedule == .Never {
            NSBeep() //alert as there is no point in swapping variables in Never condition 
        }
        
        //move to correct position within list
        switch schedule {
        case .RunStart:
            if let runStartList = PSStringList(baseEntryName: "RunStart", scriptData: scriptData),
                index = runStartList.indexOfValueWithString(variable.name) {
                    //print("RunStart move \(index) to \(position)")
                    runStartList.move(index, to: position)
            }
            
        case.RunEnd:
            if let runEndList = PSStringList(baseEntryName: "RunEnd", scriptData: scriptData),
                index = runEndList.indexOfValueWithString(variable.name) {
                    runEndList.move(index, to: position)
            }
        case .Never:
            
            //NSBeep() //no reason to swap around dialogs that dont get run
            break
        }
        
        
        scriptData.endUndoGrouping()
    }
}
