//
//  PSVariableCompositeTypePopoverController.swift
//  PsyScopeEditor
//
//  Created by James on 27/04/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSVariableCompositeTypePopoverController : NSObject, NSOutlineViewDelegate, NSOutlineViewDataSource {
    
    
    var variableType : PSVariableType!
    var refreshing : Bool = false
    
    //MARK: Outlets
    
    @IBOutlet var compositeTypeActionButton : NSButton!
    @IBOutlet var popover : NSPopover!
    @IBOutlet var outlineView : NSOutlineView!
    @IBOutlet var nameColumn : NSTableColumn!
    @IBOutlet var valueColumn : NSTableColumn!
    @IBOutlet var comboBoxDataSource : PSVariableTypeComboBoxDelegate!
    var propertiesController : PSVariablePropertiesController!
    @IBOutlet var addDeleteSegmentedControl : NSSegmentedControl!
    @IBOutlet var applyButton : NSButton!
    
    //MARK: Actions
    
    @IBAction func compositeTypeButtonPressed(_: AnyObject) {
        
        let scriptData = propertiesController.scriptData
        let typeEntry = scriptData.getOrCreateSubEntry("Type", entry: propertiesController.entry, isProperty: true)
        
        let namedType = EntryToVariableNamedType(typeEntry, scriptData: propertiesController.scriptData)
        variableType = namedType.type
        comboBoxDataSource.refreshController = refresh
        refresh()
        popover.showRelativeToRect(compositeTypeActionButton.bounds, ofView: compositeTypeActionButton, preferredEdge: NSRectEdge.MinY)
    }
    
    @IBAction func applyButtonPressed(_: AnyObject) {
        updateScript()
    }
    
    //MARK: Setup / refresh
    
    func refresh(selectItem: AnyObject? = nil) {
        
        //the reason for doing this, is that sometimes combo boxes delegate get fired, during reloadData, when the first responder changes, causing nested reload datas.
        if !refreshing {
            refreshing = true
            comboBoxDataSource.refreshWithVariableTypeNames(GetVariableTypeNames(propertiesController.scriptData))
        
       
            outlineView.reloadData()
            outlineView.expandItem(nil, expandChildren: true) //expand all items
            
            //if provided, select the given item
            if let selectItem: AnyObject = selectItem {
                let rowForItem = self.outlineView.rowForItem(selectItem)
                if rowForItem != -1 {
                    self.outlineView.selectRowIndexes(NSIndexSet(index: rowForItem), byExtendingSelection: false)
                }
            }
            refreshing = false
        }
    }
    
    //MARK: Update script
    
    func updateScript() {
        let scriptData = propertiesController.scriptData
        scriptData.beginUndoGrouping("Update Variable Type")
        let typeEntry = scriptData.getOrCreateSubEntry("Type", entry: propertiesController.entry, isProperty: true)
        VariableTypeToEntry(variableType, entry: typeEntry, scriptData: scriptData)
        scriptData.endUndoGrouping(true)
        
    }
    
    //MARK: OutlineView Data source
    
    func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
        
        if item == nil {
            return 1
        }
        
        var typeEnum : PSVariableTypeEnum = .StringType
        
        if let variableNamedType = item as? PSVariableNamedType {
            typeEnum = variableNamedType.type.type
        } else if let variableType = item as? PSVariableType {
            typeEnum = variableType.type
        } else {
            fatalError("Non nil items with children should be PSVariableNamedType or PSVariableType")
        }
        
        switch(typeEnum) {
        case .Array(_):
            return 1
        case let .Record(variableRecord):
            return variableRecord.fields.count
        default:
            return 0
        }
    }
    
    func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        if item == nil {
            return variableType
        }
        
        var typeEnum : PSVariableTypeEnum = .StringType
        
        if let variableNamedType = item as? PSVariableNamedType {
            typeEnum = variableNamedType.type.type
        } else if let variableType = item as? PSVariableType {
            typeEnum = variableType.type
        } else {
            fatalError("Non nil items with children should be PSVariableNamedType or PSVariableType")
        }
        
        switch(typeEnum) {
        case let .Array(variableArray):
            return variableArray.type
        case let .Record(variableRecord):
            return variableRecord.fields[index]
        default:
            fatalError("Children should only appear for arrays and records")
        }
        
        
        
    }
    
    func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
        return (self.outlineView(outlineView, numberOfChildrenOfItem: item) > 0)
    }
    
    func outlineView(outlineView: NSOutlineView, objectValueForTableColumn tableColumn: NSTableColumn?, byItem item: AnyObject?) -> AnyObject? {
        if tableColumn == nameColumn {
            
            if let variableNamedType = item as? PSVariableNamedType {
                return variableNamedType.name
            } else if let _ = item as? PSVariableType {
                return "Type"
            } else {
                fatalError("Items with values should be PSVariableNamedType or PSVariableType")
            }
            
        } else if tableColumn == valueColumn {
            
            var typeEnum : PSVariableTypeEnum = .StringType
            
            if let variableNamedType = item as? PSVariableNamedType {
                typeEnum = variableNamedType.type.type
            } else if let variableType = item as? PSVariableType {
                typeEnum = variableType.type
            } else {
                fatalError("Items with values should be PSVariableNamedType or PSVariableType")
            }
            
            switch(typeEnum) {
            case .IntegerType:
                return "Integer"
            case .LongIntegerType:
                return "Long_Integer"
            case .FloatType:
                return "Float"
            case .DoubleType:
                return "Double"
            case .StringType:
                return "String"
            case let .Defined(defined):
                return defined
            case let .Array(variableArray):
                return "Array[\(variableArray.count)]"
            case .Record(_):
                return "Record"
            }
            
        }
        
        
        fatalError("Column should be name or value column, and items with values should be PSVariableNamedType or PSVariableType ")
    }
    
    
    
    //MARK: OutlineView Datasource (dragging)
    
    
    //MARK: OutlineViewDelegate
    
    func outlineView(outlineView: NSOutlineView, viewForTableColumn tableColumn: NSTableColumn?, item: AnyObject) -> NSView? {
        if tableColumn == nameColumn {
            let view = outlineView.makeViewWithIdentifier(tableColumn!.identifier, owner: nil) as! PSVariableTypeTextFieldCellView
            if let variableNamedType = item as? PSVariableNamedType {
                view.item = variableNamedType
                view.textField!.editable = true
                view.textField!.font = NSFont.boldSystemFontOfSize(12)
            } else {
                view.item = nil
                view.textField!.editable = false
                view.textField!.font = NSFont.systemFontOfSize(11)
            }
            
            return view
        } else if tableColumn == valueColumn {
            let view = outlineView.makeViewWithIdentifier(tableColumn!.identifier, owner: nil) as! PSVariableTypeComboBoxTableCellView
            view.item = item
            view.comboBox.dataSource = comboBoxDataSource
            view.comboBox.setDelegate(comboBoxDataSource)
            view.comboBox.reloadData()
            
            return view
        }
        
        fatalError("Unknown column type")
    }
    
    func outlineViewSelectionDidChange(notification: NSNotification) {
        //adjust segmented control
    }
    
    //MARK: Segmented Controls actions
    
    @IBAction func addDeleteSegmentedControlPressed(_: AnyObject) {
        switch(addDeleteSegmentedControl.selectedSegment) {
        case 0:
            //add
            addNewVariableType()
        case 1:
            //remove
            deleteVariableType()
            break
        default:
            break
        }
    }
    
    func addNewVariableType() {
        
        //if it's a record then add as a child...
        if outlineView.selectedRow > -1 {
            let item : AnyObject? = outlineView.itemAtRow(outlineView.selectedRow)
            
            var typeOfRow : PSVariableTypeEnum = .StringType //temp value
            
            if let namedType = item as? PSVariableNamedType {
                typeOfRow = namedType.type.type
            } else if let variableType = item as? PSVariableType {
                typeOfRow = variableType.type
            }
            
            switch(typeOfRow) {
            case .Record(let recordVariable):
                let newField = PSVariableNamedType(name: "NewField", type: PSVariableType())
                recordVariable.fields.append(newField)
                refresh(item)
                return
            default:
                break
            }
        }
        
        //not record so do nothing...
    }
    
    func deleteVariableType() {
        if outlineView.selectedRow > -1 {
            let item : AnyObject? = outlineView.itemAtRow(outlineView.selectedRow)
            let parent : AnyObject? = outlineView.parentForItem(item)
            
            if let namedType = item as? PSVariableNamedType {
                if parent != nil {
                    //should be a field
                    var typeOfRow : PSVariableTypeEnum = .StringType //temp value
                    if let variableNamedType = parent as? PSVariableNamedType {
                        typeOfRow = variableNamedType.type.type
                    } else if let variableType = parent as? PSVariableType {
                        typeOfRow = variableType.type
                    }
                    
                    switch(typeOfRow) {
                    case .Record(let recordVariable):
                        _ = PSVariableNamedType(name: "NewField", type: PSVariableType())
                        recordVariable.fields = recordVariable.fields.filter({ $0 !== namedType })
                        
                        refresh(namedType)
                        return
                    default:
                        break
                    }
                }
            }
        }
        refresh()
    }
    
}