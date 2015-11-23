//
//  PSEditMenusSubjectVariablesController.swift
//  PsyScopeEditor
//
//  Created by James on 23/11/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

//Seperate class to control to list subject variables to drag onto menu setup
class PSEditMenusSubjectVariablesController : NSObject, NSTableViewDataSource, NSTableViewDelegate {
    @IBOutlet var editMenusController : PSEditMenusController!
    @IBOutlet var tableView : NSTableView!
    @IBOutlet var segmentedControl : NSSegmentedControl!
    
    var subjectVariables : [PSSubjectVariable] = []
    
    @IBAction func segmentedControlClicked(_ : AnyObject) {
        switch segmentedControl.selectedSegment {
        case 0: break
        case 1: break
        default: break
        }
    }

    
    func refresh() {
        //get all subject variable
        let allSubjectVariables = PSSubjectInformation(scriptData: editMenusController.scriptData).allVariables
        
        //remove ones which are already in menu structure
        let subjectVariablesInMenu = editMenusController.menuStructure.getAllChildMenuDialogVariables().map({ $0.name})
        subjectVariables = allSubjectVariables.filter({ !subjectVariablesInMenu.contains($0.name)})
        
        //show the remainders
        tableView.reloadData()
    }
    
    //MARK: Datasource
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return subjectVariables.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        return subjectVariables[row].name
    }
    
    func tableView(tableView: NSTableView, setObjectValue object: AnyObject?, forTableColumn tableColumn: NSTableColumn?, row: Int) {
        subjectVariables[row].name = object as! String
    }
    
    //MARK: Delegate
}