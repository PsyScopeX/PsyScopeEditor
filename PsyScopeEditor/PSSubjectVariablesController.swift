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
    @IBOutlet var groupingVariablesTableViewController : PSSubjectVariablesTableViewController!
    @IBOutlet var subjectInformationTableViewController : PSSubjectVariablesTableViewController!
    @IBOutlet var subjectVariablesSegmentedControl : NSSegmentedControl!
    @IBOutlet var groupingVariablesTableView : NSTableView!
    @IBOutlet var subjectVariablesTableView : NSTableView!
    @IBOutlet var dataFileNameController : PSDataFileNameController!
    
    var subjectInformation : PSSubjectInformation!
    var scriptData : PSScriptData!
    var selectedSubjectTableView : Bool = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.scriptData = experimentSetupController.scriptData
        dataFileNameController.scriptData = experimentSetupController.scriptData
        self.subjectInformation = PSSubjectInformation(scriptData: scriptData)
    }
    
    func entrySelected() {
        //propogate selection to tableview and to other controls
        
        if let selectedVariable = self.selectedSubjectVariable {
            if (selectedSubjectTableView || !subjectInformation.groupVariables.contains(selectedVariable)) {
                subjectVariablesSegmentedControl.setEnabled(true, forSegment: 1)
                subjectInformationTableViewController.selectItem(selectedVariable)
                return
            } else {
                subjectVariablesSegmentedControl.setEnabled(false, forSegment: 1)
                groupingVariablesTableViewController.selectItem(selectedVariable)
                return
            }
        }
        
        subjectVariablesSegmentedControl.setEnabled(false, forSegment: 1)
        groupingVariablesTableView.deselectAll(nil)
        subjectVariablesTableView.deselectAll(nil)
    }
    
    func reloadData() {
        self.subjectInformation.updateVariablesFromScript()
        self.groupingVariablesTableViewController.reloadData(subjectInformation.groupVariables)
        self.subjectInformationTableViewController.reloadData(subjectInformation.subjectVariables)
        self.dataFileNameController.reloadData(subjectInformation.subjectVariables)
        self.dataFileNameController.updatePreviewTextView()
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
        for subjectVariable in subjectInformation.subjectVariables {
            if entry === subjectVariable.entry {
                return subjectVariable
            }
        }
        return nil
    }
    
    func tableViewSelectionBecameActive(tableView : NSTableView) {
        if tableView == subjectVariablesTableView {
            //current selected subject
            selectedSubjectTableView = true
            groupingVariablesTableView.deselectAll(nil)
        } else {
            //current selected grouping
            selectedSubjectTableView = false
            subjectVariablesTableView.deselectAll(nil)
        }
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