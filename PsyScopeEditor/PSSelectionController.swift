//
//  PSSelectionController.swift
//  PsyScopeEditor
//
//  Created by James on 06/11/2014.
//

import Foundation

//controls propogating the selection of objects to all the other controllers
//also handles deleteing of objects (which many controls need to know about)

//All deleteing of objects should be done through here, as it wil update the selection

class PSSelectionController : NSObject, PSSelectionInterface {
    let debugMocChanges = false
    
    var document : Document!
    var scriptData : PSScriptData!
    var windowViews : [PSWindowViewInterface] = []
    var menu : NSMenu!
    
    var docMocChangesPending : Bool = false
    var preventRefresh : Bool = false
    
    func initialize(document : Document, scriptData : PSScriptData) {
        self.document = document
        self.scriptData = scriptData
    }
    
    var registeredForChanges : Bool = false {
        willSet {
            if newValue != registeredForChanges {
                if newValue {
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: "docMocChanged:", name: NSManagedObjectContextObjectsDidChangeNotification, object: scriptData.docMoc)
                } else {
                    NSNotificationCenter.defaultCenter().removeObserver(self)
                }
            }
        }
    }
    
    func registerSelectionInterface(interface : PSWindowViewInterface) {
        windowViews.append(interface)
    }
    
    func refresh() {
        
        if docMocChangesPending {  //only refresh if there are actual changes pending
        
            //detect whether selected object has been deleted, if so deselect
            let haveACurrentlySelectedEntry = selectedEntry != nil
            if haveACurrentlySelectedEntry && (selectedEntry!.deleted == true || selectedEntry!.name == nil) {
                selectEntry(nil)
            } else {
                refreshGUI()
            }
            
            docMocChangesPending = false
        }

        
    }
    
    
    
    func docMocChanged(notification : NSNotification) {
        docMocChangesPending = true
        if (debugMocChanges) { dumpDocMocChanges(notification) }
        if scriptData.inUndoGroup  {
            //prevent doc moc changes for grouped changes
            print("Doc moc changed: In undo group so not refreshing")
            return
        } else {
            print("Doc moc changed: Refreshing")
            refresh()
        }
        
    }
    
    
    
    //the entry for currently selected object
    var selectedEntry : Entry? = nil
    
    func getSelectedEntry() -> Entry? {
        return selectedEntry
    }
    
    //general method for selecting an object
    func selectEntry(entry : Entry?) {
        selectedEntry = entry
        document.mainWindowController.selectEntry(entry)
        refreshGUI()
    }
    
    //for double click action
    func doubleClickEntry(entry : Entry) {
        if selectedEntry != entry {
            selectEntry(entry)
        }
        document.mainWindowController.doubleClickEntry(entry)
    }
    
    
    func deleteObject(layoutObject : LayoutObject) {
        var new_entry_selection : Entry? = nil
        if layoutObject == selectedEntry?.layoutObject {
            //try to select a sibling
            let parents = layoutObject.parentLink as! Set<LayoutObject>
            for par in parents {
                let siblings = par.childLink.array as! [LayoutObject]
                
                for sib in siblings {
                    if sib != layoutObject {
                        new_entry_selection = sib.mainEntry
                        break
                    }
                }
                if (new_entry_selection != nil) { break }
            }
        } else {
            //no need to change selection
            new_entry_selection = selectedEntry
        }
        
        //otherwise just select a random one
        if new_entry_selection == nil {
            new_entry_selection = scriptData.getBaseEntries()[0]
        }
        
        //call main routine
        deleteObject(layoutObject, andSelect: new_entry_selection)
    }
    func deleteObject(layoutObject: LayoutObject, andSelect newSelection: Entry?) {
        
        if layoutObject == newSelection {
            fatalError("You cannot select the object about to be deleted")
        }
        
        //if the object was selected, select another one before
        let old_selection = selectedEntry
        
        selectEntry(newSelection)
        
        //delete the object
        if let pstool = PSPluginSingleton.sharedInstance.getPlugin(layoutObject.mainEntry.type) {
            scriptData.beginUndoGrouping("Delete Object")
            
            let mainEntry = layoutObject.mainEntry
            let success = pstool.deleteObject(mainEntry, withScript: scriptData)
            scriptData.endUndoGrouping(success)
            if (success) {

                for interface in windowViews {
                    interface.entryDeleted(mainEntry)
                }
                
                //check if it was the selected entry that was deleted
                if selectedEntry?.layoutObject == nil {
                    //select a random object
                    var objects = scriptData.getLayoutObjects()
                    if objects.count >= 1 {
                        selectEntry(objects[0].mainEntry) //triggers the correct filling in of the attributes browser
                    }
                    
                }
            } else {
                //show dialog to say object cannot be deleted
                if let os = old_selection {
                    selectEntry(os)
                }
                PSModalAlert("You cannot delete this type of object.")
            }
            
        }
    }
    
    //called when selection is made in attribute browser
    //action: layout object associated with base entry of the given name, and selects it
    func selectObjectForEntryNamed(selectedItem : String) {
        
        let all_entries = scriptData.getBaseEntries()
        for e in all_entries {
            if e.name == selectedItem {
                selectEntry(e)
            }
        }
    }
    
    
    func refreshGUI() {
        //print("Refresh")
        if !preventRefresh {
            buildEventActionsAttributeAndMetaData() //must be done at start of refresh
            updateVaryByMenu() //perhaps this doesn't belong here?
        
            document.mainWindowController.refreshGUI()

            for interface in windowViews {
                interface.refresh()
            }
        }
    }
    
    func updateVaryByMenu() {
        let new_menu = NSMenu()
        
        let define = NSMenuItem()
        define.title = "Define Value"
        define.keyEquivalent = "d"
        define.tag = 1
        
        let enterFormula = NSMenuItem()
        enterFormula.title = "Enter Formula"
        enterFormula.keyEquivalent = "f"
        enterFormula.tag = 2
        
        let vary = NSMenuItem()
        vary.title = "Vary value"
        vary.keyEquivalent = "v"
        
        new_menu.addItem(define)
        new_menu.addItem(enterFormula)
        new_menu.addItem(vary)
        
        let vary_menu = NSMenu()
        vary.submenu = vary_menu
        
        for (_,source) in scriptData.pluginProvider.attributeSourceTools {
            let tool = source as PSToolInterface
            if tool.isSourceForAttributes() {
                vary_menu.addItem(tool.constructAttributeSourceSubMenu(scriptData))
            }
        }
        
        menu = new_menu
    }
    
    func varyByMenu() -> NSMenu {
        return menu
    }
    
    //MARK: Event Actions / Conditions
    
    var actionsAttribute : PSEventActionsAttribute?
    var actionsAttributeViewData : [PSActionBuilderViewMetaDataSet]?
    
    func buildEventActionsAttributeAndMetaData() {
        if let e = selectedEntry {
            
            var attributeName = ""
            if e.metaData == "TrialActions" || e.metaData == "EventActions" {
                attributeName = e.metaData
            } else {
                if let _ = scriptData.getSubEntry("TrialActions", entry: e) {
                    attributeName = "TrialActions"
                } else if let _ = scriptData.getSubEntry("EventActions", entry: e) {
                    attributeName = "EventActions"
                } else {
                    attributeName = e.type == "Template" ? "TrialActions" : "EventActions"
                }
            }
            
            
            
            let newActionsAttribute = PSEventActionsAttribute(event_entry: e, scriptData: scriptData, attributeName: attributeName)
            self.actionsAttribute = newActionsAttribute
            
            
            
            //work out cell heights and expandedness here
            self.actionsAttributeViewData = PSActionConditionViewMetaData(newActionsAttribute)
        } else {
            self.actionsAttribute = nil
            self.actionsAttributeViewData = nil
        }

    }
    
    func getEventActionsAttribute() -> PSEventActionsAttribute? {
        return self.actionsAttribute
    }
    
    //returns view meta data for event actions (used by same controls as eventActionsAttribute)
    func getActionConditionViewMetaData() -> [PSActionBuilderViewMetaDataSet]? {
        return self.actionsAttributeViewData
    }
    
    func dumpDocMocChanges(notification : NSNotification) {
        let keys_to_check : [NSString] = [NSInsertedObjectsKey, NSUpdatedObjectsKey, NSDeletedObjectsKey, NSRefreshedObjectsKey, NSInvalidatedObjectsKey, NSInvalidatedAllObjectsKey];
        for key in keys_to_check {
            if let objects: AnyObject = notification.userInfo![key] {
                var array : NSArray = []
                if let set = objects as? NSSet {
                    print("Doc Moc changed: \(key) type, set with \(set.count) objects.")
                    array = set.allObjects
                } else if let arr = objects as? NSArray {
                    print("Doc Moc changed: \(key) type, array with \(arr.count) objects.")
                    array = arr
                }
                
                print(array.description)
            }
        }
    }
    
}