//
//  Document.swift
//  PsyScopeEditor
//
//  Created by James on 11/07/2014.
//

import Cocoa


class Document: NSPersistentDocument, NSSplitViewDelegate {
    
    
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
    
    
    override func revertToContentsOfURL(inAbsoluteURL: NSURL!, ofType inTypeName: String!) throws {
        
        
        defer { selectionController.listeningForDocMocChange = true }
        selectionController.listeningForDocMocChange = false
        
        scriptData.reset()
        try super.revertToContentsOfURL(inAbsoluteURL, ofType: inTypeName) //resets docmoc managedobjectcontext
    }
    
    var scriptData : PSScriptData {
        get {
            if _scriptData == nil {
                let pluginProvider = PSPluginSingleton.sharedInstance.createPluginProvider()
                _scriptData = PSScriptData(docMoc: self.managedObjectContext, pluginProvider: pluginProvider, document: self, window: self.window, selectionInterface: self.selectionController)
            }
            return _scriptData
        }
    }
    var _scriptData : PSScriptData!
    /*
    override func readFromURL(absoluteURL: NSURL!, ofType typeName: String!) throws {
        print("Loading: " + typeName)
        try super.readFromURL(absoluteURL, ofType: typeName)
    }
    
    override func writeToURL(url: NSURL, ofType typeName: String) throws {
        print("Saving: " + typeName)
        if typeName == "PsyX" {
            let script = PSScriptWriter(scriptData: scriptData).generatePsyScopeXScript()
            try script.writeToURL(url, atomically: true, encoding: NSUTF8StringEncoding)
        } else {
            try writeToURL(url, ofType: typeName)
        }
    }*/
    
    override func windowControllerDidLoadNib(aController: NSWindowController) {
      
        super.windowControllerDidLoadNib(aController)

        //register dragged types
        aController.window!.registerForDraggedTypes([PSConstants.PSToolBrowserView.dragType])
        aController.window!.minSize = NSSize(width: PSConstants.LayoutConstants.docMinWidth, height: PSConstants.LayoutConstants.docMinHeight)
        
        //store the window in a property for use by other objects
        _window = aController.window
        
        
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
        
        //create new experiment if necessary
        if isNewDocument { scriptData.setUpInitialScriptState() }
        
        
        //set up current tool bar selection
        toolbar.selectedItemIdentifier = layoutToolbarItem.itemIdentifier
        nibLoaded = true
        
        //setup view options for window
        window.titleVisibility = NSWindowTitleVisibility.Hidden
        window.titlebarAppearsTransparent = false
        window.movableByWindowBackground  = true
        //window.styleMask = window.styleMask | NSFullSizeContentViewWindowMask
    }
    
    override class func autosavesDrafts() -> Bool {
        return false
    }
    
    override func defaultDraftName() -> String {
        return "Experiment"
    }
    

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

    
    func importOldPsyScope(sender : AnyObject) {
        //open the file dialog
        let openPanel = NSOpenPanel()
        openPanel.title = "Choose a psyscope script"
        openPanel.showsResizeIndicator = true
        openPanel.showsHiddenFiles = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = true
        openPanel.allowsMultipleSelection = false
        //openPanel.allowedFileTypes = [fileType]
        openPanel.beginSheetModalForWindow(self.window, completionHandler: {
            (int_code : Int) -> () in
            if int_code == NSFileHandlingPanelOKButton {
                //relative to files location
                if let path = openPanel.URL {

                    var error : NSError?
                    var script: String?
                    do {
                        script = try String(contentsOfURL: path, encoding: NSUTF8StringEncoding)
                    } catch var error1 as NSError {
                        error = error1
                        script = nil
                    } catch {
                        fatalError()
                    }
                    if let s = script {
                        self.scriptDelegate.importScript(s)
                        return
                    }
                
                    do {
                        script = try String(contentsOfURL: path, encoding: NSMacOSRomanStringEncoding)
                    } catch var error1 as NSError {
                        error = error1
                        script = nil
                    } catch {
                        fatalError()
                    }
                    if let s = script {
                        self.scriptDelegate.importScript(s)
                        return
                    }
                }
                    
                PSModalAlert("Error opening text file")

            }
            return
        })
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


    var nibLoaded : Bool = false
    var isNewDocument : Bool = false
    func setupInitialState() {
        self.isNewDocument = true
        if nibLoaded { scriptData.setUpInitialScriptState() }
        
    }

    override class func autosavesInPlace() -> Bool {
        return true
    }

    override var windowNibName: String {
        return "Document"
    }
    
    @IBOutlet var middleView : NSView!
    
    func splitView(splitView: NSSplitView, shouldAdjustSizeOfSubview view: NSView) -> Bool {
        return (view == middleView)
    }
    
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
    var _managedObjectModel: NSManagedObjectModel? = nil
    
    var window : NSWindow {
        get {
            if _window == nil {
                let windowControllers = self.windowControllers as [NSWindowController]
                if windowControllers.count > 0 {
                    let controller = windowControllers[0] as NSWindowController
                    _window = controller.window
                } else  {
                    fatalError("No window controllers found!")
                }
            }
            return _window!
        }
    }
    
    var _window : NSWindow? = nil
    
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
                                
