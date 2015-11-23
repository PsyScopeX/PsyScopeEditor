//
//  PSExperimentSetupSheetController.swift
//  PsyScopeEditor
//
//  Created by James on 28/04/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSSubjectVariablesController : NSObject, NSTextFieldDelegate, NSTableViewDataSource {
    
    @IBOutlet var experimentSetupController : PSExperimentSetup!
    @IBOutlet var subjectInformationTableViewController : PSSubjectVariablesTableViewController!
    @IBOutlet var subjectVariablesSegmentedControl : NSSegmentedControl!
    @IBOutlet var dataFileNameController : PSDataFileNameController!
    @IBOutlet var logFileNameController : PSLogFileNameController!
    
    var subjectInformation : PSSubjectInformation!
    var scriptData : PSScriptData!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.scriptData = experimentSetupController.scriptData
        logFileNameController.scriptData = experimentSetupController.scriptData
        dataFileNameController.scriptData = experimentSetupController.scriptData
        self.subjectInformation = PSSubjectInformation(scriptData: scriptData)
    }
    
    func entrySelected() {
        //propogate selection to tableview and to other controls
        
        if let selectedVariable = self.selectedSubjectVariable {
            subjectVariablesSegmentedControl.setEnabled(true, forSegment: 1)
            subjectInformationTableViewController.selectItem(selectedVariable)
        } else {
            subjectVariablesSegmentedControl.setEnabled(false, forSegment: 1)
            subjectInformationTableViewController.selectItem(nil)
        }
        
    }
    
    //this gets called from PSExperimentSetup.update() -> which is called on script changes.
    func reloadSubjectVariablesData() {
        self.subjectInformation.updateVariablesFromScript()
        //self.groupingVariablesTableViewController.reloadData(subjectInformation.groupVariables)
        self.subjectInformationTableViewController.reloadData(subjectInformation)
        self.dataFileNameController.reloadData(subjectInformation.allVariables)
        self.dataFileNameController.updatePreviewTextView()
        self.logFileNameController.reload()
    }
    
    @IBAction func subjectVariablesSegmentedControlClick(segmentedControl : NSSegmentedControl) {
        switch(segmentedControl.selectedSegment) {
        case 0: // add
            subjectInformation.addNewVariable(false)
        case 1: // remove
            //get selected variable if there is one,
            if let selectedVariable = self.selectedSubjectVariable {
                //remove it
                subjectInformation.removeVariable(selectedVariable)
            }
        default:
            break
        }
  
    }
    
    var selectedSubjectVariable : PSSubjectVariable? {
        get {
            guard let selectedEntry = experimentSetupController.selectionInterface.getSelectedEntry(),
            selectedVariable = getSubjectVariableForEntry(selectedEntry) else {
                return nil
            }
            
            return selectedVariable
            
        }
    }
    
    func getSubjectVariableForEntry(entry : Entry) -> PSSubjectVariable? {
        for subjectVariable in subjectInformation.allVariables {
            if entry === subjectVariable.entry {
                return subjectVariable
            }
        }
        return nil
    }
    
    
    
    @IBAction func generateGroupsButtonClicked(_: AnyObject) {
        //grouping variables need to be radiobuttons / checkboxes
        var allValidGroupingTypes = true
        
        for groupingVariable in subjectInformation.groupVariables {
            switch (groupingVariable.dialogType) {
            case .CheckBoxes(_):
                break
            case .RadioButtons(_):
                break
            default:
                allValidGroupingTypes = false
            }
        }
        
        if !allValidGroupingTypes {
            PSModalAlert("Variables must be radio buttons or checkboxes to have automatic group generation")
            return
        }
        let groupCreator = PSGroupsCreator(scriptData: scriptData)
        groupCreator.generateGroups(subjectInformation.groupVariables)
        
    }    
}