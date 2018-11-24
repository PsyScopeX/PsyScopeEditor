//
//  PSListTool.swift
//  PsyScopeEditor
//
//  Created by James on 19/08/2014.
//

import Foundation

//
//  PSEventTool.swift
//  PsyScopeEditor
//
//  Created by James on 19/08/2014.
//

import Foundation

//
//  PSBlockTool.swift
//  PsyScopeEditor
//
//  Created by James on 16/07/2014.
//


import Cocoa


class PSListTool: PSTool, PSToolInterface {
    
    
    
    override init() {
        super.init()
        toolType = PSType.List
        helpfulDescriptionString = "Node for defining a list"
        iconName = "List-icon"
        iconColor = NSColor.blue
        classNameString = "PSListTool"
        section = PSSection.ListDefinitions
        identityProperty = Properties.Factors
        properties = [Properties.Factors, Properties.Grip, Properties.Offset, Properties.AccessType, Properties.Levels, Properties.IsList]
    }
    
    struct Properties {
        static let Factors = PSProperty(name: "Factors", defaultValue: "")
        static let Grip = PSProperty(name: "Grip", defaultValue: "1")
        static let Offset = PSProperty(name: "Offset", defaultValue: "0")
        static let AccessType = PSProperty(name: "AccessType", defaultValue: "Sequential")
        static let Levels = PSProperty(name: "Levels", defaultValue: "", essential : true)
        static let IsList = PSProperty(name: "IsList", defaultValue: "TRUE", essential : true)
        
    }
    
    override func identifyEntries(_ ghostScript: PSGhostScript) -> [PSScriptError] {
        
        var errors : [PSScriptError] = PSTool.identifyEntriesByKeyAttribute(ghostScript, keyAttribute: "IsList", type: toolType)
        
        //Also need to create links with Factors: attribute
        errors += PSTool.identifyEntriesByPropertyInOtherEntry(ghostScript, property: Properties.Factors, type: toolType)
        return errors
    }
    
    override func updateEntry(_ realEntry: Entry, withGhostEntry ghostEntry: PSGhostEntry, scriptData: PSScriptData) {
        super.updateEntry(realEntry, withGhostEntry: ghostEntry, scriptData: scriptData)
        
        //all sub entries are properties
        for subEntry in realEntry.subEntries.array as! [Entry] {
            subEntry.isProperty = true
        }
    }
    
    override func isSourceForAttributes() -> Bool {
        return true
    }
    
    override func canAddAttributes() -> Bool {
        return false
    }
    
    
    override func deleteObject(_ lobject: Entry, withScript scriptData: PSScriptData) -> Bool {
        //remove all links
        for parent in lobject.layoutObject.parentLink as! Set<LayoutObject> {
            deleteLinkFrom(parent.mainEntry, to: lobject, withScript: scriptData)
        }
        scriptData.deleteMainEntry(lobject)
        return true
    }
    
    override func deleteLinkFrom(_ parent: Entry, to child: Entry, withScript scriptData: PSScriptData) -> Bool {
        parent.layoutObject.removeChildLinkObject(child.layoutObject)
        let factors_entry = scriptData.getOrCreateSubEntry("Factors", entry: parent, isProperty: true)
        let sets_entry = scriptData.getOrCreateSubEntry("Sets", entry: factors_entry, isProperty: true)
        let types_entry = scriptData.getOrCreateSubEntry("Types", entry: factors_entry, isProperty: true)
        
        let factors = PSStringList(entry: factors_entry, scriptData: scriptData)
        let sets = PSStringList(entry: sets_entry, scriptData: scriptData)
        let types = PSStringList(entry: types_entry, scriptData: scriptData)
        
        if let i = factors.indexOfValueWithString(child.name) {
            factors.removeAtIndex(i)
            sets.removeAtIndex(i)
            types.removeAtIndex(i)
        }
        
        //delete factors if none left
        if factors.count == 0 {
            scriptData.deleteSubEntryFromBaseEntry(parent, subEntry: factors_entry)
        }
        return true
    }
    
    override func identifyAsAttributeSourceAndReturnRepresentiveString(_ currentValue: String) -> [AnyObject] {
        return PSToolHelper.attributedStringForAttributeFunction("FactorAttrib", icon: self.icon(), currentValue: currentValue)
    }
    
