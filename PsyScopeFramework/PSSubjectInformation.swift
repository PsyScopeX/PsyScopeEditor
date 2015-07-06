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
        self.subjectVariables = []
    }
    
    let scriptData : PSScriptData
    public var subjectVariables : [PSSubjectVariable]
    
    public var groupVariables : [PSSubjectVariable] {
        get {
            return subjectVariables.filter({ $0.isGroupingVariable})
        }
    }
    
    public func updateVariablesFromScript() {
        subjectVariables = []

        //get all base entries which are dialogs, and are run at some point of the experiment
        let dialogEntries = scriptData.getBaseEntriesOfType("DialogVariable")
        var groupVarNames : [String] = []
        subjectVariables = dialogEntries.map { PSSubjectVariable(entry: $0, scriptData: self.scriptData) }

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
        
//        SubjectName:: "SUBJECT NAME"
//        
//        SubjectNumber:: 1
//        Type: Integer
//        
//        RunNumber:: 1
//        Type: Integer
//        
//        SubjectNumAndGroup::
//        Dialog: SubjectNumAndGroup
//        SubjectCount: 1
//        RunCount: 1
//        GroupRunCount: 1
//        GroupSpecs: JamesGroup @"JamesGroup"
//        
//        JamesGroup:: But1
//        Dialog: Buttons
//        Msg: "
//        "
//        Buttons: But1 But2
//        Default: But1
//        
//        JamesVariable:: CB1 CB2
//        Dialog: CheckBoxes
//        Msg: "
//        "
//        CheckBoxes: CB1 CB2
//        Default: CB1
    
    }
    
    public func addNewVariable(isGroupingVariable : Bool) {
        if isGroupingVariable {
            subjectVariables.append(PSSubjectVariable.NewGroupingVariable(scriptData))
        } else {
            subjectVariables.append(PSSubjectVariable.NewSubjectVariable(scriptData))
        }
    }
    
    public func updateScriptFromVariables() {
        for subjectVariable in subjectVariables { subjectVariable.saveToScript() }
    }
}