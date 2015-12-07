//
//  PsyScopeScriptController.swift
//  PsyScopeEditor
//
//  Controller for PSLayoutBoard - controls the conversion of LayoutObjects to graphical display, and actions from the gui to the core-data model

import Cocoa
import QuartzCore

var PSCopiedEntry : Entry?
let PSPasteboardTypeLayoutObject = "psyscope.layoutobject"

class PSLayoutItem : NSObject {
    var icon : CALayer! = nil
    var text : CATextLayer! = nil
}

//Acts as controller between core data and layoutboard
class LayoutController: NSObject, NSPasteboardItemDataProvider {
    
    var objectsTolayoutItems : [LayoutObject : PSLayoutItem] = [:]  //converts LayoutObjects to layoutItem on layoutboard
    var layoutItemsToObjects : [PSLayoutItem : LayoutObject] = [:]  //converts layoutItems on layout board to LayoutObjects
    
    //the currently selected object
    var selectedObject : LayoutObject? = nil
    
    var convertEventsController : PSConvertEvents!
    
    //general method for selecting an object
    func selectEntry(entry : Entry?) {
        if let e = entry, lobject = e.layoutObject, layoutItem = objectsTolayoutItems[lobject] {
            selectedObject = lobject
            layoutBoard.highlightLayoutItem(layoutItem)
        } else {
            selectedObject = nil
            layoutBoard.highlightLayoutItem(nil)
        }
    }
    
    @IBOutlet var layoutBoard : PSLayoutBoard!
    @IBOutlet var mainWindowController : PSMainWindowController!
    
    var scriptData : PSScriptData!
    var selectionController : PSSelectionController!

    func initialize() {
        selectionController = mainWindowController.selectionController
        scriptData = mainWindowController.scriptData
        layoutBoard.prepareMainLayer() //must be done first
        refresh()

        //show or hide events and lists depending on setting
        eventsHidden = !NSUserDefaults.standardUserDefaults().boolForKey(PSPreferences.showEvents.key)
        listsHidden = !NSUserDefaults.standardUserDefaults().boolForKey(PSPreferences.showLists.key)
        hideShowEvents()
        hideShowLists()
    }
    
    func refresh() {
        
        let layoutObjects = scriptData.getLayoutObjects()
        
        //update views (position them / delete display them)
        for layoutObject in layoutObjects {
            updateViewForObject(layoutObject)
        }
    
        //update links (has to be done after layoutObjects updated)
        for layoutObject in layoutObjects {
            updateViewsForLinks(layoutObject)
        }
        
        //update selection
        if let se = selectionController.selectedEntry, _ = se.layoutObject {
            selectEntry(se)
        }
        
        //remove non-existent layoutObjects
        for layoutObject in Array(objectsTolayoutItems.keys) {
            if !layoutObjects.contains(layoutObject) {
                deleteObject(layoutObject)
            }
        }
    }
    
    
    @IBOutlet var showHideEventsButton : NSButton!
    var eventsHidden : Bool = false
    @IBAction func hideEvents(sender : AnyObject) {
        //tooggle
        eventsHidden = !eventsHidden
        hideShowEvents()
    }
    
    @IBOutlet var showHideListsButton : NSButton!
    var listsHidden : Bool = false
    @IBAction func hideLists(sender : AnyObject) {
        listsHidden = !listsHidden
        hideShowLists()
    }
    
    func hideShowLists() {
        
        if listsHidden {
            showHideListsButton.title = "Show Lists"
            showHideListsButton.state = 1
        } else {
            showHideListsButton.title = "Hide Lists"
            showHideListsButton.state = 0
        }
        
        NSUserDefaults.standardUserDefaults().setBool(!listsHidden, forKey: PSPreferences.showLists.key)
       
        
        for object in objectsTolayoutItems.keys {
            if object.mainEntry.type == "List" {
                layoutBoard.hideLayoutItem(objectsTolayoutItems[object]!, hidden: listsHidden)
            }
        }
    }
    
    func hideShowEvents() {
    
        if eventsHidden {
            showHideEventsButton.title = "Show Events"
            showHideEventsButton.state = 1
        } else {
            showHideEventsButton.title = "Hide Events"
            showHideEventsButton.state = 0
        }
        
        NSUserDefaults.standardUserDefaults().setBool(!eventsHidden, forKey: PSPreferences.showEvents.key)
        
        for object in objectsTolayoutItems.keys {
            if PSPluginSingleton.sharedInstance.typeIsEvent(object.mainEntry.type) {
                layoutBoard.hideLayoutItem(objectsTolayoutItems[object]!, hidden: eventsHidden)
            }
        }
    }

    
//methods which update the PSLayoutBoard and Attributes Browser

