//
//  PSExperimentSetup.swift
//  PsyScopeEditor
//
//  Created by James on 15/06/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

/*
 * PSExperimentSetup: Loaded in Document.xib.  Initialized by PSMainWindowController, which loads the ExperimentSetup.xib.
 * Later PSDocumentTabDelegate adds the loaded views into the correct tabViews.
 */
class PSExperimentSetup: NSObject {
    
    //MARK: Outlets
    
    @IBOutlet var mainWindowController : PSMainWindowController!
    @IBOutlet var subjectVariablesController: PSSubjectVariablesController!
    @IBOutlet var midPanelView : NSView!
    @IBOutlet var groupTableViewController : PSGroupsTableViewController!

    //MARK: Variables
    
    var selectionInterface : PSSelectionInterface!
    var topLevelObjects : NSArray?
    var scriptData : PSScriptData!
    var templateEntry : Entry!
    
    //MARK: Setup
    
    func initialize() {
        self.scriptData = mainWindowController.scriptData
        self.selectionInterface = self.scriptData.selectionInterface
        //load nib and gain access to views
        Bundle(for:type(of: self)).loadNibNamed("ExperimentSetup", owner: self, topLevelObjects: &topLevelObjects)
        self.groupTableViewController.setup(mainWindowController.scriptData)
    }
    
    
    //MARK: PSDocumentTabDelegate
    
    func identifier() -> String! {
        return "ExperimentSetup"
    }
    
    //returns a new tabview item for the central panel
    func midPanelTab() -> NSTabViewItem! {
        let tabViewItem = NSTabViewItem(identifier: "ExperimentWindow")
        tabViewItem.view = midPanelView
        return tabViewItem
    }
    
    //MARK: PSSelectionController
    
    func update() {
        subjectVariablesController.reloadSubjectVariablesData()
        self.groupTableViewController.refreshView()
    }
    
    func selectEntry(_ entry : Entry?) {
        selectionInterface.selectEntry(entry)
    }
    
    func entrySelected() {
        subjectVariablesController.entrySelected()
    }
    
}
