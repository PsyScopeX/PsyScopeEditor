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
        
        //get variables referenced in runstart
        
        //get variables referenced in runend

        //get all base entries which are dialogs, and are run at some point of the experiment
        let dialogEntries = scriptData.getBaseEntriesOfType("DialogVariable").filter({
            if let dialogSubEntry = scriptData.getSubEntry("Dialog", entry: $0) {
                if ["Standard","CheckBoxes","Buttons"].contains(dialogSubEntry.currentValue) {
                    return true
                }
            }
            return false
        })
    
        neverRunVariables = dialogEntries.map { PSSubjectVariable(entry: $0, scriptData: self.scriptData) }
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
        print("Moving variable \(variable.name) to list \(schedule) at position \(position)")
    }
}

//Entries which cause a dialog to be run

//StartUp

//ExperimentStartUp

//RunStart

//These same entries with 'Log' as a prefix and a Dialog: subentry with value 'LogInfo' cause the variable to be logged

//SubjectNumAndGroup has the Dialog: subentry with 'SubjectNumAndGroup' which is the automatic calculation

//AutoDataFile AutoDatafile:: "SUBJECT NAMESUBJECT NAME-"
//Dialog: MakeFileName
//Strings: @"SubjectName" @"SubjectName" "-"
//Folder:
//UseDir: FALSE

//PracticeStart

//RunEnd

//PracticeEnd

//RunBreak

//PracticeBreak

//ExperimentClose

//Shutdown



//RunStart:: LogRunStart SubjectNumAndGroup JamesGroup JamesVariable

//LogRunStart:: SubjectName JamesGroup JamesVariable
//   Dialog: LogInfo