    func deleteObject(lobject : LayoutObject) {
        //println("Object has been deleted - removing sublayoutItem")
        //object has been deleted, so update layoutboard and pointers
        let sublayoutItem = objectsTolayoutItems[lobject]
        objectsTolayoutItems[lobject] = nil
        if let sl = sublayoutItem {
            layoutItemsToObjects[sl] = nil
            layoutBoard.removeObjectLayoutItem(sl) //this routine also deletes all link layoutItems
        }

    }
    
    //given an object, update the view for it (or create view if not present
    func updateViewForObject(object : LayoutObject) {
        
        var sublayoutItem : PSLayoutItem? = objectsTolayoutItems[object]
    
        if (sublayoutItem == nil) {
                //object has not been instantiated on layoutBoard
                if let icon = PSPluginSingleton.sharedInstance.getIconForType(object.mainEntry.type) {
                    object.icon = icon
                    sublayoutItem = layoutBoard.makeObjectLayoutItem(icon, name: object.mainEntry.name)
                    objectsTolayoutItems[object] = sublayoutItem
                    layoutItemsToObjects[sublayoutItem!] = object
                } else {
                    fatalError("Error, icon not found for type \(object.mainEntry.type)")
                }  
        }
            
        if object.mainEntry != nil {
            layoutBoard.updateObjectLayoutItem(sublayoutItem!, x: object.xPos.integerValue, y: object.yPos.integerValue, name: object.mainEntry.name)
        } else {
            //this has been deleted!
            deleteObject(object)
        }
        
    }
    
    func updateViewsForLinks(object : LayoutObject) {
 
        let sublayoutItem = objectsTolayoutItems[object]

        if (sublayoutItem != nil) {
            let childLinklayoutItems : [PSLayoutItem] = (object.childLink.array as! [LayoutObject]).map({
                ( obj) -> PSLayoutItem in
                let obj2 = obj as LayoutObject
                let output : PSLayoutItem! = self.objectsTolayoutItems[obj2]
                return output})
            
            let parentLinklayoutItems : [PSLayoutItem] = Array(object.parentLink as! Set<LayoutObject>).map({
                ( obj) -> PSLayoutItem in
                let obj2 = obj as LayoutObject
                let output : PSLayoutItem! = self.objectsTolayoutItems[obj2]
                return output})
            
            layoutBoard.updateChildLinks(sublayoutItem!, childLayoutItems: childLinklayoutItems)
            layoutBoard.updateParentLinks(sublayoutItem!, parentLayoutItems: parentLinklayoutItems)
        }

        //also hide layoutItem if required
        if let me = object.mainEntry {
            if PSPluginSingleton.sharedInstance.typeIsEvent(me.type) {
                layoutBoard.hideLayoutItem(objectsTolayoutItems[object]!, hidden: eventsHidden)
            }
        }
    }

    
    func updateViewForLink(startObject : LayoutObject, destObject : LayoutObject)
    {
        if let startlayoutItem = objectsTolayoutItems[startObject] as PSLayoutItem? {
            if let destlayoutItem = objectsTolayoutItems[destObject] as PSLayoutItem? {
                layoutBoard.makeLinkItem(startlayoutItem, destLayoutItem: destlayoutItem) //checks if link has already been made
            }
        }
    }
    
    //called when: a layoutItem is selected by mouse in layoutboard
    //action: gets the object the layoutItem is associated with and selects it
    func selectObjectForLayoutItem(selectedlayoutItem : PSLayoutItem) {
        if let obj = layoutItemsToObjects[selectedlayoutItem] {
            selectionController.selectEntry(obj.mainEntry)
        }
    }
    

    
    func deSelect() {
        selectionController.selectEntry(nil)
    }
    
    func doubleClickObjectForLayoutItem(selectedLayoutItem : PSLayoutItem) {
        if let obj = layoutItemsToObjects[selectedLayoutItem] {
            selectionController.doubleClickEntry(obj.mainEntry)
        }
    }
    
