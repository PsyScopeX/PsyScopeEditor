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
        typeString = "List"
        helpfulDescriptionString = "Node for defining a list"
        iconName = "List-icon"
        iconColor = NSColor.blueColor()
        classNameString = "PSListTool"
        section = (name: "ListDefinitions", zorder: 7)
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
    
    override func identifyEntries(ghostScript: PSGhostScript!) -> [AnyObject]! {
        
        var errors : [PSScriptError] = PSTool.identifyEntriesByKeyAttribute(ghostScript, keyAttribute: "IsList", type: type())
        
        //Also need to create links with Factors: attribute
        errors += PSTool.identifyEntriesByPropertyInOtherEntry(ghostScript, property: Properties.Factors, type: type())
        return errors
    }
    
    override func updateEntry(realEntry: Entry!, withGhostEntry ghostEntry: PSGhostEntry!, scriptData: PSScriptData!) {
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
    
    override func createLinkFrom(parent: Entry!, to child: Entry!, withScript scriptData: PSScriptData!) -> Bool {
        if child.type == type() {
            let allowableParentTypes = ["Experiment","Group","Block","Template"]
            var allowed = false
            for apt in allowableParentTypes {
                if parent.type == apt {
                    allowed = true
                    break
                }
            }
            if !allowed { return false }
        } else {
            return false
        }
        
        //create Link
        parent.layoutObject.addChildLinkObject(child.layoutObject)
        //attribute is a weird one, as it has two sub attributes
        let factors_entry = scriptData.getOrCreateSubEntry("Factors", entry: parent, isProperty: true)
        let sets_entry = scriptData.getOrCreateSubEntry("Sets", entry: factors_entry, isProperty: true)
        let types_entry = scriptData.getOrCreateSubEntry("Types", entry: factors_entry, isProperty: true)
        
        let factors = PSStringList(entry: factors_entry, scriptData: scriptData)
        let sets = PSStringList(entry: sets_entry, scriptData: scriptData)
        let types = PSStringList(entry: types_entry, scriptData: scriptData)
        
        if (!factors.contains(child.name) && factors.appendAsString(child.name)) {
            sets.appendAsString("1")
            types.appendAsString("List")
        }
        
        return true
        
    }
    
    override func deleteObject(lobject: Entry!, withScript scriptData: PSScriptData!) -> Bool {
        //remove all links
        for parent in lobject.layoutObject.parentLink as! Set<LayoutObject> {
            deleteLinkFrom(parent.mainEntry, to: lobject, withScript: scriptData)
        }
        scriptData.deleteMainEntry(lobject)
        return true
    }
    
    override func deleteLinkFrom(parent: Entry!, to child: Entry!, withScript scriptData: PSScriptData!) -> Bool {
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
    
    override func identifyAsAttributeSourceAndReturnRepresentiveString(currentValue: String!) -> [AnyObject]! {
        return PSToolHelper.attributedStringForAttributeFunction("FactorAttrib", icon: self.icon(), currentValue: currentValue)
    }
    
    override func menuItemSelectedForAttributeSource(menuItem: NSMenuItem!, scriptData: PSScriptData!) -> String! {
        
        if menuItem.tag == 2 {
            if menuItem.title == "New List..." {
                //create new list and open editor
            } else if menuItem.title == "Edit List..." {
                //open list editor
            }
        }
        
        if let ro = menuItem.representedObject as? String {
            return ro
        } else {
            return "NULL"
        }
        
        /*
        //TODO more varied edit window
        var attribute_popup = PSVaryByAttributePopup(baseEntry: baseEntry, scriptData: scriptData, type: typeString)
        attribute_popup.showAttributeModalForWindow(scriptData.window)
        return "BlockAttrib(\"\(attribute_popup.currentValue)\")"*/
        
    }
    
    override func constructAttributeSourceSubMenu(scriptData: PSScriptData!) -> NSMenuItem! {
        
        let subMenuItem = NSMenuItem(title: "List", action: "", keyEquivalent: "l")
        subMenuItem.representedObject = self
        subMenuItem.tag = 0
        //get all blocks, that this attribute is linked to, and list attributes
        var lists = scriptData.getBaseEntriesOfType("List")
        if lists.count == 0 {
            subMenuItem.enabled = false
            return subMenuItem }
        
        let menu = NSMenu(title: "List")
        subMenuItem.submenu = menu;
        
        //add new List option
        let newListItem = NSMenuItem()
        newListItem.title = "New List..."
        newListItem.representedObject = self
        newListItem.tag = 2
        menu.addItem(newListItem)
        
        for list in lists {
            let newSubMenuItem = NSMenuItem()
            newSubMenuItem.title = list.name
            newSubMenuItem.representedObject =  self
            newSubMenuItem.tag = 0
            menu.addItem(newSubMenuItem)
            
            
            let linkSubMenu = NSMenu()
            newSubMenuItem.submenu = linkSubMenu
            
            //add edit List option
            let editListItem = NSMenuItem()
            editListItem.title = "Edit List..."
            editListItem.representedObject = list.name
            editListItem.tag = 2
            newSubMenuItem.submenu!.addItem(editListItem)
            
            let sub_entries = list.subEntries.array as! [Entry]
            for att in sub_entries {
                if att.name != "Levels" && att.name != "IsList" {
                    let newAttSubMenuItem = NSMenuItem()
                    newAttSubMenuItem.title = att.name
                    newAttSubMenuItem.representedObject =  "FactorAttrib(\"\(list.name)\",\"\(att.name)\")"
                    newAttSubMenuItem.tag = 1
                    newSubMenuItem.submenu!.addItem(newAttSubMenuItem)
                }
            }
        }
        return subMenuItem
    }
    

    
    override func getPropertiesViewController(entry: Entry!, withScript scriptData: PSScriptData!) -> PSPluginViewController? {
        
        return PSListViewController(entry: entry, scriptData: scriptData)
    }

}
