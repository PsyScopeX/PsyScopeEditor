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
    @IBOutlet var selectedSubjectVariableController : PSSelectedSubjectVariableController!
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
    
    func entrySelected(entry: Entry?) {
        //propogate selection to tableview and to other controls
        for subjectVariable in subjectInformation.subjectVariables {
            if entry === subjectVariable.entry {
                selectedSubjectVariableController.setSelectedItem(subjectVariable)
                if (selectedSubjectTableView || !subjectInformation.groupVariables.contains(subjectVariable)) {
                    subjectInformationTableViewController.selectItem(subjectVariable)
                    return
                } else {
                    groupingVariablesTableViewController.selectItem(subjectVariable)
                    return
                }
            }
        }
        
        groupingVariablesTableView.deselectAll(nil)
        subjectVariablesTableView.deselectAll(nil)
    }
    
    func reloadData() {
        self.subjectInformation.updateVariablesFromScript()
        self.groupingVariablesTableViewController.reloadData(subjectInformation.groupVariables)
        self.subjectInformationTableViewController.reloadData(subjectInformation.subjectVariables)
        self.dataFileNameController.reloadData(subjectInformation.subjectVariables)
        self.dataFileNameController.updatePreviewTextView()
        self.selectedSubjectVariableController.refreshControls()
    }
    
    @IBAction func subjectVariablesSegmentedControlClick(segmentedControl : NSSegmentedControl) {
        switch(segmentedControl.selectedSegment) {
        case 0: // add
            subjectInformation.addNewVariable(false)
        case 1: // remove
            break
        default:
            break
        }
  
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