    //checks whether a given layoutItem is an object or not
    func layoutItemIsObject(layoutItem : PSLayoutItem) -> Bool {
        let object = layoutItemsToObjects[layoutItem]
        if object != nil {
            return true
        }
        else {
            return false
        }
        
    }
    
    //called when: a tool is dragged from left toolbar onto board
    //action: updates core-data with new tool
    func draggedNewTool(toolName : String, location: NSPoint) {
        scriptData.beginUndoGrouping("Add New Object")
        var success = false
        if let new_entry = scriptData.createNewObjectFromTool(PSType.FromName(toolName)) {
            
            //not all objects need to have a layoutObject now
            if let layoutObject = new_entry.layoutObject {
                layoutObject.xPos = location.x
                layoutObject.yPos = location.y
            }
            success = true
            selectionController.selectEntry(new_entry)
        } 
        
        scriptData.endUndoGrouping(success)
    }
    
    
    
    //called when: an existing layoutItem representing a layoutobject is dragged to a new location
    //action: updates core-data
    func layoutItemMoved(objectlayoutItem : PSLayoutItem) {
        let the_object = layoutItemsToObjects[objectlayoutItem] as LayoutObject?
        if let safe_object = the_object {
            scriptData.beginUndoGrouping("Move Object")
            safe_object.xPos = objectlayoutItem.icon.position.x
            safe_object.yPos = objectlayoutItem.icon.position.y
            scriptData.endUndoGrouping()
        }
    }
    
    //called when: layoutItems are chosen to be linked
    //action: updates core-data with new link
    func linkObjects(targetLayoutItem : PSLayoutItem, destLayoutItem : PSLayoutItem){
        if let startObject = layoutItemsToObjects[targetLayoutItem] as LayoutObject? {
            if let destObject = layoutItemsToObjects[destLayoutItem] as LayoutObject? {
                //check if link is allowed
                scriptData.beginUndoGrouping("Add Link")
                
                if let pstool = PSPluginSingleton.sharedInstance.getPlugin(startObject.mainEntry.type) {
                    if pstool.createLinkFrom(startObject.mainEntry, to: destObject.mainEntry, withScript: scriptData) {
                        scriptData.endUndoGrouping(true)
                        return
                    }
                }
                    
                if let pstool = PSPluginSingleton.sharedInstance.getPlugin(destObject.mainEntry.type) {
                    if pstool.createLinkFrom(destObject.mainEntry, to: startObject.mainEntry, withScript: scriptData) {
                        scriptData.endUndoGrouping(true)
                        return
                    }
                }
                
                
                
                scriptData.endUndoGrouping(false)
                PSModalAlert("You cannot link these objects.")
                return
              
            }
        }
        
    }
    
    //called when: layoutItems are chosen to be unlinked
    //action: deletes link from core-data
    func unLinkObjects(targetLayoutItem : PSLayoutItem, destLayoutItem : PSLayoutItem) {
        if let startObject = layoutItemsToObjects[targetLayoutItem] as LayoutObject? {
            if let destObject = layoutItemsToObjects[destLayoutItem] as LayoutObject? {
                if let pstool = PSPluginSingleton.sharedInstance.getPlugin(startObject.mainEntry.type) {
                    scriptData.beginUndoGrouping("Delete Link")
                    let success = pstool.deleteLinkFrom(startObject.mainEntry, to: destObject.mainEntry, withScript: scriptData)
                    scriptData.endUndoGrouping(success)
                }
            }
        }
    }
    
    //called when: a layoutItem is selected to be deleted
    //action: deletes assocaited layoutobject, entry and links from core-data
    func deleteLayoutItems(layoutItems : [PSLayoutItem]) {
        scriptData.beginUndoGrouping("Delete Object(s)")
        for layoutItem in layoutItems {
            if let o = layoutItemsToObjects[layoutItem] {
                selectionController.deleteObject(o)
            }
        }
        scriptData.endUndoGrouping(true)
    }
    
