//
//  Document.swift
//  PsyScopeEditor
//
//  Created by James on 11/07/2014.
//

import Cocoa


class Document: NSPersistentDocument, NSSplitViewDelegate {
    
    //MARK: Outlets
    @IBOutlet var middleView : NSView!
    @IBOutlet var toolbar : NSToolbar!
    @IBOutlet var layoutToolbarItem : NSToolbarItem!
    @IBOutlet var tabController : PSDocumentTabDelegate!
    @IBOutlet var objectToolbarDelegate : PSToolBrowserViewDelegate!
    @IBOutlet var eventToolbarDelegate : PSEventBrowserViewDelegate!
    @IBOutlet var actionsBrowser : PSActionsBrowser!
    @IBOutlet var scriptDelegate : PSScriptViewDelegate!
    
    @IBOutlet var attributeTabView : NSTabView!
    @IBOutlet var layoutController : LayoutController!
    @IBOutlet var selectionController : PSSelectionController!
    @IBOutlet var entryBrowser : PSEntryBrowser!
    @IBOutlet var errorHandler : PSScriptErrorViewController!
    @IBOutlet var entryBrowserSearchController : PSEntryBrowserSearchController!
    @IBOutlet var variableSelector : PSVariableSelector!
    @IBOutlet var experimentSetup : PSExperimentSetup!
    
    var nibLoaded : Bool = false
    var isNewDocument : Bool = false
    var _scriptData : PSScriptData!
    var _managedObjectModel: NSManagedObjectModel?
    var mainWindow : NSWindow?
    var scriptToImport : String?
    
    //MARK: ScriptData
    
    var scriptData : PSScriptData {
        get {
            if _scriptData == nil {
                let pluginProvider = PSPluginSingleton.sharedInstance.createPluginProvider()
                _scriptData = PSScriptData(docMoc: self.managedObjectContext, pluginProvider: pluginProvider, document: self, window: self.window, selectionInterface: self.selectionController)
            }
            return _scriptData
        }
    }
    
    
    //MARK: Initialization
        
    func initializeMainWindow() {
        //create new experiment if necessary
        if isNewDocument { scriptData.setUpInitialScriptState() }
        
        
        
        
        //initialize and setup all documents
        layoutController.initialize()
        experimentSetup.initialize()
        objectToolbarDelegate.setup(scriptData.pluginProvider)
        eventToolbarDelegate.setup(scriptData.pluginProvider)
        actionsBrowser.setup(scriptData)
        scriptDelegate.setup(scriptData)
        entryBrowser.setup(scriptData)
        entryBrowserSearchController.setup(scriptData)
        variableSelector.setup(scriptData)
        
        tabController.initialize() //must be second to last
        selectionController.initialize() //must be last
        
        
        
        
        //set up current tool bar selection
        toolbar.selectedItemIdentifier = layoutToolbarItem.itemIdentifier
        nibLoaded = true
        
        
        
        //import script if there is one to import
        if let scriptToImport = scriptToImport {
            self.fileURL = nil
            self.fileType = self.autosavingFileType
            scriptDelegate.importScript(scriptToImport)
            
        }
        
        scriptToImport = nil
    }
    
    func setupInitialState() {
        self.isNewDocument = true
        if nibLoaded { scriptData.setUpInitialScriptState() }
        
    }
    
    //MARK: NSDocument Overrides
    
    override func revertToContentsOfURL(inAbsoluteURL: NSURL!, ofType inTypeName: String!) throws {
        try super.revertToContentsOfURL(inAbsoluteURL, ofType: inTypeName)
        layoutController.refresh()
    }
    
    override func readFromURL(absoluteURL: NSURL!, ofType typeName: String!) throws {
        
        if typeName == "DocumentType" {
            try super.readFromURL(absoluteURL, ofType: typeName)
        } else if let path = absoluteURL {
            scriptToImport = try String(contentsOfURL: path, encoding: NSUTF8StringEncoding)
        }
    }
    
    override class func autosavesDrafts() -> Bool { return false }
    
    override func defaultDraftName() -> String { return "Experiment" }
    
    override class func autosavesInPlace() -> Bool { return true }
    
    override var windowNibName: String { return "Document" }
    
    override func makeWindowControllers() {
        //make main window controller
        let mainWindowController = NSWindowController(windowNibName: "Document", owner: self)
        self.addWindowController(mainWindowController)
        
        //register dragged types
        mainWindowController.window!.registerForDraggedTypes([PSConstants.PSToolBrowserView.dragType])
        mainWindowController.window!.minSize = NSSize(width: PSConstants.LayoutConstants.docMinWidth, height: PSConstants.LayoutConstants.docMinHeight)
        
        //store the window in a property for use by other objects
        if let mainWindow = mainWindowController.window {
            self.mainWindow = mainWindow
            //setup view options for window
            mainWindow.titleVisibility = NSWindowTitleVisibility.Hidden
            mainWindow.titlebarAppearsTransparent = false
            mainWindow.movableByWindowBackground  = true
            //window.styleMask = window.styleMask | NSFullSizeContentViewWindowMask
        } else {
            fatalError("Couldn't create main window")
        }
        
        initializeMainWindow()
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
            PSPsyScopeXRunner.sharedInstance.runThisScript(self)
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
    
    
    //MARK: Split view
    
    func splitView(splitView: NSSplitView, shouldAdjustSizeOfSubview view: NSView) -> Bool {
        return (view == middleView)
    }
    
    
    //MARK: Window
    
    var window : NSWindow {
        get {
            return mainWindow!
        }
    }
    
    
    
    //MARK: NSPersistentDocument Override
    
    override var managedObjectModel : AnyObject! {
        // Creates if necessary and returns the managed object model for the application.
        if let mom = _managedObjectModel {
            return mom
        }
        
        let modelURL = NSBundle(forClass:Entry.self).URLForResource("Script", withExtension: "momd")
        
        _managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL!)
        _managedObjectModel!.kc_generateOrderedSetAccessors();
        return _managedObjectModel!
    }
    
    override func configurePersistentStoreCoordinatorForURL(url: NSURL!, ofType fileType: String!, modelConfiguration configuration: String?, storeOptions: [String : AnyObject]!) throws {
        var error: NSError! = NSError(domain: "Migrator", code: 0, userInfo: nil)
        //http://stackoverflow.com/questions/10001026/lightweight-migration-of-a-nspersistentdocument
        //options provide automatic data migration - for simple cases
        
        
        var newStoreOptions = storeOptions
        
        if newStoreOptions == nil { newStoreOptions = [:] }
        newStoreOptions[NSMigratePersistentStoresAutomaticallyOption] = true
        newStoreOptions[NSInferMappingModelAutomaticallyOption] = true
        var result : Bool
        do {
            try super.configurePersistentStoreCoordinatorForURL(url, ofType: fileType, modelConfiguration: configuration, storeOptions: newStoreOptions)
            result = true
        } catch var error1 as NSError {
            error = error1
            result = false
        }
        if result {
            return
        }
        throw error
    }
    
}

