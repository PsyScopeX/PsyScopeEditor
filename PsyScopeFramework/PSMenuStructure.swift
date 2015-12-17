//
//  PSMenuStructure.swift
//  PsyScopeEditor
//
//  Created by James on 23/11/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

public class PSMenuStructure : NSObject {
    
    let scriptData : PSScriptData
    public var menuComponents : [PSMenuComponent]
    var saving : Bool
    
    public init(scriptData : PSScriptData) {
        self.scriptData = scriptData
        self.menuComponents = []
        self.saving = false
        super.init()
        parseFromScript()
    }
    
    public func saveToScript() {
        saving = true
        scriptData.beginUndoGrouping("Edit Menus")
        print("Menu structure saving to script with \(menuComponents.count) components")
        if menuComponents.count > 0 {
            let entry = scriptData.getOrCreateBaseEntry("Menus", type: PSType.Menu, section: PSSection.Menus)
            let stringList = PSStringList(entry: entry, scriptData: scriptData)
            
            stringList.stringListRawUnstripped = menuComponents.map({ $0.name })
            print("Components: \(entry.currentValue)")
            for menuComponent in menuComponents {
                menuComponent.saveToScript()
            }
            
        } else {
            scriptData.deleteBaseEntryByName("Menus")
        }
        saving = false
        scriptData.endUndoGrouping()
        
    }
    
    public func parseFromScript() {
        if saving { return }
        menuComponents = []
        guard let entry = scriptData.getBaseEntry("Menus") else { return }
        let stringList = PSStringList(entry: entry, scriptData: scriptData)
        for menuName in stringList.stringListRawStripped {
            if let menuDialogEntry = scriptData.getBaseEntry(menuName) {
                menuComponents.append(PSMenuComponent(entry: menuDialogEntry, scriptData: scriptData))
            }
        }
    }
    
    
    
    public func addNewSubMenu() {
        let newName = scriptData.getNextFreeBaseEntryName("Menu")
        let newMenuEntry = scriptData.getOrCreateBaseEntry(newName, type: PSType.Menu, section: PSSection.Menus)
        self.menuComponents.append(PSMenuComponent(entry: newMenuEntry, scriptData: scriptData))
    }
    
    public func getAllChildMenuDialogVariables() -> [PSSubjectVariable] {
        var menuDialogVariables : [PSSubjectVariable] = []
        for menuComponent in menuComponents {
            let childMenuDialogVariables = menuComponent.getAllChildMenuDialogVariables()
            menuDialogVariables.appendContentsOf(childMenuDialogVariables)
        }
        
        var seen: [String:Bool] = [:]
        return menuDialogVariables.filter({ seen.updateValue(true, forKey: $0.name) == nil })
    }
    
    public func getParentForComponent(component : PSMenuComponent) -> PSMenuComponent? {
        for mc in menuComponents {
            if mc == component {
                return nil
            }
            if let s = mc.returnParentFor(component) {
                return s
            }
        }
        return nil
    }
    
    public func getParentForVariable(variable : PSSubjectVariable) -> PSMenuComponent? {
        for mc in menuComponents {
            if let parent = mc.returnParentForSubjectVariable(variable) {
                return parent
            }
        }
        return nil
    }
    
    public func getMenuNamed(menuName : String) -> PSMenuComponent? {
        for mc in menuComponents {
            if mc.name == menuName {
                return mc
            }
            if let s = mc.getMenuNamed(menuName) {
                return s
            }
        }
        return nil
    }
    
    public func getVariableNamed(variableName : String) -> PSSubjectVariable? {
        for mc in menuComponents {
            if let s = mc.getVariableNamed(variableName) {
                return s
            }
        }
        return nil
    }
    
    public func removeComponent(component : PSMenuComponent) {
        if let index = menuComponents.indexOf(component) {
            menuComponents.removeAtIndex(index)
        }
        for menuComponent in menuComponents {
            menuComponent.removeComponent(component)
        }
    }
    
    public func removeSubjectVariable(subjectVariable : PSSubjectVariable) {
        for menuComponent in menuComponents {
            menuComponent.removeSubjectVariable(subjectVariable)
        }
    }
    
    public func addSubjectVariables(newSubjectVariables : [String], toMenu menuName: String, atIndex indexToInsert: Int) {
        
        guard let menuToMoveTo = getMenuNamed(menuName) else { return }
        for subjectVariableName in newSubjectVariables {
            if let subjectVariableEntry = scriptData.getBaseEntry(subjectVariableName) {
                menuToMoveTo.dialogVariables.insert(PSSubjectVariable(entry: subjectVariableEntry, scriptData: scriptData), atIndex: indexToInsert)
            }
        }
    }
    