    func cleanUpChildren(layoutItem : PSLayoutItem) {
        if let o = layoutItemsToObjects[layoutItem] {
            PSSortSubTree(o,scriptData: scriptData)
        }
    }
    
    
    func pasteEntry() {
        if let se = selectionController.selectedEntry {
            scriptData.beginUndoGrouping("Paste Object")
            let pasteboard = NSPasteboard.generalPasteboard()
            let items = pasteboard.readObjectsForClasses([NSPasteboardItem.self], options: [:]) as! [NSPasteboardItem]
            for item in items {
                if let data = item.dataForType(PSPasteboardTypeLayoutObject) {
                    if let new_entry = scriptData.unarchiveBaseEntry(data) {
                        let new_name = scriptData.getNextFreeBaseEntryName(new_entry.name)
                        new_entry.name = new_name
                    }
                } else if let data = item.dataForType(PSPasteboardTypeAttribute as String) {
                    let dict = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! NSDictionary
                    let new_entry = PSCreateEntryFromDictionary(scriptData.docMoc, dict: dict)
                    se.addSubEntriesObject(new_entry)
                }
            }
            scriptData.endUndoGrouping(true)
        }
    }
    
    func copyEntry() {
        if let se = selectionController.selectedEntry {
            let pasteboardItem = NSPasteboardItem()
            let types = [NSPasteboardTypeString, PSPasteboardTypeLayoutObject]
            var ok = pasteboardItem.setDataProvider(self, forTypes: types)
            if ok {
                let pasteboard = NSPasteboard.generalPasteboard()
                pasteboard.clearContents()
                ok = pasteboard.writeObjects([pasteboardItem])
            }
            
            if (ok) {
                //here remember what was copied in order to paste it
                PSCopiedEntry = se
            }
        }
    }
    func pasteboard(pasteboard: NSPasteboard?, item: NSPasteboardItem, provideDataForType type: String) {
        if let ce = PSCopiedEntry {
            switch (type) {
            case NSPasteboardTypeString:
                guard let pasteboard = pasteboard else { return }
                let writer = PSScriptWriter(scriptData: mainWindowController.scriptData)
                let string = writer.entryToText(ce, level: 0)
                pasteboard.setString(string, forType: NSPasteboardTypeString)
            case PSPasteboardTypeLayoutObject:
                //need to send type of object and all attributes
                guard let pasteboard = pasteboard else { return }
                let data = scriptData.archiveBaseEntry(ce)
                pasteboard.setData(data, forType: PSPasteboardTypeLayoutObject)
            case PSPasteboardTypeAttribute:
                print("Cannot provide data for type : \(type)")
            default:
                print("Cannot provide data for type : \(type)")
            }
        }
    }
    
    func toolTypesForPath(path : String) -> [PSToolInterface]? {
        let exten = path.pathExtension.lowercaseString
        
        for (ext , tools) in scriptData.pluginProvider.fileImportPlugins {
            if ext == exten {
                return tools
            }
        }
        return nil
    }
    
    func draggedFiles(filesToImport : [String:[PSToolInterface]], location : NSPoint) -> Bool {
        
        if !scriptData.alertIfNoValidDocumentDirectory() {
            return false
        }
        
        scriptData.beginUndoGrouping("Drag new files")
        var offset : CGFloat = 0
        for (fn, tools) in filesToImport {
            //1. offer choice from tools (with use this setting for all files with same extension
            if let tool = tools.first, new_entry = tool.createFromDraggedFile(fn, scriptData: scriptData) {
                new_entry.layoutObject.xPos = location.x + offset
                new_entry.layoutObject.yPos = location.y + offset
                offset = offset + 5
            }
        }
        scriptData.endUndoGrouping(true)
        return true
    }
    
    func layoutItemsAreConvertible(layoutItems : [PSLayoutItem]) -> Bool {
        let types = layoutItems.flatMap({ return self.layoutItemsToObjects[$0] }).map({ $0.mainEntry.type})
        
        if let type = types.first {
            return scriptData.typeIsEvent(type) && !types.contains({ $0 != type })
        }
        
        return false
    }
    
    func convertLayoutItems(layoutItems : [PSLayoutItem]) {
        if !layoutItemsAreConvertible(layoutItems) { return }
        let events : [Entry] = layoutItems.flatMap({ return self.layoutItemsToObjects[$0] }).map({ $0.mainEntry })
        
        //reset the layout items so when next refresh occurs it uses new icons
        resetLayoutItems()
        
        convertEventsController = PSConvertEvents(scriptData: scriptData, events: events)
        convertEventsController.showAttributeModalForWindow(scriptData.window)
        
        
        
    }
    
    func resetLayoutItems() {
        for layoutItem in Array(objectsTolayoutItems.values) as [PSLayoutItem] {
            layoutBoard.removeObjectLayoutItem(layoutItem)
        }
        objectsTolayoutItems = [:]
        layoutItemsToObjects = [:]
        
        
    }
    
}
