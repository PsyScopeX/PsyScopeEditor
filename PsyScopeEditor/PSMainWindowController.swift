//
//  PSMainWindowController.swift
//  PsyScopeEditor
//
//  Created by James on 24/07/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

//
class PSMainWindowController : NSWindowController, NSWindowDelegate {
    
    //MARK: Outlets
    @IBOutlet var toolbar : NSToolbar!
    @IBOutlet var tabController : PSDocumentTabDelegate!
    @IBOutlet var objectToolbarDelegate : PSToolBrowserViewDelegate!
    @IBOutlet var eventToolbarDelegate : PSEventBrowserViewDelegate!
    @IBOutlet var actionsBrowser : PSActionsBrowser!
    @IBOutlet var scriptDelegate : PSScriptViewDelegate!
    
    @IBOutlet var layoutController : LayoutController!
    @IBOutlet var entryBrowser : PSEntryBrowser!
    @IBOutlet var errorHandler : PSScriptErrorViewController!
    @IBOutlet var entryBrowserSearchController : PSEntryBrowserSearchController!
    @IBOutlet var variableSelector : PSVariableSelector!
    @IBOutlet var experimentSetup : PSExperimentSetup!


    @IBOutlet var attributesBrowser : PSAttributesBrowser!
    @IBOutlet var layoutObjectComboBox : PSLayoutObjectComboBox!
    
    var mainDocument : Document!
    var scriptData : PSScriptData!
    var selectionController : PSSelectionController!
    var initialized : Bool = false
    
    //MARK: Initialization
    
    func initializeMainWindow(scriptData : PSScriptData, document : Document, selectionController : PSSelectionController) {
        
        if initialized { fatalError("Trying to initialise main window twice") }
        
        self.mainDocument = document
        self.scriptData = scriptData
        self.selectionController = selectionController
    
        
        initialized = true
        
    }
    
    override func windowDidLoad() {
        //initialize and setup all documents
        layoutController.initialize()
        experimentSetup.initialize()
        objectToolbarDelegate.setup(scriptData.pluginProvider)
        eventToolbarDelegate.setup(scriptData.pluginProvider)
        actionsBrowser.setup(scriptData)
        scriptDelegate.setup(scriptData)
        entryBrowser.setup(scriptData)
        entryBrowserSearchController.setup(scriptData)
        
        tabController.initialize() //must be last

    }
    
    
    func refreshGUI() {
        tabController.refresh() //sends refresh to property controllers
        layoutController.refresh()
        layoutObjectComboBox.refresh()
        experimentSetup.update()
        actionsBrowser.refresh()
        entryBrowser.update()
        attributesBrowser.refresh()
        attributesBrowser.refresh()
        variableSelector.update()
        scriptDelegate.scriptHasHadObjectUpdates()
    }
    
    func selectEntry(entry : Entry?) {
        layoutController.selectEntry(entry)
        scriptDelegate.selectEntry(entry)
        experimentSetup.entrySelected()
    }
    
    //for double click action
    func doubleClickEntry(entry : Entry) {
        tabController.showProperties()
        tabController.doubleClickProperties()
    }
    
    //MARK: NSWindowController overrides
    
    override var shouldCloseDocument: Bool {
        get {
            return true
        }
        set {}
    }
    
    //MARK: Menu methods
    
    func runExperiment(sender : AnyObject){
        
        if errorHandler.errors.count != 0 {
            PSModalAlert("Must fix parsing errors (or update script) before running script!")
            return
        }
        
        errorHandler.reset()
        //validate the script
        let tools : [PSToolInterface] = PSPluginSingleton.sharedInstance.toolObjects.values.array
        let events : [PSToolInterface] = PSPluginSingleton.sharedInstance.eventObjects.values.array
        let plugins = tools + events
        
        for plugin in plugins {
            
            let errors : [AnyObject] =  plugin.validateBeforeRun(scriptData)
            for error in errors {
                if let err = error as? PSScriptError {
                    errorHandler.newError(err)
                }
            }
        }
        
        if errorHandler.errors.count == 0 {
            //RUN
            PSPsyScopeXRunner.sharedInstance.runThisScript(self.mainDocument)
        } else {
            PSModalAlert("Errors were found during validation of script!")
            errorHandler.presentErrors()
        }
    }
    
    func cleanUpLayout(sender : AnyObject) {
        PSCleanUpTree(scriptData)
    }
    
    func developerMenuItem(sender : NSMenuItem) {
        switch (sender.tag) {
        case 0:
            //restart application engine
            
            break
        case 1:
            //kill application engine
            
            break
        default:
            break
        }
    }
    
    //MARK: Custom field editor
    
    lazy var customFieldEditor : PSFieldEditor = {
       let fieldEditor = PSFieldEditor(frame: NSZeroRect)
        fieldEditor.fieldEditor = true
        fieldEditor.setup(self.scriptData)
        return fieldEditor
    }()
    
    func windowWillReturnFieldEditor(sender: NSWindow, toObject client: AnyObject?) -> AnyObject? {
        if let client = client as? PSEntryValueTextField {
            return customFieldEditor
        } else {
            return nil
        }
    }
    
}