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
        
        if let scriptData = scriptData, self.mainWindowController.initialized {
            scriptData.setUpInitialScriptState()
            self.isNewDocument = false
        } else {
            self.isNewDocument = true
        }
    }
    
    //MARK: NSDocument Overrides
    
    override func revert(toContentsOf inAbsoluteURL: URL, ofType inTypeName: String) throws {
        selectionController.preventRefresh = true
        try super.revert(toContentsOf: inAbsoluteURL, ofType: inTypeName)
        selectionController.preventRefresh = false
        //self.mainWindowController.layoutController.refresh()
        selectionController.refresh()
    }
    
    override func read(from absoluteURL: URL, ofType typeName: String) throws {
        if typeName == "DocumentType" {
            try super.read(from: absoluteURL, ofType: typeName)
        } else {
            do {
                scriptToImport = try String(contentsOf: absoluteURL, encoding: String.Encoding.utf8)
            } catch {
                scriptToImport = try String(contentsOf: absoluteURL, encoding: String.Encoding.macOSRoman)
            }
        }
    }
    
    override class var autosavesDrafts: Bool { return false }
    
    override func defaultDraftName() -> String { return "Experiment" }
    
    override class var autosavesInPlace: Bool { return true }
    
    override var windowNibName: String { return "Document" }
    
    override func makeWindowControllers() {
        //create scriptData and selectionController
        let pluginProvider = PSPluginSingleton.sharedInstance.createPluginProvider()
        self.scriptData = PSScriptData(docMoc: self.managedObjectContext!, pluginProvider: pluginProvider, document: self, selectionInterface: self.selectionController)
        self.selectionController.initialize(self, scriptData: scriptData)
        
        //make main window controller
        self.mainWindowController = PSMainWindowController(windowNibName: "Document")
        self.mainWindowController.initializeMainWindow(scriptData, document: self, selectionController: selectionController)
        
        self.addWindowController(mainWindowController)
        
        //register dragged types
        mainWindowController.window!.registerForDraggedTypes(convertToNSPasteboardPasteboardTypeArray([PSConstants.PSToolBrowserView.dragType]))
        mainWindowController.window!.minSize = NSSize(width: PSConstants.LayoutConstants.docMinWidth, height: PSConstants.LayoutConstants.docMinHeight)
        
        //store the window in a property for use by other objects
        if let mainWindow = mainWindowController.window {
            self.mainWindow = mainWindow
            //setup view options for window
            //mainWindow.titleVisibility = NSWindowTitleVisibility.Hidden
            mainWindow.titlebarAppearsTransparent = false
            mainWindow.isMovableByWindowBackground  = true
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
    
    //MARK: NSPersistentDocument Override
    
    override var managedObjectModel : NSManagedObjectModel! {
        // Creates if necessary and returns the managed object model for the application.
        if let mom = _managedObjectModel {
            return mom
        }
        
        let modelURL = Bundle(for:Entry.self).url(forResource: "Script", withExtension: "momd")
        
        _managedObjectModel = NSManagedObjectModel(contentsOf: modelURL!)
        _managedObjectModel!.kc_generateOrderedSetAccessors();
        return _managedObjectModel!
    }
    
    override func configurePersistentStoreCoordinator(for url: URL, ofType fileType: String, modelConfiguration configuration: String?, storeOptions: [String : Any]!) throws {
        var error: NSError! = NSError(domain: "Migrator", code: 0, userInfo: nil)
        //http://stackoverflow.com/questions/10001026/lightweight-migration-of-a-nspersistentdocument
        //options provide automatic data migration - for simple cases
        
        
        var newStoreOptions = storeOptions ?? [:]

        newStoreOptions[NSMigratePersistentStoresAutomaticallyOption] = true
        newStoreOptions[NSInferMappingModelAutomaticallyOption] = true
        var result : Bool
        do {
            try super.configurePersistentStoreCoordinator(for: url, ofType: fileType, modelConfiguration: configuration, storeOptions: newStoreOptions)
            result = true
        } catch let error1 as NSError {
            error = error1
            result = false
        }
        if result {
            return
        }
        throw error
    }
    
}

