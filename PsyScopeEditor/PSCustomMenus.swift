//
//  PSCustomMenus.swift
//  PsyScopeEditor
//
//  Created by James on 16/06/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSCustomMenus : NSObject {
    
    @IBOutlet var document : Document!
    @IBOutlet var customMenuPopUp : NSPopUpButton!
    
    var menuTitles : [String] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //register for NSPopUpButtonWillPopUpNotification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "popUpWillPopUp:", name: "NSPopUpButtonWillPopUpNotification", object: customMenuPopUp)
    }
    
    func popUpWillPopUp(AnyObject) {
        //construct menu from script
        let scriptData = document.scriptData
        
        //save first and second item
        let firstItem = customMenuPopUp.itemAtIndex(0)!
        let secondItem = customMenuPopUp.itemAtIndex(1)!
        let seperator = customMenuPopUp.itemAtIndex(2)!
        
        //remove all items
        customMenuPopUp.removeAllItems()
        
        //create new  menu with original items
        var menu = NSMenu()
        menu.addItem(firstItem)
        menu.addItem(secondItem)
        menu.addItem(seperator)
        
        //get base items
        if let menusList = PSStringList(baseEntryName: "Menus", scriptData: scriptData) {
            for value in menusList.values {
                switch(value) {
                    case  let .StringValue(stringElement):
                        //skip Experiment menu item
                        if stringElement.value == "Experiment" { break }
                        //create a new menu item
                        let menuItem = NSMenuItem()
                        menuItem.title = stringElement.value
                        if let itemEntry = scriptData.getBaseEntry(stringElement.value) {
                            addItemsToMenuItem(menuItem, entry: itemEntry, scriptData: scriptData)
                        }
                        menu.addItem(menuItem)
                    default:
                        break
                }
            }
        }
        
        //add menu to popup buttom
        customMenuPopUp.menu = menu
    }
    
    @IBAction func addNewMenuItemClick(AnyObject) {
        print("Click")
    }
    
    func menuItemSelected(menuItem : NSMenuItem) {
        print(menuItem.title)
        let scriptData = document.scriptData
        let selectedTitle = menuItem.title
        if let entry = scriptData.getBaseEntry(selectedTitle) {
            let variable = PSSubjectVariable(entry: entry, scriptData: scriptData)
            //activate dialog for selected item
            PSSubjectVariableDialog(variable, currentValue: entry.currentValue)
        }
    }
    
    func addItemsToMenuItem(menuItem : NSMenuItem, entry : Entry, scriptData : PSScriptData) {
        let menuTitles = PSStringList(entry: entry, scriptData: scriptData).stringListRawStripped
        
        if menuTitles.count > 0 {
            let subMenu = NSMenu()
            menuItem.submenu = subMenu
            for menuTitle in menuTitles {
                let menuItem = NSMenuItem()
                menuItem.title = menuTitle
                menuItem.action = "menuItemSelected:"
                menuItem.target = self
                subMenu.addItem(menuItem)
            }
        }
    }
}