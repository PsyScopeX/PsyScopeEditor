//
//  PSTemplateTool.swift
//  PsyScopeEditor
//
//  Created by James on 19/08/2014.
//

import Cocoa

class PSTemplateTool: PSTool , PSToolInterface {
    
    override init() {
        super.init()
        typeString = "Template"
        helpfulDescriptionString = "Node for defining a template"
        iconName = "Template-icon-128" //icon changed by Luca
        iconColor = NSColor.redColor()
        classNameString = "PSTemplateTool"
        section = (name: "TemplateDefinitions", zorder: 3)
        identityProperty = Properties.Templates
    }
    
    struct Properties {
        static let Templates = PSProperty(name: "Templates", defaultValue: "")
    }
    
    override func identifyEntries(ghostScript: PSGhostScript!) -> [AnyObject]!{
        return PSTool.identifyEntriesByPropertyInOtherEntry(ghostScript, property: identityProperty!, type: type())
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
        
        var subMenuItem = NSMenuItem(title: "Template", action: "", keyEquivalent: "t")
        subMenuItem.representedObject = self
        subMenuItem.tag = 0
        //get all blocks, that this attribute is linked to, and list attributes
        var templateEntries = scriptData.getBaseEntriesOfType(typeString)
        
        //now get all attributes
        var suitableAttributes : [String:Bool] = [:] //dummy dictionary to hold unique attribute names
        for link in templateEntries {
            for att in link.getAttributes() {
                suitableAttributes[att.name] = true
            }
        }
        if suitableAttributes.count == 0 {
            subMenuItem.enabled = false
            return subMenuItem }
        var menu = NSMenu(title: "Template")
        subMenuItem.submenu = menu;
        
        //now construct menu
        for (attributeName,dummybool) in suitableAttributes {
            var newSubMenuItem = NSMenuItem()
            newSubMenuItem.title = attributeName
            newSubMenuItem.representedObject =  "TrialAttrib(\"\(attributeName)\")"
            newSubMenuItem.tag = 1
            menu.addItem(newSubMenuItem)
        }
        return subMenuItem
    }
    
    override func identifyAsAttributeSourceAndReturnRepresentiveString(currentValue: String!) -> [AnyObject]! {
        let function = PSFunctionElement()
        return PSToolHelper.attributedStringForAttributeFunction("TrialAttrib", icon: self.icon(), currentValue: currentValue)
        
    }
    
    override func getPropertiesViewController(entry: Entry!, withScript scriptData: PSScriptData!) -> PSPluginViewController? {
        return PSTemplatesViewController(entry: entry, scriptData: scriptData)
    }
    
    override func createLinkFrom(parent: Entry!, to child: Entry!, withScript scriptData: PSScriptData!) -> Bool {
        
        //Experiment has to be parent
        if parent.type == "Template" {
            
            if scriptData.typeIsEvent(child.type) {
                scriptData.createLinkFrom(parent, to: child, withAttribute: "Events")
                return true
            }
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
