//
//  PSCustomMenus.swift
//  PsyScopeEditor
//
//  Created by James on 16/06/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSCustomMenus : NSObject {
    
    @IBOutlet var mainWindowController : PSMainWindowController!
    @IBOutlet var customMenuPopUp : NSPopUpButton!
    
    var menuTitles : [String] = []
    var editController : PSEditMenusController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //register for NSPopUpButtonWillPopUpNotification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "popUpWillPopUp:", name: "NSPopUpButtonWillPopUpNotification", object: customMenuPopUp)
    }
    
    func popUpWillPopUp(_: AnyObject) {
        //construct menu from script
        let scriptData = mainWindowController.scriptData
        
        //save first and second item
        let firstItem = customMenuPopUp.itemAtIndex(0)! //the icon
        let secondItem = customMenuPopUp.itemAtIndex(1)! //'edit items' item
        let seperator = customMenuPopUp.itemAtIndex(2)! //seperator
        
        //remove all items
        customMenuPopUp.removeAllItems()
        
        //create new  menu with original items
        let menu = NSMenu()
        menu.addItem(firstItem)
        menu.addItem(secondItem)
        menu.addItem(seperator)
        
        let menuStructure = PSMenuStructure(scriptData: scriptData)
        
        //base items
        for menuComponent in menuStructure.menuComponents {
            //skip Experiment menu item
            if menuComponent.name == "Experiment" { break }
            //create a new menu item
            let menuItem = NSMenuItem()
            menuItem.title = menuComponent.name
            addItemsToMenuItem(menuItem, menuComponent: menuComponent, scriptData: scriptData)
            menu.addItem(menuItem)
        }
        
        //get base items
        
        //add menu to popup buttom
        customMenuPopUp.menu = menu
    }
    
    @IBAction func addNewMenuItemClick(_: AnyObject) {
        editController = PSEditMenusController(scriptData: mainWindowController.scriptData)
        editController.showAttributeModalForWindow(mainWindowController.scriptData.window)
    }
    
    func menuItemSelected(menuItem : NSMenuItem) {
        let scriptData = mainWindowController.scriptData
        let selectedTitle = menuItem.title
        if let entry = scriptData.getBaseEntry(selectedTitle) {
            let variable = PSSubjectVariable(entry: entry, scriptData: scriptData)
            //activate dialog for selected item
            PSSubjectVariableDialog(variable, currentValue: entry.currentValue)
        }
    }
    
    func addItemsToMenuItem(parentMenuItem : NSMenuItem, menuComponent : PSMenuComponent, scriptData : PSScriptData) {
        
        
        if menuComponent.subMenus {
            let subComponents = menuComponent.subComponents
            if subComponents.count > 0 {
                let subMenu = NSMenu()
                parentMenuItem.submenu = subMenu
                for subComponent in subComponents {
                    let childMenuItem = NSMenuItem()
                    childMenuItem.title = subComponent.name
                    subMenu.addItem(childMenuItem)
                    addItemsToMenuItem(childMenuItem, menuComponent: subComponent, scriptData: scriptData)
                }
            }
        } else {
            let dialogVariables = menuComponent.dialogVariables
            if dialogVariables.count > 0 {
                let subMenu = NSMenu()
                parentMenuItem.submenu = subMenu
                for dialogVariable in dialogVariables {
                    let childMenuItem = NSMenuItem()
                    childMenuItem.title = dialogVariable.name
                    childMenuItem.action = "menuItemSelected:"
                    childMenuItem.target = self
                    subMenu.addItem(childMenuItem)
                }
            }
        }
 
        
    }
}