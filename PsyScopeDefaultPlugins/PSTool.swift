//
//  PSTool.swift
//  PsyScopeEditor
//
//  Created by James on 27/08/2014.
//

import Cocoa

class PSTool: PSToolHelper {
    var toolType : PSType
    var helpfulDescriptionString : String
    var iconName : String
    var iconColor : NSColor
    var classNameString : String
    var properties : [PSProperty]
    var section : PSSection
    var identityProperty : PSProperty?
    var reservedEntryNames : [String]
    var illegalEntryNames : [String]
    override init() {
        toolType = PSType.UndefinedEntry
        helpfulDescriptionString = ""
        iconName = ""
        iconColor = NSColor.whiteColor()
        classNameString = ""
        section =  PSSection.UndefinedEntries
        properties = []
        identityProperty = nil
        reservedEntryNames = []
        illegalEntryNames = []
        super.init()
    }
    
    func type() -> String {
        return toolType.name
    }
    
    func helpfulDescription() -> String {
        return helpfulDescriptionString
    }
    
    func icon() -> NSImage {
        return PSTool.ImageNamed(iconName)
    }
    
    func color() -> NSColor {
        return iconColor
    }
    
    func psclassName() -> String  {
        return classNameString
    }
    
    func createLinkFrom(parent: Entry, to child: Entry, withScript scriptData: PSScriptData) -> Bool {
        return false
    }
    
    func deleteLinkFrom(parent: Entry, to child: Entry, withScript scriptData: PSScriptData) -> Bool {
        
        
        return false
    }
    
    func identifyEntries(ghostScript: PSGhostScript) -> [PSScriptError]{
        // blank entries must always be identified after all other plugins (so do nothing for this stage)
        return []
    }
    
    func validateBeforeRun(scriptData: PSScriptData) -> [PSScriptError] {
        return []
    }
    
    func createObjectWithGhostEntries(entries: [PSGhostEntry], withScript scriptData: PSScriptData) -> [LayoutObject]? {
        var return_array : [LayoutObject] = []
        for ent in entries {
            if let new_blank_obj = createObject(scriptData) {
                updateEntry(new_blank_obj, withGhostEntry: ent, scriptData: scriptData)
                
                if let _ = new_blank_obj.layoutObject {
                    return_array.append(new_blank_obj.layoutObject)
                }
            }
        }
        return return_array
    }
    
    func updateEntry(realEntry: Entry, withGhostEntry ghostEntry: PSGhostEntry, scriptData: PSScriptData) {
        
        PSUpdateEntryWithGhostEntry(realEntry, ghostEntry: ghostEntry, scriptData: scriptData)
        
        //make keyattributes properties so they don't show up in attribute browser
        
        let totalProperties = properties + PSDefaultConstants.StructuralProperties.All
        
        for property in totalProperties {
            scriptData.assertPropertyIsPresent(property, entry: realEntry)
        }
    }
    
    func createObject(scriptData: PSScriptData) -> Entry? {
        let layout_object = scriptData.createBaseEntryAndLayoutObjectPair(section, entryName: toolType.name, type: toolType)
        
        layout_object.icon = self.icon()

        //now do properties
        for property in properties {
            scriptData.assertPropertyIsPresent(property, entry: layout_object.mainEntry)
        }
        
        return layout_object.mainEntry
    }
    
    func deleteObject(lobject: Entry, withScript scriptData: PSScriptData) -> Bool {
        scriptData.deleteMainEntry(lobject)
        return true
    }
    
    func isSourceForAttributes() -> Bool {
        return false
    }
    

    func canAddAttributes() -> Bool {
        return true
    }
    
    func menuItemSelectedForAttributeSource(itemTitle : String, tag : Int, entry : Entry?, originalValue : String, scriptData: PSScriptData) -> String {
        fatalError("Tool is not source for script")
    }
    
    func constructAttributeSourceSubMenu(scriptData: PSScriptData) -> NSMenuItem {
        fatalError("Tool is not source for script")
    }
    
    func identifyAsAttributeSourceAndReturnRepresentiveString(currentValue: String) -> [AnyObject] {
        return []
    }
    
    func appearsInToolMenu() -> Bool { return true }
    
    func getPropertiesViewController(entry: Entry, withScript scriptData: PSScriptData) -> PSPluginViewController? {
        //default show nil
        return nil
        
    }
    
    func validDraggedFileExtensions() -> [String] {
        return []
    }
    
    func createFromDraggedFile(fileName : String, scriptData: PSScriptData) -> Entry? {
        return nil
    }
    
    func getReservedEntryNames() -> [String] {
        return reservedEntryNames
    }
    
    func getIllegalEntryNames() -> [String] {
        let allIllegalEntryNames = [toolType.name] + properties.map({ $0.name })
        return allIllegalEntryNames
    }
    
}
