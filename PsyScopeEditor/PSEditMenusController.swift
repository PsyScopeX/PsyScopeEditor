//
//  PSEditMenusController.swift
//  PsyScopeEditor
//
//  Created by James on 23/11/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

/**
 * PSEditMenusController: Loaded in EditMenus.xib.  Controls everything to do with editing menu structure, adding / removing / drag reordering.
 * 
 */
class PSEditMenusController : NSObject, NSOutlineViewDataSource, NSOutlineViewDelegate {
    
    //MARK: Dependencies
    
    let scriptData : PSScriptData
    let menuStructure : PSMenuStructure
    
    //MARK: Outlets
    
    @IBOutlet var menuStructureOutlineView : NSOutlineView!
    @IBOutlet var menuStructureSegmentedControl : NSSegmentedControl!
    @IBOutlet var attributeSheet : NSWindow!
    @IBOutlet var subjectVariablesController : PSEditMenusSubjectVariablesController!
    
    //MARK: Variables 
    
    var topLevelObjects : NSArray?
    var parentWindow : NSWindow!
    var initialized : Bool
    
    //MARK: Constants
    
    static let dragReorderVariableType = "PSEditMenusControllerSubjectVariable"
    static let dragReorderMenuType = "PSEditMenusControllerMenu"
    
    
    //MARK: Setup
    
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
            self.menuStructureOutlineView.registerForDraggedTypes(convertToNSPasteboardPasteboardTypeArray([PSEditMenusController.dragReorderVariableType, PSEditMenusController.dragReorderMenuType,PSEditMenusSubjectVariablesController.subjectVariableType]))
        }
    }
    
    var registeredForChanges : Bool = false {
        willSet {
            if newValue != registeredForChanges {
                if newValue {
                    NotificationCenter.default.addObserver(self, selector: #selector(PSEditMenusController.refreshNotification(_:)), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: scriptData.docMoc)
                    
                } else {
                    NotificationCenter.default.removeObserver(self)
                }
            }
        }
    }
    
    deinit {
        registeredForChanges = false
    }
    
    //MARK: Add/Remove Segmented Control
    
    @IBAction func menuStructureSegmentedControlClicked(_ : AnyObject) {
        switch menuStructureSegmentedControl.selectedSegment {
        case 0: addNewSubMenu()
        case 1: removeSelected()
        default: break
        }
    }
    
    func addNewSubMenu() {
        let selectedItem = menuStructureOutlineView.item(atRow: menuStructureOutlineView.selectedRow)
        if let menuComponent = selectedItem as? PSMenuComponent {
            menuComponent.addChildMenu()
        } else {
            menuStructure.addNewSubMenu()
        }
        menuStructure.saveToScript()
    }
    
    func removeSelected() {
        let selectedItem = menuStructureOutlineView.item(atRow: menuStructureOutlineView.selectedRow)
        let selectedItemParent = menuStructureOutlineView.parent(forItem: selectedItem)
        if let menuComponent = selectedItem as? PSMenuComponent {

            //get parent and remove from list
            if let menuComponentParent = selectedItemParent as? PSMenuComponent,
                let index = menuComponentParent.subComponents.index(of: menuComponent) {
                menuComponentParent.subComponents.remove(at: index)
                menuComponentParent.saveToScript()
            } else if let index = menuStructure.menuComponents.index(of: menuComponent) {
                //must be a base item
                menuStructure.menuComponents.remove(at: index)
                menuStructure.saveToScript()
            }
        } else if let dialogVariable = selectedItem as? PSSubjectVariable {
            if let menuComponentParent = selectedItemParent as? PSMenuComponent,
                let index = menuComponentParent.dialogVariables.index(of: dialogVariable) {
                    menuComponentParent.dialogVariables.remove(at: index)
                    menuComponentParent.saveToScript()
            }
        }
    }
    
    
    
    //MARK: Refresh
    @objc func refreshNotification(_ notification : Notification) {
        refresh()
    }
    
    func refresh() {
        menuStructure.parseFromScript()
        subjectVariablesController.refresh()
        menuStructureOutlineView.reloadData()
        menuStructureOutlineView.expandItem(nil, expandChildren: true)
    }
    
    
    // MARK: NSOutlineViewDataSource
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
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
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
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
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let menuComponent = item as? PSMenuComponent {
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
    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        if let menuComponent = item as? PSMenuComponent {
            return menuComponent.name
        } else if let subjectVariable = item as? PSSubjectVariable {
            return subjectVariable.name
        } else {
            return nil
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, byItem item: Any?) {
        if let menuComponent = item as? PSMenuComponent, let string = object as? String {
            menuComponent.name = string
        } else if let subjectVariable = item as? PSSubjectVariable, let string = object as? String {
            subjectVariable.name = string
        }
    }
    
    // MARK: NSOutlineViewDelegate

    func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
        let pboard = info.draggingPasteboard
        let indexToInsert = max(index,0)
        
        if let data = pboard.data(forType: convertToNSPasteboardPasteboardType(PSEditMenusSubjectVariablesController.subjectVariableType)),
            let newSubjectVariables : [String] = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String],
            let menuComponent = item as? PSMenuComponent {
        
                
                menuStructure.addSubjectVariables(newSubjectVariables, toMenu: menuComponent.name, atIndex: indexToInsert)
                menuStructure.saveToScript()
                return true
            
        } else if let data = pboard.data(forType: convertToNSPasteboardPasteboardType(PSEditMenusController.dragReorderVariableType)),
            let subjectVariableName : String = NSKeyedUnarchiver.unarchiveObject(with: data) as? String,
            let menuComponent = item as? PSMenuComponent {
                
                menuStructure.moveSubjectVariable(subjectVariableName, toMenu: menuComponent.name, atIndex: indexToInsert)
                menuStructure.saveToScript()
                return true
        } else if let data = pboard.data(forType: convertToNSPasteboardPasteboardType(PSEditMenusController.dragReorderMenuType)),
            let menuName : String = NSKeyedUnarchiver.unarchiveObject(with: data) as? String {
                
                if let menuItem = item as? PSMenuComponent {
                    menuStructure.moveMenu(menuName, toMenu: menuItem.name, atIndex: indexToInsert)
                } else {
                    menuStructure.moveMenuToBase(menuName, atIndex: indexToInsert)
                }
                menuStructure.saveToScript()
                
                return true
        }
        return false
    }
    
    func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
        let pboard = info.draggingPasteboard
        guard let types = convertFromOptionalNSPasteboardPasteboardTypeArray(pboard.types) else { return NSDragOperation() }
        if types.contains(PSEditMenusSubjectVariablesController.subjectVariableType) {
            if let menuComponent = item as? PSMenuComponent, !menuComponent.subMenus {
                return NSDragOperation.link
            }
        } else if types.contains(PSEditMenusController.dragReorderMenuType) {
            if let proposedParentItem = item as? PSMenuComponent  {
                
                if let data = pboard.data(forType: convertToNSPasteboardPasteboardType(PSEditMenusController.dragReorderMenuType)),
                    let menuName : String = NSKeyedUnarchiver.unarchiveObject(with: data) as? String,
                    let menuEntry = scriptData.getBaseEntry(menuName) {
                        
                        let proposedChildItem = PSMenuComponent(entry: menuEntry, scriptData: scriptData)
                        
                        if proposedParentItem == proposedChildItem {
                            return NSDragOperation()
                        }
                        
                        //if proposed child is parent of the proposed parent, then this is not allowed.
                        var nextParent : PSMenuComponent? =  menuStructure.getParentForComponent(proposedParentItem)
                        
                        while nextParent != nil {
                            if let nextParentMenu = nextParent {
                                if nextParentMenu == proposedChildItem {
                                    return NSDragOperation()
                                }
                                nextParent = menuStructure.getParentForComponent(nextParent!)
                            }
                        }
                        return NSDragOperation.link
                }
            } else if item == nil {
                return NSDragOperation.link
            }
            
            return NSDragOperation()
        } else if types.contains(PSEditMenusController.dragReorderVariableType) {
            if let menuComponent = item as? PSMenuComponent, !menuComponent.subMenus {
                return NSDragOperation.link
            }
        }
        
        return NSDragOperation()
    }
    
    func outlineView(_ outlineView: NSOutlineView, writeItems items: [Any], to pasteboard: NSPasteboard) -> Bool {
        guard let item = items.first, items.count == 1 else { return false }
        if let menuComponent = item as? PSMenuComponent {
            let data = NSKeyedArchiver.archivedData(withRootObject: menuComponent.name)
            pasteboard.declareTypes(convertToNSPasteboardPasteboardTypeArray([PSEditMenusController.dragReorderMenuType]), owner: self)
            pasteboard.setData(data, forType: convertToNSPasteboardPasteboardType(PSEditMenusController.dragReorderMenuType))
            return true
        } else if let subjectVariable = item as? PSSubjectVariable {
            let data = NSKeyedArchiver.archivedData(withRootObject: subjectVariable.name)
            pasteboard.declareTypes(convertToNSPasteboardPasteboardTypeArray([PSEditMenusController.dragReorderVariableType]), owner: self)
            pasteboard.setData(data, forType: convertToNSPasteboardPasteboardType(PSEditMenusController.dragReorderVariableType))
            return true
        }
        return false
    }

    //MARK: Showing the window

    func showAttributeModalForWindow(_ window : NSWindow) {
        if (attributeSheet == nil) {
            Bundle(for: type(of: self)).loadNibNamed("EditMenus", owner: self, topLevelObjects: &topLevelObjects)
        }
        
        parentWindow = window
        
        parentWindow.beginSheet(attributeSheet, completionHandler: {
            (response : NSApplication.ModalResponse) -> () in
            
            
            //NSApp.stopModalWithCode(response)
            
            
        })
        
        //disabled to allow manageobjectcontext notifications
        //NSApp.runModalForWindow(attributeSheet)
    }
    
    @IBAction func closeMyCustomSheet(_: AnyObject) {
        parentWindow.endSheet(attributeSheet)
    }
}


