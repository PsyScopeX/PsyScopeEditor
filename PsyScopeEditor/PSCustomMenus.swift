//
//  PSCustomMenus.swift
//  PsyScopeEditor
//
//  Created by James on 16/06/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

/**
 * PSCustomMenus: Object loaded in Document.xib.  Controls NSPopUpButton that shows custom menu structure.
 */
class PSCustomMenus : NSObject {
    
    //MARK: Outlets
    
    @IBOutlet var mainWindowController : PSMainWindowController!
    @IBOutlet var customMenuPopUp : NSPopUpButton!
    
    //MARK: Variables
    
    var menuTitles : [String] = []
    var editController : PSEditMenusController!
    
    //MARK: Setup
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //register for NSPopUpButtonWillPopUpNotification
        NotificationCenter.default.addObserver(self, selector: "popUpWillPopUp:", name: "NSPopUpButtonWillPopUpNotification", object: customMenuPopUp)
    }
    
    //MARK: On NSPopUpButtonWillPopUpNotification
    
    func popUpWillPopUp(_: AnyObject) {
        //construct menu from script
        
        //get scriptData
        let scriptData = mainWindowController.scriptData
        
        //save default items then remove all items from popup
        let firstItem = customMenuPopUp.item(at: 0)! //the icon
        let secondItem = customMenuPopUp.item(at: 1)! //'edit items' item
        let seperator = customMenuPopUp.item(at: 2)! //seperator
        customMenuPopUp.removeAllItems()
        
        //create new  menu with original items
        let menu = NSMenu()
        menu.addItem(firstItem)
        menu.addItem(secondItem)
        menu.addItem(seperator)
        
        //parse the script to get the menu structyre
        let menuStructure = PSMenuStructure(scriptData: scriptData)
        
        //cycle base items recursively
        for menuComponent in menuStructure.menuComponents {
            
            //skip Experiment menu item
            if menuComponent.name == "Experiment" { break }
            
            //create menu item from base component
            let menuItem = createMenuItemFromMenuComponent(menuComponent, scriptData: scriptData)
            menu.addItem(menuItem)
        }

        //add menu to popup buttom
        customMenuPopUp.menu = menu
    }
    
    func createMenuItemFromMenuComponent(_ menuComponent : PSMenuComponent, scriptData : PSScriptData) -> NSMenuItem {
        
        //create a new menu item
        let menuItem = NSMenuItem()
        menuItem.title = menuComponent.name
        
        if menuComponent.subMenus {
            
            //menuComponent has submenus, add these recursively
            let subComponents = menuComponent.subComponents
            if subComponents.count > 0 {
                let subMenu = NSMenu()
                menuItem.submenu = subMenu
                for subComponent in subComponents {
                    let childMenuItem = createMenuItemFromMenuComponent(subComponent, scriptData: scriptData)
                    subMenu.addItem(childMenuItem)
                }
            }
        } else {
            
            //menuComponent has dialogVariables
            let dialogVariables = menuComponent.dialogVariables
            if dialogVariables.count > 0 {
                let subMenu = NSMenu()
                menuItem.submenu = subMenu
                for dialogVariable in dialogVariables {
                    let childMenuItem = NSMenuItem()
                    childMenuItem.title = dialogVariable.name
                    childMenuItem.action = "menuItemSelected:"
                    childMenuItem.target = self
                    subMenu.addItem(childMenuItem)
                }
            }
        }
        
        return menuItem
    }
    
    //MARK: Actions
    
    @IBAction func addNewMenuItemClick(_: AnyObject) {
        //open dialog to edit the menu
        editController = PSEditMenusController(scriptData: mainWindowController.scriptData)
        editController.showAttributeModalForWindow(mainWindowController.scriptData.window)
    }
    
    
    func menuItemSelected(_ menuItem : NSMenuItem) {
        //User has selected a dialog variable from the menu
        
        let scriptData = mainWindowController.scriptData
        let selectedTitle = menuItem.title
        if let entry = scriptData.getBaseEntry(selectedTitle) {
            let variable = PSSubjectVariable(entry: entry, scriptData: scriptData)
            
            //activate dialog for selected item
            PSSubjectVariableDialog(variable, currentValue: entry.currentValue)
        }
    }
    
    
}
