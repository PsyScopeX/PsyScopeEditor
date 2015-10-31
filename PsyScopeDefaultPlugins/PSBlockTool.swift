//
//  PSBlockTool.swift
//  PsyScopeEditor
//
//  Created by James on 16/07/2014.
//


import Cocoa


class PSBlockTool: PSTool, PSToolInterface {
    
    override init() {
        super.init()
        typeString = "Block"
        helpfulDescriptionString = "Node for defining a block"
        iconName = "BlockTemplate-icon-128" // icon changed by Luca
        iconColor = NSColor.blueColor()
        classNameString = "PSBlockTool"
        section = (name: "BlockDefinitions", zorder: 2)
        identityProperty = Properties.Blocks
    }
    
    struct Properties {
        static let Blocks = PSProperty(name: "Blocks", defaultValue: "")
    }
    
    
    override func identifyEntries(ghostScript: PSGhostScript!) -> [AnyObject]!{
        return PSTool.identifyEntriesByPropertyInOtherEntry(ghostScript, property: Properties.Blocks, type: type())
    }
    
    override func isSourceForAttributes() -> Bool {
        return true
    }

    override func menuItemSelectedForAttributeSource(menuItem: NSMenuItem!, scriptData: PSScriptData!) -> String! {
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
        
        let subMenuItem = NSMenuItem(title: "Block", action: "", keyEquivalent: "b")
        subMenuItem.representedObject = self
        subMenuItem.tag = 0
        //get all blocks
        let blockEntries = scriptData.getBaseEntriesOfType(typeString)
   
        //now get all attributes
        var suitableAttributes : [String:Bool] = [:] //dummy dictionary to hold unique attribute names
        for link in blockEntries {
            for att in link.getAttributes() {
                suitableAttributes[att.name] = true
            }
        }
        if suitableAttributes.count == 0 {
            subMenuItem.enabled = false
            return subMenuItem }
        let menu = NSMenu(title: "Block")
        subMenuItem.submenu = menu;
        
        //now construct menu
        for (attributeName,_) in suitableAttributes {
            let newSubMenuItem = NSMenuItem()
            newSubMenuItem.title = attributeName
            newSubMenuItem.representedObject =  "BlockAttrib(\"\(attributeName)\")"
            newSubMenuItem.tag = 1
            menu.addItem(newSubMenuItem)
        }
        return subMenuItem
    }
    
    override func identifyAsAttributeSourceAndReturnRepresentiveString(currentValue: String!) -> [AnyObject]! {
        _ = PSFunctionElement()
        return PSToolHelper.attributedStringForAttributeFunction("BlockAttrib", icon: self.icon(), currentValue: currentValue)
        
    }
    
    override func getPropertiesViewController(entry: Entry!, withScript scriptData: PSScriptData!) -> PSPluginViewController? {
        return PSBlocksViewController(entry: entry, scriptData: scriptData)
    }
    
    override func createLinkFrom(parent: Entry!, to child: Entry!, withScript scriptData: PSScriptData!) -> Bool {
        if PSTool.createLinkFromToolToList(parent, to: child, withScript: scriptData) {
            return true
        }
        //Block has to be parent
        if parent.type == "Block" {
            //get the type of child which the parent already has (if any)
            let childrenOfParent : [Entry] = scriptData.getChildEntries(parent)
            var currentChildType : String = ""
            for childOfParent in childrenOfParent {
                if childOfParent.type != "List" {
                    currentChildType = childOfParent.type
                    break
                }
            }
            
            if scriptData.typeIsEvent(currentChildType) {
                currentChildType = "Event"
            }
            
            if currentChildType != "" {
                //found a child type - need to check if it's the same
                switch (currentChildType) {
                case "Block":
                    if child.type == "Block" {
                        scriptData.createLinkFrom(parent, to: child, withAttribute: "Blocks")
                        return true
                    } else {
                        return false
                    }
                case "Template":
                    if child.type == "Block" {
                        scriptData.moveParentLinks(parent, newParent: child, withAttribute: "Templates")
                        scriptData.createLinkFrom(parent, to: child, withAttribute: "Blocks")
                        return true
                    } else if child.type == "Template" {
                        scriptData.createLinkFrom(parent, to: child, withAttribute: "Templates")
                        return true
                    } else {
                        return false
                    }
                case "Event":
                    if child.type == "Block" {
                        scriptData.moveParentLinks(parent, newParent: child, withAttribute: "Events")
                        scriptData.createLinkFrom(parent, to: child, withAttribute: "Blocks")
                        return true
                    } else if child.type == "Template" {
                        scriptData.moveParentLinks(parent, newParent: child, withAttribute: "Events")
                        scriptData.createLinkFrom(parent, to: child, withAttribute: "Templates")
                        return true
                    } else if scriptData.typeIsEvent(child.type) {
                        scriptData.createLinkFrom(parent, to: child, withAttribute: "Events")
                        return true
                    } else {
                        return false
                    }
                default:
                    fatalError("Unknown / Invalid child type: '\(currentChildType)' for Group entry")
                }
            } else {
                if child.type == "Block" {
                    scriptData.createLinkFrom(parent, to: child, withAttribute: "Blocks")
                    return true
                } else if child.type == "Template" {
                    scriptData.createLinkFrom(parent, to: child, withAttribute: "Templates")
                    return true
                } else if scriptData.typeIsEvent(child.type) {
                    scriptData.createLinkFrom(parent, to: child, withAttribute: "Events")
                    return true
                } else {
                    return false
                }
            }
            
        } else {
            return false
        }
        return false
    }
    
    override func deleteLinkFrom(parent: Entry!, to child: Entry!, withScript scriptData: PSScriptData!) -> Bool {
        var childAttributeName : String = ""
        
        if scriptData.typeIsEvent(child.type) {
            childAttributeName = "Events"
        } else if child.type != "" {
            childAttributeName = child.type + "s"
        }
        
        
        if childAttributeName != "" {
            scriptData.removeLinkFrom(parent, to: child, withAttribute: childAttributeName)
            return true
        } else {
            return false
        }
    }


}
