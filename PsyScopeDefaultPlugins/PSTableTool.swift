//
//  PSListTool.swift
//  PsyScopeEditor
//
//  Created by James on 19/08/2014.
//

import Cocoa


class PSTableTool: PSTool, PSToolInterface {
    
    override init() {
        super.init()
        typeString = "Table"
        helpfulDescriptionString = "Define experimental design with factors for the experiment"
        iconName = "TableIcon"
        iconColor = NSColor.blueColor()
        classNameString = "PSTableTool"
        section = (name: "TableDefinitions", zorder: 8)
    }
    
    override func appearsInToolMenu() -> Bool { return false }
    
    override func isSourceForAttributes() -> Bool {
        return false
    }
    
    //is called when the item type is selected to be a source. window is provided incase any more data is needed, so provide in modal windows
    /*override func selectedAsSourceForAttribute(scriptData: PSScriptData!, baseEntry: Entry!) -> String! {
        //TODO get attributes from groups
        var attribute_popup = PSVaryByListPopup(baseEntry: baseEntry, scriptData: scriptData)
        attribute_popup.showAttributeModalForWindow(scriptData.window)
        return attribute_popup.currentValue
    }
    
    override func identifyAsAttributeSourceAndReturnRepresentiveString(currentValue: String!) -> Bool {
        return currentValue.rangeOfString("FactorAttrib") != nil
    }*/
    
    override func getPropertiesViewController(entry: Entry!, withScript scriptData: PSScriptData!) -> PSPluginViewController? {
        
        return PSTableViewController(entry: entry, scriptData: scriptData)

    }

}
