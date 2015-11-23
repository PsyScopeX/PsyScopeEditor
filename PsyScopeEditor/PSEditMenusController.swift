//
//  PSEditMenusController.swift
//  PsyScopeEditor
//
//  Created by James on 23/11/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

class PSEditMenusController : NSObject, NSOutlineViewDataSource, NSOutlineViewDelegate {
    
    let scriptData : PSScriptData
    let menuStructure : PSMenuStructure
    
    @IBOutlet var menuStructureOutlineView : NSOutlineView!
    @IBOutlet var menuStructureSegmentedControl : NSSegmentedControl!
    @IBOutlet var attributeSheet : NSWindow!
    @IBOutlet var subjectVariablesController : PSEditMenusSubjectVariablesController!
    var topLevelObjects : NSArray?
    var parentWindow : NSWindow!
    var initialized : Bool
    
    static let dragReorderType = "PSEditMenusController"
    
    init(scriptData : PSScriptData) {
        self.scriptData = scriptData
        self.menuStructure = PSMenuStructure(scriptData: scriptData)
        self.initialized = false
        super.init()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if (!initialized) {
            refresh()
            initialized = true
            self.registeredForChanges = true
            self.menuStructureOutlineView.registerForDraggedTypes([PSEditMenusController.dragReorderType, PSEditMenusSubjectVariablesController.subjectVariableType])
        }
    }
    
    var registeredForChanges : Bool = false {
        willSet {
            if newValue != registeredForChanges {
                if newValue {
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshNotification:", name: NSManagedObjectContextObjectsDidChangeNotification, object: scriptData.docMoc)
                    
                } else {
                    NSNotificationCenter.defaultCenter().removeObserver(self)
                }
            }
        }
    }
    
    deinit {
        registeredForChanges = false
    }
    
    @IBAction func menuStructureSegmentedControlClicked(_ : AnyObject) {
        switch menuStructureSegmentedControl.selectedSegment {
        case 0: addNewSubMenu()
        case 1: removeSelectedSubMenu()
        default: break
        }
    }
    
    func addNewSubMenu() {
        let selectedItem = menuStructureOutlineView.itemAtRow(menuStructureOutlineView.selectedRow)
        if let menuComponent = selectedItem as? PSMenuComponent {
            menuComponent.addChildMenu()
        } else {
            menuStructure.addNewSubMenu()
        }
    }
    
    func removeSelectedSubMenu() {
        
    }
    
    //MARK: Refresh
    func refreshNotification(notification : NSNotification) {
        refresh()
    }
    
    func refresh() {
        menuStructure.parseFromScript()
        subjectVariablesController.refresh()
        menuStructureOutlineView.reloadData()
        menuStructureOutlineView.expandItem(nil, expandChildren: true)
    }
    
    
    // MARK: NSOutlineViewDataSource
    
    func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
        if item == nil {
            return menuStructure.menuComponents.count
        } else if let menuComponent = item as? PSMenuComponent {
            if menuComponent.subMenus {
                return menuComponent.subComponents.count
            } else {
                return menuComponent.dialogVariables.count
            }
        }
        return 0
    }
    func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        if item == nil {
            return menuStructure.menuComponents[index]
        } else if let menuComponent = item as? PSMenuComponent {
            if menuComponent.subMenus {
                return menuComponent.subComponents[index]
            } else {
                return menuComponent.dialogVariables[index]
            }
        } else {
            return ""
        }

    }
    func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
        if let menuComponent = item as? PSMenuComponent {
            print(menuComponent.name)
            if menuComponent.subMenus {
                if menuComponent.subComponents.count > 0 {
                    return true
                } else {
                    return false
                }
            } else {
                if menuComponent.dialogVariables.count > 0 {
                    return true
                } else {
                    return false
                }
            }
        }
        return false
    }
    func outlineView(outlineView: NSOutlineView, objectValueForTableColumn tableColumn: NSTableColumn?, byItem item: AnyObject?) -> AnyObject? {
        if let menuComponent = item as? PSMenuComponent {
            return menuComponent.name
        } else if let subjectVariable = item as? PSSubjectVariable {
            return subjectVariable.name
        } else {
            return nil
        }
    }
    
    func outlineView(outlineView: NSOutlineView, setObjectValue object: AnyObject?, forTableColumn tableColumn: NSTableColumn?, byItem item: AnyObject?) {
        if let menuComponent = item as? PSMenuComponent, string = object as? String {
            menuComponent.name = string
        } else if let subjectVariable = item as? PSSubjectVariable, string = object as? String {
            subjectVariable.name = string
        }
    }
    
    // MARK: NSOutlineViewDelegate

    func outlineView(outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: AnyObject?, childIndex index: Int) -> Bool {
        let pboard = info.draggingPasteboard()
        if let data = pboard.dataForType(PSEditMenusSubjectVariablesController.subjectVariableType),
            newSubjectVariables : [String] = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [String],
            menuComponent = item as? PSMenuComponent {
        
                scriptData.beginUndoGrouping("Edit Menus")
                for subjectVariableName in newSubjectVariables {
                    if let subjectVariableEntry = scriptData.getBaseEntry(subjectVariableName) {
                        menuComponent.dialogVariables.append(PSSubjectVariable(entry: subjectVariableEntry, scriptData: scriptData))
                    }
                }
                menuComponent.saveToScript()
                scriptData.endUndoGrouping()
            
        }
        return false
    }
    
    func outlineView(outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: AnyObject?, proposedChildIndex index: Int) -> NSDragOperation {
        let pboard = info.draggingPasteboard()
        guard let types = pboard.types else { return NSDragOperation.None }
        if types.contains(PSEditMenusSubjectVariablesController.subjectVariableType) {
            if let menuComponent = item as? PSMenuComponent where !menuComponent.subMenus {
                return NSDragOperation.Link
            }
        } else if types.contains(PSEditMenusController.dragReorderType) {
        }
        
        return NSDragOperation.None
    }

    
    
    
    func showAttributeModalForWindow(window : NSWindow) {
        if (attributeSheet == nil) {
            NSBundle(forClass: self.dynamicType).loadNibNamed("EditMenus", owner: self, topLevelObjects: &topLevelObjects)
        }
        
        parentWindow = window
        
        parentWindow.beginSheet(attributeSheet, completionHandler: {
            (response : NSModalResponse) -> () in
            
            
            //NSApp.stopModalWithCode(response)
            
            
        })
        
        //disabled to allow manageobjectcontext notifications
        //NSApp.runModalForWindow(attributeSheet)
    }
    
    @IBAction func closeMyCustomSheet(_: AnyObject) {
        parentWindow.endSheet(attributeSheet)
    }
}