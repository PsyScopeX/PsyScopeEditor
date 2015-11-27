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
        toolType = PSType.Template
        helpfulDescriptionString = "Node for defining a template"
        iconName = "Template-icon-128" //icon changed by Luca
        iconColor = NSColor.redColor()
        classNameString = "PSTemplateTool"
        section = PSSection.TemplateDefinitions
        identityProperty = Properties.Templates
    }
    
    struct Properties {
        static let Templates = PSProperty(name: "Templates", defaultValue: "")
    }
    
    override func identifyEntries(ghostScript: PSGhostScript) -> [PSScriptError]{
        return PSTool.identifyEntriesByPropertyInOtherEntry(ghostScript, property: identityProperty!, type: toolType)
    }
    
    override func isSourceForAttributes() -> Bool {
        return true
    }
    
    override func menuItemSelectedForAttributeSource(itemTitle: String, tag: Int, entry: Entry?, originalValue: String, originalFullType : PSAttributeType?, scriptData: PSScriptData) -> String {
        if entry != nil {
            return "TrialAttrib(\"\(itemTitle)\")"
        } else {
            return originalValue
        }
        
        /*
        //TODO more varied edit window
        var attribute_popup = PSVaryByAttributePopup(baseEntry: baseEntry, scriptData: scriptData, type: typeString)
        attribute_popup.showAttributeModalForWindow(scriptData.window)
        return "BlockAttrib(\"\(attribute_popup.currentValue)\")"*/
        
    }
    
    override func constructAttributeSourceSubMenu(scriptData: PSScriptData) -> NSMenuItem {
        
        let subMenuItem = NSMenuItem(title: "Template", action: "", keyEquivalent: "t")
        subMenuItem.representedObject = self
        subMenuItem.tag = 0
        //get all blocks, that this attribute is linked to, and list attributes
        let templateEntries = scriptData.getBaseEntriesOfType(toolType)
        
        //now get all attributes
        var suitableAttributes : [String:Entry] = [:] //dummy dictionary to hold unique attribute names
        for templateEntry in templateEntries {
            for att in templateEntry.getAttributes() {
                suitableAttributes[att.name] = templateEntry
            }
        }
        if suitableAttributes.count == 0 {
            subMenuItem.enabled = false
            return subMenuItem }
        let menu = NSMenu(title: "Template")
        subMenuItem.submenu = menu;
        
        //now construct menu
        for (attributeName,templateEntry) in suitableAttributes {
            let newSubMenuItem = NSMenuItem()
            newSubMenuItem.title = attributeName
            newSubMenuItem.representedObject = templateEntry
            newSubMenuItem.tag = 1
            menu.addItem(newSubMenuItem)
        }
        return subMenuItem
    }
    
    override func identifyAsAttributeSourceAndReturnRepresentiveString(currentValue: String) -> [AnyObject] {
        return PSToolHelper.attributedStringForAttributeFunction("TrialAttrib", icon: self.icon(), currentValue: currentValue)
        
    }
    
    override func getPropertiesViewController(entry: Entry, withScript scriptData: PSScriptData) -> PSPluginViewController? {
        return PSTemplatesViewController(entry: entry, scriptData: scriptData)
    }
    
    override func createLinkFrom(parent: Entry, to child: Entry, withScript scriptData: PSScriptData) -> Bool {
        if PSTool.createLinkFromToolToList(parent, to: child, withScript: scriptData) {
            return true
        }
        
        //Template has to be parent
        if parent.type == "Template" {
            
            if scriptData.typeIsEvent(child.type) {
                scriptData.createLinkFrom(parent, to: child, withAttribute: "Events")
                return true
            }
        }
        
        return false
    }
    
    override func deleteLinkFrom(parent: Entry, to child: Entry, withScript scriptData: PSScriptData) -> Bool {
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
