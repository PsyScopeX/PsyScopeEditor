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
    
    init(scriptData : PSScriptData) {
        self.scriptData = scriptData
        super.init()
    }
    
    var menuComponents : [PSMenuComponent] {
        get {
            guard let entry = scriptData.getBaseEntry("Menus") else { return [] }
            let stringList = PSStringList(entry: entry, scriptData: scriptData)
            var toReturn : [PSMenuComponent] = []
            for menuName in stringList.stringListRawStripped {
                if let menuDialogEntry = scriptData.getBaseEntry(menuName) {
                    toReturn.append(PSMenuComponent(entry: menuDialogEntry, scriptData: scriptData))
                }
            }
            return toReturn
        }
        
        set {
            if newValue.count > 0 {
                let entry = scriptData.getOrCreateBaseEntry("Menus", type: PSType.Menu, section: PSSection.Menus)
                let stringList = PSStringList(entry: entry, scriptData: scriptData)
                
                //flag any no long existent ones
                let existingNames = newValue.map({ $0.name })
                let toRemove : [String] = stringList.stringListRawStripped.filter( {
                    !existingNames.contains($0) })
                
                //remove them (chain subMenus)
                for subMenuToRemoveName in toRemove {
                    if let subMenuEntry = scriptData.getBaseEntry(subMenuToRemoveName) {
                        let menuComponent = PSMenuComponent(entry: subMenuEntry, scriptData: scriptData)
                        menuComponent.removeSubMenus()
                    }
                }
                
                //add new ones
                for dialogVariable in newValue {
                    if !stringList.contains(dialogVariable.name) {
                        stringList.appendAsString(dialogVariable.name)
                    }
                }
                
                
            } else {
                scriptData.deleteBaseEntryByName("Menus")
            }
        }
    }

    

}

class PSMenuComponent : NSObject {
    
    let scriptData : PSScriptData
    let entry : Entry
    
    init(entry : Entry, scriptData : PSScriptData) {
        self.scriptData = scriptData
        self.entry = entry
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
            entry.name = newValue
        }
    }
    
    var subComponents : [PSMenuComponent] {
        get {
            if let subMenus = scriptData.getBaseEntry("SubMenus") {
                //get new PSMenuComponents for each item
                let subMenusList = PSStringList(entry: subMenus, scriptData: scriptData)
                var componentsToReturn : [PSMenuComponent] = []
                for item in subMenusList.stringListRawStripped {
                    if let itemEntry = scriptData.getBaseEntry(item) {
                        componentsToReturn.append(PSMenuComponent(entry: itemEntry, scriptData: scriptData))
                    }
                }
                return componentsToReturn
            } else {
                return []
            }
        }
        
        set {
            if newValue.count > 0 {
                let subMenus = scriptData.getOrCreateSubEntry("SubMenus", entry: entry, isProperty: true)
                let subMenusList = PSStringList(entry: subMenus, scriptData: scriptData)
                for subComponent in newValue {
                    if !subMenusList.contains(subComponent.name) {
                        subMenusList.appendAsString(subComponent.name)
                    }
                }
                //also remove current value
                entry.currentValue = ""
            } else {
                removeSubMenus()
            }
        }
    }
    
    
    
    func removeSubMenus() {
        //delete the subMenus
        if let subMenus = scriptData.getSubEntry("SubMenus", entry: entry) {
            let subMenusList = PSStringList(entry: subMenus, scriptData: scriptData)
            for subComponentName in subMenusList.stringListRawStripped {
                if let subComponentEntry = scriptData.getBaseEntry(subComponentName) {
                    let menuComponent = PSMenuComponent(entry: subComponentEntry, scriptData: scriptData)
                    menuComponent.removeSubMenus()
                }
            }
            scriptData.deleteNamedSubEntryFromParentEntry(entry, name: "SubMenus")
        }
    }
    
    var dialogVariables : [PSSubjectVariable] {
        get {
            let stringList = PSStringList(entry: entry, scriptData: scriptData)
            var variablesToReturn : [PSSubjectVariable] = []
            for dialogVariableName in stringList.stringListRawStripped {
                if let dialogVariableEntry = scriptData.getBaseEntry(dialogVariableName) {
                    variablesToReturn.append(PSSubjectVariable(entry: dialogVariableEntry, scriptData: scriptData))
                }
            }
            return variablesToReturn
        }
        
        set {
            if newValue.count > 0 {
                let stringList = PSStringList(entry: entry, scriptData: scriptData)
                for dialogVariable in newValue {
                    if !stringList.contains(dialogVariable.name) {
                        stringList.appendAsString(dialogVariable.name)
                    }
                }
                //also remove any submenu related subentries
                removeSubMenus()
            } else {
                entry.currentValue = ""
            }
        }
    }
}