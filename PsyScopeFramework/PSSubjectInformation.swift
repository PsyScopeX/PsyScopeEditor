//
//  PSSubjectVariables.swift
//  PsyScopeEditor
//
//  Created by James on 11/05/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

open class PSSubjectInformation : NSObject {
    public init(scriptData : PSScriptData) {
        self.scriptData = scriptData
        self.runStartVariables = []
        self.runEndVariables = []
        self.neverRunVariables = []
        super.init()
        updateVariablesFromScript()
    }
    
    let scriptData : PSScriptData
    open var runStartVariables : [PSSubjectVariable]
    open var runEndVariables : [PSSubjectVariable]
    open var neverRunVariables : [PSSubjectVariable]
    
    open var groupVariables : [PSSubjectVariable] {
        get {
            return allVariables.filter({ $0.isGroupingVariable})
        }
    }
    
    open var allVariables : [PSSubjectVariable] {
        return runStartVariables + runEndVariables + neverRunVariables
    }
    
    open func updateVariablesFromScript() {
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
            dialogVariables.remove(at: dialogVariables.index(of: runStartVariable)!)
        }
        
        for runEndEntryName in runEndStringList {
            guard let runEndVariable = dialogVariables.filter({ $0.name == runEndEntryName }).first else { continue }
            runEndVariables.append(runEndVariable)
            dialogVariables.remove(at: dialogVariables.index(of: runEndVariable)!)
        }
        
        
        // remainder are never run
        neverRunVariables = dialogVariables
    }
    
    open func addNewVariable(_ isGroupingVariable : Bool) {
        if isGroupingVariable {
            runStartVariables.append(PSSubjectVariable.NewGroupingVariable(scriptData))
        } else {
            runStartVariables.append(PSSubjectVariable.NewSubjectVariable(scriptData))
        }
        updateScriptFromVariables()
    }
    
    open func removeVariable(_ variable : PSSubjectVariable) {
        variable.removeFromScript()
    }
    
    open func updateScriptFromVariables() {
        for subjectVariable in allVariables { subjectVariable.saveToScript() }
    }
    
    open func moveVariable(_ variable : PSSubjectVariable, schedule: PSSubjectVariableSchedule, position: Int) {
        //print("Moving variable \(variable.name) to list \(schedule) at position \(position)")
        scriptData.beginUndoGrouping("Change variable")
        if variable.storageOptions.schedule != schedule {
            //move to new schedule
            var storageOptions = variable.storageOptions
            storageOptions.schedule = schedule
            variable.storageOptions = storageOptions
        } else if schedule == .never {
            NSSound.beep() //alert as there is no point in swapping variables in Never condition 
        }
        
        //move to correct position within list
        switch schedule {
        case .runStart:
            if let runStartList = PSStringList(baseEntryName: "RunStart", scriptData: scriptData),
                let index = runStartList.indexOfValueWithString(variable.name) {
                    //print("RunStart move \(index) to \(position)")
                    runStartList.move(index, to: position)
            }
            
        case.runEnd:
            if let runEndList = PSStringList(baseEntryName: "RunEnd", scriptData: scriptData),
                let index = runEndList.indexOfValueWithString(variable.name) {
                    runEndList.move(index, to: position)
            }
        case .never:
            
            //NSSound.beep() //no reason to swap around dialogs that dont get run
            break
        }
        
        
        scriptData.endUndoGrouping()
    }
}
