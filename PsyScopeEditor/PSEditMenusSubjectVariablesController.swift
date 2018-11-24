//
//  PSEditMenusSubjectVariablesController.swift
//  PsyScopeEditor
//
//  Created by James on 23/11/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

/*
 * PSEditMenusSubjectVariablesController: Loaded in EditMenus.xib.  Seperate class to control to list subject variables to drag onto menu setup
 */
class PSEditMenusSubjectVariablesController : NSObject, NSTableViewDataSource, NSTableViewDelegate {
    
    //MARK: Outlets
    
    @IBOutlet var editMenusController : PSEditMenusController!
    @IBOutlet var tableView : NSTableView!
 
    //MARK: Variables
    
    var subjectVariables : [PSSubjectVariable] = []
    
    //MARK: Constants
    
    static let subjectVariableType : String = "PSSubjectVariable"
    

    //MARK: Refresh
    
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
    func numberOfRows(in tableView: NSTableView) -> Int {
        return subjectVariables.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return subjectVariables[row].name
    }
    
    func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        subjectVariables[row].name = object as! String
    }
    
    //MARK: Delegate
    
    func tableView(_ tableView: NSTableView, writeRowsWith rowIndexes: IndexSet, to pboard: NSPasteboard) -> Bool {
        // Copy the subjectVariableNames
        let subjectVariableNames : [String] = rowIndexes.enumerated().map({ subjectVariables[$0.element].name })
        let data = NSKeyedArchiver.archivedData(withRootObject: subjectVariableNames)
        pboard.declareTypes(convertToNSPasteboardPasteboardTypeArray([PSEditMenusSubjectVariablesController.subjectVariableType]), owner: self)
        pboard.setData(data, forType: convertToNSPasteboardPasteboardType(PSEditMenusSubjectVariablesController.subjectVariableType))
        return true
    }
}