    override func menuItemSelectedForAttributeSource(_ itemTitle: String, tag: Int, entry: Entry?, originalValue: String, originalFullType : PSAttributeType?, scriptData: PSScriptData) -> String {

        
        if let entry = entry {
            if itemTitle == "Edit List..." {
                //find entry for list + open list editor
                scriptData.selectionInterface.doubleClickEntry(entry)
            } else {
                
                
                
                //check field exists
                let list = PSList(scriptData: scriptData, listEntry: entry)
                guard let field = list.fields.filter({ itemTitle == $0.entry.name }).first else {
                    PSModalAlert("Couldn't find field named : \(itemTitle) on list: \(entry.name)")
                    return originalValue
                }
                
                //if given an original type, check if types match
                if let originalFullType = originalFullType where originalFullType.fullType != "" {
                    if field.type != originalFullType {
                        
                        //show warning
                        let question = "Do you want to convert the type of the field named \"\(itemTitle)\" on list \"\(entry.name)\"?"
                        let info = "The field: \"\(itemTitle)\" on list: \"\(entry.name)\" is of a different type to the item you are varying it by it to - click yes to automatically convert this field to the type \"\(originalFullType.fullType)\", click no to apply the change anyway, click cancel to make no changes."
                        let yesButton = "Yes"
                        let noButton = "No"
                        let cancelButton = "Cancel"
                        let alert = NSAlert()
                        alert.messageText = question
                        alert.informativeText = info
                        alert.addButton(withTitle: yesButton)
                        alert.addButton(withTitle: noButton)
                        alert.addButton(withTitle: cancelButton)
                        
                        let answer = alert.runModal()
                        if answer == NSAlertFirstButtonReturn {
                            //change type of field
                            field.entry.type = originalFullType.fullType
                        } else if answer == NSAlertSecondButtonReturn {
                            //fall through...
                        } else {
                            return originalValue
                        }
                    }
                }
                
                return "FactorAttrib(\"\(entry.name)\",\"\(itemTitle)\")"
                
            }
        } else {
            if itemTitle == "New List..." {
                //create new list and open editor
                scriptData.beginUndoGrouping("Create List")
                if let newListEntry = self.createObject(scriptData) {
                    
                    scriptData.selectionInterface.doubleClickEntry(newListEntry)
                }
                scriptData.endUndoGrouping()
            }
        }
        
        return originalValue
    }
 
    
    
    
    //For the varyby menu:
    
    // menuItemSelectedForAttributeSource will be called with or without and entry.
    // set the menuItem representedObject to self for without entry, and tag to whatever
    // set the menuItem representedObject to an entry, for with entry, and again tag to whatever
    
    
    override func constructAttributeSourceSubMenu(_ scriptData: PSScriptData) -> NSMenuItem {
        
        let subMenuItem = NSMenuItem(title: "List", action: "", keyEquivalent: "l")
        subMenuItem.representedObject = self
        subMenuItem.tag = 0
        subMenuItem.action = nil
        subMenuItem.target = nil
        //get all blocks, that this attribute is linked to, and list attributes
        let lists = scriptData.getBaseEntriesOfType(toolType)
        
        let listsMenu = NSMenu(title: "List")
        subMenuItem.submenu = listsMenu;
        
        //add new List option
        let newListItem = NSMenuItem()
        newListItem.title = "New List..."
        newListItem.representedObject = self
        newListItem.tag = 2
        listsMenu.addItem(newListItem)
        
        for list in lists {
            let newSubMenuItem = NSMenuItem()
            newSubMenuItem.title = list.name
            newSubMenuItem.representedObject =  list
            newSubMenuItem.tag = 0
            listsMenu.addItem(newSubMenuItem)
            
            
            let linkSubMenu = NSMenu()
            newSubMenuItem.submenu = linkSubMenu
            
            //add edit List option
            let editListItem = NSMenuItem()
            editListItem.title = "Edit List..."
            editListItem.representedObject = list
            editListItem.tag = 2
            newSubMenuItem.submenu!.addItem(editListItem)
            
            let sub_entries = list.subEntries.array as! [Entry]
            for att in sub_entries {
                if att.name != "Levels" && att.name != "IsList" {
                    let newAttSubMenuItem = NSMenuItem()
                    newAttSubMenuItem.title = att.name
                    newAttSubMenuItem.representedObject =  list
                    newAttSubMenuItem.tag = 1
                    newSubMenuItem.submenu!.addItem(newAttSubMenuItem)
                }
            }
        }
        return subMenuItem
    }
    

    
    override func getPropertiesViewController(_ entry: Entry, withScript scriptData: PSScriptData) -> PSPluginViewController? {
        
        return PSListViewController(entry: entry, scriptData: scriptData)
    }

}
