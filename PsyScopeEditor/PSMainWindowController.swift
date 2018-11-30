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
    @IBOutlet var toolBrowserController : PSToolBrowserController!
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
    
    func initializeMainWindow(_ scriptData : PSScriptData, document : Document, selectionController : PSSelectionController) {
        
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
        toolBrowserController.setup(scriptData.pluginProvider)
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
    
    func selectEntry(_ entry : Entry?) {
        layoutController.selectEntry(entry)
        scriptDelegate.selectEntry(entry)
        experimentSetup.entrySelected()
    }
    
    //for double click action
    func doubleClickEntry(_ entry : Entry) {
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
    
    func showScript(_ sender : AnyObject) {
        print("SHOWSCIRPT")
        tabController.showScript()
    }
    
    func runExperiment(_ sender : AnyObject){
        
        if errorHandler.errors.count != 0 {
            PSModalAlert("Must fix parsing errors (or update script) before running script!")
            return
        }
        
        errorHandler.reset()
        //validate the script
        let tools : [PSToolInterface] = Array(PSPluginSingleton.sharedInstance.toolObjects.values)
        let events : [PSToolInterface] = Array(PSPluginSingleton.sharedInstance.eventObjects.values)
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
    
    func cleanUpLayout(_ sender : AnyObject) {
        PSCleanUpTree(scriptData)
    }
    
    func developerMenuItem(_ sender : NSMenuItem) {
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
    
    func inputDevicesMenuItem(_ sender : NSMenuItem) {
        let types : [String] = scriptData.pluginProvider.conditionPlugins.values.filter( {
            return $0.isInputDevice()
        }).map({
            return $0.type()
        })
        
        let checkBoxStrings : [(String,String)] =  types.map({
            return ($0,$0)
        })
        
        //get current value
        let experimentEntry = scriptData.getMainExperimentEntry()
        let inputDevices = scriptData.getSubEntry("InputDevices", entry: experimentEntry)
        
        let currentValue = inputDevices == nil ? .null : PSGetListElementForString(inputDevices!.currentValue)
        let popup = PSCheckBoxListAttributePopup(currentValue: currentValue, displayName: "InputDevices", checkBoxStrings: checkBoxStrings, setCurrentValueBlock: {(newValue : PSEntryElement) in
            
            self.scriptData.beginUndoGrouping("Edit Input Devices")
            let id = self.scriptData.getOrCreateSubEntry("InputDevices", entry: experimentEntry, isProperty: true)
            id.currentValue = newValue.stringValue()
            
            let stringListValues = PSGetEntryElementAsStringList(newValue).getStrippedStringValues()
            
            for type in types {
                let on = stringListValues.contains(type)
                self.scriptData.pluginProvider.conditionPlugins[type]?.turnInputDeviceOn(on, scriptData: self.scriptData)
            }
            
            self.scriptData.endUndoGrouping()
        
        })
        popup.showAttributeModalForWindow(scriptData.window)
    }
    
    func detachCurrentWindow(_ sender : NSMenuItem) {
        tabController.detachCurrentWindow()
    }
    
    //MARK: Custom field editor
    
    lazy var customFieldEditor : PSFieldEditor = {
       let fieldEditor = PSFieldEditor(frame: NSZeroRect)
        fieldEditor.isFieldEditor = true
        fieldEditor.setup(self.scriptData)
        return fieldEditor
    }()
    
    func windowWillReturnFieldEditor(_ sender: NSWindow, to client: Any?) -> Any? {
        if (client as? PSEntryValueTextField) != nil {
            return customFieldEditor
        } else {
            return nil
        }
    }
    
}
