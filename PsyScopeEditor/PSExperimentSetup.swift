//
//  PSExperimentSetup.swift
//  PsyScopeEditor
//
//  Created by James on 15/06/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSExperimentSetup: NSObject {
    
    //MARK: Outlets
    @IBOutlet var document : Document!
    @IBOutlet var selectionInterface : PSSelectionController!
    @IBOutlet var subjectVariablesController: PSSubjectVariablesController!
    @IBOutlet var midPanelView : NSView!
    @IBOutlet var leftPanelView : NSView!
    @IBOutlet var selectedSubjectController : PSSelectedSubjectVariableController!
    
    
    var topLevelObjects : NSArray?
    var scriptData : PSScriptData!
    var templateEntry : Entry!
    
    func initialize() {
        self.scriptData = document.scriptData
        //load nib and gain access to views
        NSBundle(forClass:self.dynamicType).loadNibNamed("ExperimentSetup", owner: self, topLevelObjects: &topLevelObjects)
    }
    
    func update() {
        subjectVariablesController.reloadData()
    }
    
    func identifier() -> String! {
        return "ExperimentSetup"
    }
    
    
    //returns a new tabview item for the central panel
    func midPanelTab() -> NSTabViewItem! {
        let tabViewItem = NSTabViewItem(identifier: "ExperimentWindow")
        tabViewItem.view = midPanelView
        return tabViewItem
    }
    
    //returns a left panel item
    func leftPanelTab() -> NSTabViewItem! {
        let tabViewItem = NSTabViewItem(identifier: "ExperimentSetupTools")
        tabViewItem.view = leftPanelView
        return tabViewItem
    }
    
    func selectEntry(entry : Entry) {
        selectionInterface.selectEntry(entry)
    }
    
    func entrySelected(entry: Entry?) {
        subjectVariablesController.entrySelected(entry)
    }
    
    func entryDeleted(entry: Entry!) { }
    
    func type() -> String! {
        return "TemplateBuilder"
    }
    
}