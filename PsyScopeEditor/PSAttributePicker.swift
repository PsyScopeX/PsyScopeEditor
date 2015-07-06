//
//  PSAttributePicker.swift
//  PsyScopeEditor
//
//  Created by James on 20/09/2014.
//  Copyright (c) 2014 James. All rights reserved.
//

import Cocoa

//typealias PSAttributeType = (attributeType : String, entryType : String)

class PSAttributePickerType : NSObject {
    var name : String = ""
    var userFriendlyName : String = ""
    var helpfulDescription : String = ""
}

class PSAttributePickerAttribute : NSObject {
    var codeName : String = ""
    var userFriendlyName : String = ""
    var helpfulDescription : String = ""
    var attribute : PSAttributeInterface! = nil
}

class PSAttributePicker: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    
    var selectAttributeFunction : ((PSAttributeInterface,Bool) -> ())?
    var selectedAttribute : PSAttributeInterface! = nil
    var scriptData : PSScriptData!
    let tableCellViewIdentifier : String = "PSAttributePickerCell"
    @IBOutlet var attributeTableView : NSTableView!
    @IBOutlet var popover : NSPopover!
    @IBOutlet var attributePopupButton : NSPopUpButton!
    
    var types : [PSAttributePickerType] {
        if _types == nil {
            _types = []
            var all_type = PSAttributePickerType()
            all_type.name = "All Attributes"
            all_type.userFriendlyName = "All Attributes"
            all_type.helpfulDescription = "The collection of all possible attributes"
            _types!.append(all_type)
            
            for (name, plugin) in scriptData.pluginProvider.toolPlugins as [String : PSToolInterface] {
                
                    var new_type = PSAttributePickerType()
                    new_type.name = plugin.type()
                    new_type.userFriendlyName = plugin.type()
                    new_type.helpfulDescription = plugin.helpfulDescription()
                    _types!.append(new_type)
                
            }
            
            for (name, plugin) in scriptData.pluginProvider.eventPlugins as [String : PSToolInterface] {
                    var new_type = PSAttributePickerType()
                    new_type.name = plugin.type()
                    new_type.userFriendlyName = plugin.type()
                    new_type.helpfulDescription = plugin.helpfulDescription()
                    _types!.append(new_type)
            }
        }
        
        return _types!
    }
    
    var _types : [PSAttributePickerType]?
    var attributes : [PSAttributePickerAttribute] = []
    var topLevelObjects : NSArray?
    var existingAttributes : [String] = []
    
    override init() {
        super.init()
        NSBundle(forClass: PSAttributePicker.self).loadNibNamed("AttributePicker", owner: self, topLevelObjects: &topLevelObjects)
    }
    
    override func awakeFromNib() {
        var nib = NSNib(nibNamed: "AttributePickerCell", bundle: NSBundle(forClass: PSAttributePicker.self))
        attributeTableView.registerNib(nib!, forIdentifier: tableCellViewIdentifier)

    }
    
    func showAttributeWindow(script_data : PSScriptData, view : NSView, entryType : String, existingAttributes : [String]) {
        scriptData = script_data
        self.existingAttributes = existingAttributes
        //put into popup menu
        var menu_items : [String] = []
        for type in types {
            menu_items.append(type.userFriendlyName)
        }
        attributePopupButton.removeAllItems()
        attributePopupButton.addItemsWithTitles(menu_items)
        
        
        attributes = []
        var chosenType = false
     
        for type in types {
            if type.name == entryType {
                attributePopupButton.selectItemWithTitle(type.userFriendlyName)
                chosenType = true
            }
        }
        
        
        if (!chosenType) {
            attributePopupButton.selectItemWithTitle("All Attributes")
        }
        
        
        popover.showRelativeToRect(view.bounds, ofView: view, preferredEdge: NSMinXEdge)
        
        selectAttributes(self)
    }
    

    @IBAction func selectAttributes(sender : AnyObject) {
        attributes = []
        var selected_type = "All Attributes"
        //get type selected
        for type in types {
            if type.userFriendlyName == attributePopupButton.selectedItem?.title {
                selected_type = type.name
            }
        }
        
        if selected_type != "All Attributes" {
            //show just the relevent attributes
            for (name, plugin) in scriptData.pluginProvider.attributePlugins {
                if let a_plugin = plugin as? PSAttributeInterface {
                    
                    var valid_types = a_plugin.tools()
                    
                    for tool_type in valid_types {
                        if tool_type as NSString == selected_type {
                            //attribute is applicable to this tool
                            var new_attribute = PSAttributePickerAttribute()
                            new_attribute.codeName = a_plugin.codeName()
                            new_attribute.userFriendlyName = a_plugin.userFriendlyName()
                            new_attribute.helpfulDescription = a_plugin.helpfulDescription()
                            new_attribute.attribute = a_plugin
                            attributes.append(new_attribute)
                            
                            
                            
                        }
                    }
                    
                }
            }
        } else {
        
        
            //show all possible attributes
            for (name, plugin) in scriptData.pluginProvider.attributePlugins {
                if let a_plugin = plugin as? PSAttributeInterface {
                    var new_attribute = PSAttributePickerAttribute()
                    new_attribute.codeName = a_plugin.codeName()
                    new_attribute.userFriendlyName = a_plugin.userFriendlyName()
                    new_attribute.helpfulDescription = a_plugin.helpfulDescription()
                    new_attribute.attribute = a_plugin
                    attributes.append(new_attribute)
                }
            }
        }
        
        attributes = sorted(attributes,{ (s1: PSAttributePickerAttribute, s2: PSAttributePickerAttribute) -> Bool in
            return s1.userFriendlyName < s2.userFriendlyName })
        attributeTableView.reloadData()
    }
    
    @IBAction func doneButtonClicked(sender : AnyObject) {
        popover.close()
    }
    
    
    func numberOfRowsInTableView(tableView: NSTableView!) -> Int {
        return attributes.count
    }
    
    func tableView(tableView: NSTableView!, objectValueForTableColumn tableColumn: NSTableColumn!, row: Int) -> AnyObject! {
        var attribute_name : NSString = attributes[row].userFriendlyName
        println(attribute_name)
        return attribute_name
    }
    
    func tableView(tableView: NSTableView!, viewForTableColumn tableColumn: NSTableColumn!, row: Int) -> NSView! {
        var view = tableView.makeViewWithIdentifier(tableCellViewIdentifier, owner: self) as PSAttributePickerCell
        view.attribute = attributes[row].attribute
        //preset button state
        view.button.state = contains(existingAttributes, attributes[row].codeName) ? 1 : 0
        view.selectAttributeFunction = {
            (tool : PSAttributeInterface, selected : Bool) -> () in
            //update the internal array of selected attributes
            if (selected) {
                self.existingAttributes.append(tool.codeName())
            } else {
                if let index = find(self.existingAttributes,tool.codeName()) {
                    self.existingAttributes.removeAtIndex(index)
                }
            }
            self.selectAttributeFunction!(tool, selected)
            return }
        return view
    }
    
    

    
    func tableView(tableView: NSTableView!, heightOfRow row: Int) -> CGFloat {
        return CGFloat(33)
    }
    
}
