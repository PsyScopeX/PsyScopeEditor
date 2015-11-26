//
//  PSMenuStructure.swift
//  PsyScopeEditor
//
//  Created by James on 23/11/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

class PSMenuStructure : NSObject {
    
    let scriptData : PSScriptData
    var menuComponents : [PSMenuComponent]
    
    
    init(scriptData : PSScriptData) {
        self.scriptData = scriptData
        self.menuComponents = []
        super.init()
        parseFromScript()
    }
    
    func saveToScript() {
        if menuComponents.count > 0 {
            let entry = scriptData.getOrCreateBaseEntry("Menus", type: PSType.Menu, section: PSSection.Menus)
            let stringList = PSStringList(entry: entry, scriptData: scriptData)
            
            stringList.stringListRawUnstripped = menuComponents.map({ $0.name })
            
        } else {
            scriptData.deleteBaseEntryByName("Menus")
        }
    }
    
    func parseFromScript() {
        menuComponents = []
        guard let entry = scriptData.getBaseEntry("Menus") else { return }
        let stringList = PSStringList(entry: entry, scriptData: scriptData)
        for menuName in stringList.stringListRawStripped {
            if let menuDialogEntry = scriptData.getBaseEntry(menuName) {
                menuComponents.append(PSMenuComponent(entry: menuDialogEntry, scriptData: scriptData))
            }
        }
    }
    
    
    
    func addNewSubMenu() {
        let newName = scriptData.getNextFreeBaseEntryName("Menu")
        let newMenuEntry = scriptData.getOrCreateBaseEntry(newName, type: PSType.Menu, section: PSSection.Menus)
        self.menuComponents.append(PSMenuComponent(entry: newMenuEntry, scriptData: scriptData))
        self.saveToScript()
    }
    
    func getAllChildMenuDialogVariables() -> [PSSubjectVariable] {
        var menuDialogVariables : [PSSubjectVariable] = []
        for menuComponent in menuComponents {
            let childMenuDialogVariables = menuComponent.getAllChildMenuDialogVariables()
            menuDialogVariables.appendContentsOf(childMenuDialogVariables)
        }
        
        var seen: [String:Bool] = [:]
        return menuDialogVariables.filter({ seen.updateValue(true, forKey: $0.name) == nil })
    }
    
    func getParentForComponent(component : PSMenuComponent) -> PSMenuComponent? {
        return component.parentMenu()
    }
    
    func getParentForVariable(variable : PSSubjectVariable) -> PSMenuComponent? {
        for mc in menuComponents {
            if let parent = mc.returnParentForSubjectVariable(variable) {
                return parent
            }
        }
        return nil
    }
    
}

class PSMenuComponent : Equatable {
    
    let scriptData : PSScriptData
    let entry : Entry
    var subComponents : [PSMenuComponent]
    var dialogVariables : [PSSubjectVariable]
    var subMenus : Bool
    
    init(entry : Entry, scriptData : PSScriptData) {
        self.scriptData = scriptData
        self.entry = entry
        self.subComponents = []
        self.dialogVariables = []
        self.subMenus = false
        parseFromScript()
    }
    
    convenience init(getOrCreateFrom name : String, scriptData : PSScriptData) {
        let entry = scriptData.getOrCreateBaseEntry(name, type: PSType.Menu, section: PSSection.Menus)
        self.init(entry: entry, scriptData: scriptData)
    }
    
    var name : String {
        get {
            return entry.name
        }
        
        set {
            scriptData.beginUndoGrouping("Rename Menu")
            scriptData.renameEntry(entry, nameSuggestion: newValue)
            scriptData.endUndoGrouping()
        }
    }
    
    func getAllChildMenuDialogVariables() -> [PSSubjectVariable] {
        
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
    
    func saveToScript() {
        if subComponents.count > 0 {
            let subMenus = scriptData.getOrCreateSubEntry("SubMenus", entry: entry, isProperty: true)
            let subMenusList = PSStringList(entry: subMenus, scriptData: scriptData)
            
            subMenusList.stringListRawUnstripped = subComponents.map({ $0.name })
            
            //also remove current value
            entry.currentValue = ""
        } else if dialogVariables.count > 0 {
            let stringList = PSStringList(entry: entry, scriptData: scriptData)
            
            stringList.stringListRawUnstripped = dialogVariables.map({ $0.name })
    
            //also remove any submenu related subentries
            removeSubMenus()
        } else {
            entry.currentValue = ""
            removeSubMenus()
        }
    }
    
    func parseFromScript() {
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
    
    
    func addChildMenu() {
        let newName = scriptData.getNextFreeBaseEntryName("Menu")
        let newMenuEntry = scriptData.getOrCreateBaseEntry(newName, type: PSType.Menu, section: PSSection.Menus)
        self.subComponents.append(PSMenuComponent(entry: newMenuEntry, scriptData: scriptData))
        self.saveToScript()
    }
    
    func remove() {
        removeSubMenus()
    }
    
    func removeSubMenus() {
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
            scriptData.deleteNamedSubEntryFromParentEntry(entry, name: "SubMenus")
        }
    }
    
    func parentMenu() -> PSMenuComponent? {
        let menuStructure = PSMenuStructure(scriptData: scriptData)
        for mc in menuStructure.menuComponents {
            if mc == self {
                return nil
            }
            if let s = mc.returnParentFor(self) {
                return s
            }
        }
        return nil
    }
    
    func returnParentFor(subMenu : PSMenuComponent) -> PSMenuComponent? {
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
    
    func returnParentForSubjectVariable(subjectVariable : PSSubjectVariable) -> PSMenuComponent? {
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
}

func ==(lhs: PSMenuComponent, rhs: PSMenuComponent) -> Bool {
    return lhs.name == rhs.name
}