    public func moveSubjectVariable(subjectVariableName : String, toMenu menuName: String, atIndex indexToInsert : Int) {
        
        guard let subjectVariableToMove = getVariableNamed(subjectVariableName),
            menuToMoveTo = getMenuNamed(menuName) else { return }
        
        //are we moving within same menu?
        if let oldIndex = menuToMoveTo.dialogVariables.indexOf(subjectVariableToMove) {
            // Move the specified row to its new location...
            // if we remove a row then everything moves down by one
            // so do an insert prior to the delete
            // --- depends which way were moving the data!!!
            //print("\(oldIndex) -> \(index)")
            if (oldIndex < indexToInsert) {
                menuToMoveTo.dialogVariables.insert(subjectVariableToMove, atIndex: indexToInsert)
                menuToMoveTo.dialogVariables.removeAtIndex(oldIndex)
            } else {
                menuToMoveTo.dialogVariables.removeAtIndex(oldIndex)
                menuToMoveTo.dialogVariables.insert(subjectVariableToMove, atIndex: indexToInsert)
            }
        } else {
            //moving from one menu to another
            if let subjectVariableParent = getParentForVariable(subjectVariableToMove),
                index = subjectVariableParent.dialogVariables.indexOf(subjectVariableToMove) {
                    subjectVariableParent.dialogVariables.removeAtIndex(index)
            }
            
            menuToMoveTo.dialogVariables.insert(subjectVariableToMove, atIndex: indexToInsert)
        }
    }
    
    public func moveMenuToBase(childMenuName : String, atIndex indexToInsert : Int) {
        guard let childMenu = getMenuNamed(childMenuName) else { return }
        
        if let oldIndex = menuComponents.indexOf(childMenu) {
            if (oldIndex < indexToInsert) {
                menuComponents.insert(childMenu, atIndex: indexToInsert)
                menuComponents.removeAtIndex(oldIndex)
            } else {
                menuComponents.removeAtIndex(oldIndex)
                menuComponents.insert(childMenu, atIndex: indexToInsert)
            }
        } else {
            removeComponent(childMenu)
            menuComponents.insert(childMenu, atIndex: indexToInsert)
        }
    }
    
    public func moveMenu(childMenuName : String, toMenu newParentMenuName: String, atIndex indexToInsert : Int) {
        
        guard let childMenu = getMenuNamed(childMenuName),
            newParentMenu = getMenuNamed(newParentMenuName) else { return }
        
        
        if let oldParentMenu = getParentForComponent(childMenu),
            oldIndex = oldParentMenu.subComponents.indexOf(childMenu) where oldParentMenu == newParentMenu {
                // Special case as moving within same menu (reordering)
                if (oldIndex < indexToInsert) {
                    newParentMenu.subComponents.insert(childMenu, atIndex: indexToInsert)
                    newParentMenu.subComponents.removeAtIndex(oldIndex)
                } else {
                    newParentMenu.subComponents.removeAtIndex(oldIndex)
                    newParentMenu.subComponents.insert(childMenu, atIndex: indexToInsert)
                }
                
        } else {
            //Standard case
            removeComponent(childMenu)
            newParentMenu.subComponents.insert(childMenu, atIndex: indexToInsert)
        }
    }
    
}

public class PSMenuComponent : Equatable {
    
    let scriptData : PSScriptData
    let entry : Entry
    public var subComponents : [PSMenuComponent]
    public var dialogVariables : [PSSubjectVariable]
    public var subMenus : Bool
    var saving : Bool
    
    public init(entry : Entry, scriptData : PSScriptData) {
        self.scriptData = scriptData
        self.entry = entry
        self.subComponents = []
        self.dialogVariables = []
        self.subMenus = false
        self.saving = false
        parseFromScript()
    }
    
    public convenience init(getOrCreateFrom name : String, scriptData : PSScriptData) {
        let entry = scriptData.getOrCreateBaseEntry(name, type: PSType.Menu, section: PSSection.Menus)
        self.init(entry: entry, scriptData: scriptData)
    }
    
    public var name : String {
        get {
            return entry.name
        }
        
        set {
            scriptData.beginUndoGrouping("Rename Menu")
            scriptData.renameEntry(entry, nameSuggestion: newValue)
            scriptData.endUndoGrouping()
        }
    }
    
    public func getAllChildMenuDialogVariables() -> [PSSubjectVariable] {
        
        if self.subMenus {
            var menuDialogVariables : [PSSubjectVariable] = []
            for menuComponent in subComponents {
                menuDialogVariables += menuComponent.getAllChildMenuDialogVariables()
            }
            var seen: [String:Bool] = [:]
            return menuDialogVariables.filter({ seen.updateValue(true, forKey: $0.name) == nil })
        } else {
            return dialogVariables
        }
        
    }
    
