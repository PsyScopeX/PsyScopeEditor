//
//  PSVariablePropertiesOutlineView.swift
//  PsyScopeEditor
//
//  Created by James on 23/04/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSVariableOutlineViewController : NSObject, NSOutlineViewDataSource, NSOutlineViewDelegate {
    
    
    //MARK: Outlets
    var controller : PSVariablePropertiesController!
    @IBOutlet var outlineView : NSOutlineView!
    @IBOutlet var nameColumn : NSTableColumn!
    @IBOutlet var valueColumn : NSTableColumn!
    
    //MARK: Variables
    
    var selectedEntry : Entry!
    var type : PSVariableType!
    var currentValues : PSVariableValues!
    var initialValues : PSVariableValues!
    var expandedItems : [AnyObject] = []
    var editInitialValues : Bool = true
    
    //MARK: Refresh
    
    func refreshWithEntry(_ entry : Entry, editInitialValues : Bool) {
        self.editInitialValues = editInitialValues
        let scriptData = controller.scriptData
        selectedEntry = entry
        
        if let typeSubEntry = scriptData?.getSubEntry("Type", entry: entry),
            let fullType = TypeEntryToFullVariableType(typeSubEntry, scriptData: scriptData!) {
            type = fullType
                
            currentValues = PSVariableValuesFromVariableType("Current Value", variableType: type)
            UpdateVariableValuesWithEntryCurrentValues(entry, values: currentValues, scriptData: scriptData!)
                
            if editInitialValues {
                initialValues = PSVariableValuesFromVariableType("Initial Value", variableType: type)
                if let initEntry = scriptData?.getSubEntry("Init", entry: entry) {
                    UpdateVariableValuesWithInlineEntryCurrentValues(initEntry.currentValue, values: initialValues)
                }
            }
                
        } else {
            type = nil
        }
        outlineView.reloadData()
        outlineView.expandItem(nil, expandChildren: true) //expand all items
    }
    
    //MARK: Update script
    
    func updateScriptWithVariableValues() {
        //update structure of entry to match variable type
        controller.scriptData.beginUndoGrouping("Update Variable Value")
        UpdateEntryCurrentValuesWithVariableValues(selectedEntry, values: currentValues, scriptData: controller.scriptData)
        
        if editInitialValues {
            let initEntry = controller.scriptData.getOrCreateSubEntry("Init", entry: selectedEntry, isProperty: true)
            initEntry.currentValue = UpdateInlineEntryCurrentValuesWithVariableValues(initialValues)
        }
        controller.scriptData.endUndoGrouping(true)
    }
    
    //MARK: OutlineView Data source
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil && type != nil {
            return editInitialValues ? 2 : 1 //Current Value + Initial Value
        } else if let values = item as? PSVariableValues {
            return values.subValues.count
        } else {
            return 0
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
            if index == 0 {
                return currentValues
            } else {
                return initialValues
            }
        } else if let values = item as? PSVariableValues {
            return values.subValues[index]
        } else {
            fatalError("Parent should be nil or PSVariableValues")
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return (self.outlineView(outlineView, numberOfChildrenOfItem: item) > 0)
    }
    
    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        if tableColumn == nameColumn {
            
            if let values = item as? PSVariableValues {
                return values.label
            } else {
                fatalError("Items with values should be PSVariableValues")
            }
            
        } else if tableColumn == valueColumn {
            
            if let values = item as? PSVariableValues {
                switch values.type {
                case .singleValue:
                    return values.currentValue
                default:
                    return ""
                }
                
            } else {
                fatalError("Items with values should be PSVariableValues")
            }
            
        }
        
        fatalError("Column should be name or value column, and items with values should be PSVariableValues")
    }
    
    
    func outlineView(_ outlineView: NSOutlineView, shouldExpandItem item: Any) -> Bool {
        expandedItems.append(item as AnyObject)
        return true
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldCollapseItem item: Any) -> Bool {
        var newExpandedItems : [AnyObject] = []
        for obj in expandedItems {
            if obj as AnyObject !== item as AnyObject {
                newExpandedItems.append(obj as AnyObject)
            }
        }
        expandedItems = newExpandedItems
        return true
    }
    
    //MARK: Outlineview delegate
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        if convertFromNSUserInterfaceItemIdentifier(tableColumn!.identifier) == convertFromNSUserInterfaceItemIdentifier(nameColumn.identifier) {
            return outlineView.makeView(withIdentifier: tableColumn!.identifier, owner: nil)
        } else if convertFromNSUserInterfaceItemIdentifier(tableColumn!.identifier) == convertFromNSUserInterfaceItemIdentifier(valueColumn.identifier) {
            let view = outlineView.makeView(withIdentifier: tableColumn!.identifier, owner: nil) as! PSVariableOutlineViewCellView
            
            
            view.updateScriptBlock = self.updateScriptWithVariableValues
            if let values = item as? PSVariableValues {
                view.variableValue = values
                
                switch values.type {
                case .singleValue:
                    view.textField!.isEditable = true
                default:
                    view.textField!.isEditable = false
                }
                return view
            }
        }
        
        fatalError("Column should be name or value column, and items with values should be PSVariableValues")
    }
}
