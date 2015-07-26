//
//  Document.swift
//  PsyScopeEditor
//
//  Created by James on 11/07/2014.
//

import Cocoa


class Document: NSPersistentDocument {
    
    
    var isNewDocument : Bool = false
    var scriptData : PSScriptData!
    var _managedObjectModel: NSManagedObjectModel?
    var selectionController : PSSelectionController = PSSelectionController()
    var mainWindowController : PSMainWindowController!
    var mainWindow : NSWindow?
    var scriptToImport : String?
    
    //MARK: Initialization
    
    func setupInitialState() {
        self.isNewDocument = true
        if self.mainWindowController.initialized { scriptData.setUpInitialScriptState() }
    }
    
    //MARK: NSDocument Overrides
    
    override func revertToContentsOfURL(inAbsoluteURL: NSURL!, ofType inTypeName: String!) throws {
        try super.revertToContentsOfURL(inAbsoluteURL, ofType: inTypeName)
        self.mainWindowController.layoutController.refresh()
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
        //create scriptData and selectionController
        let pluginProvider = PSPluginSingleton.sharedInstance.createPluginProvider()
        self.scriptData = PSScriptData(docMoc: self.managedObjectContext, pluginProvider: pluginProvider, document: self, selectionInterface: self.selectionController)
        self.selectionController.initialize(self, scriptData: scriptData)
        
        //make main window controller
        self.mainWindowController = PSMainWindowController(windowNibName: "Document")
        self.mainWindowController.initializeMainWindow(scriptData, document: self, selectionController: selectionController)
        
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
            self.scriptData.window = mainWindow
        } else {
            fatalError("Couldn't create main window")
        }
        
        
        //create new experiment if necessary
        if isNewDocument { scriptData.setUpInitialScriptState() }
        
        
        
        //import script if there is one to import
        if let scriptToImport = scriptToImport {
            self.fileURL = nil
            self.fileType = self.autosavingFileType
            self.mainWindowController.scriptDelegate.importScript(scriptToImport)
        }
        
        scriptToImport = nil
        
        //begin listening for changes
        self.selectionController.registeredForChanges = true
        self.selectionController.refreshGUI()
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