    public func saveToScript() {
        saving = true
        print("Menu \(self.name) saving to script with \(subComponents.count) components")
        if subComponents.count > 0 {
            let subMenus = scriptData.getOrCreateSubEntry("SubMenus", entry: entry, isProperty: true)
            let subMenusList = PSStringList(entry: subMenus, scriptData: scriptData)
            
            subMenusList.stringListRawUnstripped = subComponents.map({ $0.name })
            
            print("Components: \(subMenus.currentValue)")
            
            //also remove current value
            entry.currentValue = ""
            
            for subComponent in subComponents {
                subComponent.saveToScript()
            }
            
            
        } else if dialogVariables.count > 0 {
            let stringList = PSStringList(entry: entry, scriptData: scriptData)
            
            stringList.stringListRawUnstripped = dialogVariables.map({ $0.name })
            
            //also remove any submenu related subentries
            removeSubMenus()
            
            for dialogVariable in dialogVariables {
                dialogVariable.saveToScript()
            }
            
        } else {
            entry.currentValue = ""
            removeSubMenusEntry()
        }
        saving = false
    }
    
    public func parseFromScript() {
        if saving { return }
        subComponents = []
        dialogVariables = []
        
        if let subMenus = scriptData.getSubEntry("SubMenus", entry: entry) {
            self.subMenus = true
            //get new PSMenuComponents for each item
            let subMenusList = PSStringList(entry: subMenus, scriptData: scriptData)
            for item in subMenusList.stringListRawStripped {
                if let itemEntry = scriptData.getBaseEntry(item) {
                    subComponents.append(PSMenuComponent(entry: itemEntry, scriptData: scriptData))
                }
            }
        } else {
            self.subMenus = false
            let stringList = PSStringList(entry: entry, scriptData: scriptData)
            for dialogVariableName in stringList.stringListRawStripped {
                if let dialogVariableEntry = scriptData.getBaseEntry(dialogVariableName) {
                    dialogVariables.append(PSSubjectVariable(entry: dialogVariableEntry, scriptData: scriptData))
                }
            }
        }
    }
    
    
    public func addChildMenu() {
        let newName = scriptData.getNextFreeBaseEntryName("Menu")
        let newMenuEntry = scriptData.getOrCreateBaseEntry(newName, type: PSType.Menu, section: PSSection.Menus)
        self.subComponents.append(PSMenuComponent(entry: newMenuEntry, scriptData: scriptData))
        self.saveToScript()
    }
    
    public func remove() {
        removeSubMenus()
    }
    
    public func removeSubMenus() {
        //delete the subMenus
        if let subMenus = scriptData.getSubEntry("SubMenus", entry: entry) {
            let subMenusList = PSStringList(entry: subMenus, scriptData: scriptData)
            for subComponentName in subMenusList.stringListRawStripped {
                if let subComponentEntry = scriptData.getBaseEntry(subComponentName) {
                    let menuComponent = PSMenuComponent(entry: subComponentEntry, scriptData: scriptData)
                    menuComponent.removeSubMenus()
                    scriptData.deleteBaseEntry(subComponentEntry)
                }
            }
            removeSubMenusEntry()
        }
    }
    
    public func removeSubMenusEntry() {
        scriptData.deleteNamedSubEntryFromParentEntry(entry, name: "SubMenus")
    }
    
    
    public func returnParentFor(subMenu : PSMenuComponent) -> PSMenuComponent? {
        for sc in self.subComponents {
            if sc == subMenu {
                return self
            }
            if let s = sc.returnParentFor(subMenu) {
                return s
            }
        }
        return nil
    }
    
    public func returnParentForSubjectVariable(subjectVariable : PSSubjectVariable) -> PSMenuComponent? {
        for sc in self.dialogVariables {
            if sc == subjectVariable {
                return self
            }
        }
        
        for mc in self.subComponents {
            if let s = mc.returnParentForSubjectVariable(subjectVariable) {
                return s
            }
        }
        return nil
    }
    
    public func getMenuNamed(menuName : String) -> PSMenuComponent? {
        for mc in subComponents {
            if mc.name == menuName {
                return mc
            }
            if let s = mc.getMenuNamed(menuName) {
                return s
            }
        }
        return nil
    }
    
    public func getVariableNamed(variableName : String) -> PSSubjectVariable? {
        for variable in dialogVariables {
            if variable.name == variableName {
                return variable
            }
        }
        
        for mc in subComponents {
            if let s = mc.getVariableNamed(variableName) {
                return s
            }
        }
        return nil
    }
    
    public func removeComponent(component : PSMenuComponent) {
        if let index = subComponents.indexOf(component) {
            subComponents.removeAtIndex(index)
        }
        for subComponent in subComponents {
            subComponent.removeComponent(component)
        }
    }
    
    public func removeSubjectVariable(subjectVariable : PSSubjectVariable) {
        if let index = dialogVariables.indexOf(subjectVariable) {
            dialogVariables.removeAtIndex(index)
        }
        for subComponent in subComponents {
            subComponent.removeSubjectVariable(subjectVariable)
        }
    }
}

public func ==(lhs: PSMenuComponent, rhs: PSMenuComponent) -> Bool {
    return lhs.name == rhs.name
}