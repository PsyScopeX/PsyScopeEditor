//
//  PSVariableTypeOutlineViewDelegate.swift
//  PsyScopeEditor
//
//  Created by James on 21/04/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSVariableTypeOutlineViewDelegate : NSObject, NSOutlineViewDataSource, NSOutlineViewDelegate {
    
    let draggedType = "PSVariableTypeOutlineView"
    
    var variableTypes : PSVariableTypes = PSVariableTypes(types: [])
    var initialSetupComplete = false
    var expandedItems : [AnyObject] = []
    
    //MARK: Outlets
    @IBOutlet var outlineView : NSOutlineView!
    @IBOutlet var nameColumn : NSTableColumn!
    @IBOutlet var valueColumn : NSTableColumn!
    @IBOutlet var comboBoxDataSource : PSVariableTypeComboBoxDelegate!
    
    //MARK: Setup / refresh
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if (!initialSetupComplete) {
            initialSetupComplete = true
            outlineView.registerForDraggedTypes([draggedType])
            outlineView.reloadData()
        }
    }

    
    func refreshWithVariableTypes(types : PSVariableTypes, selectItem: AnyObject? = nil) {
        self.variableTypes = types
        outlineView.reloadData()
        
        //if an item is selected (e.g record / array) make sure it is expanded
        if let selectItem: AnyObject = selectItem {
            expandedItems.append(selectItem)
        }
        
        
        expandedItems.forEach {
            self.outlineView.expandItem( $0 )
        }
        
        if let selectItem: AnyObject = selectItem {
            let rowForItem = self.outlineView.rowForItem(selectItem)
            if rowForItem != -1 {
                self.outlineView.selectRowIndexes(NSIndexSet(index: rowForItem), byExtendingSelection: false)
            }
        }
    }
    
    //MARK: OutlineView Data source
    
    func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
        if item == nil {
            return variableTypes.types.count
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
        case .Array:
            return 1
        case let .Record(variableRecord):
            return variableRecord.fields.count
        default:
            return 0
        }
    }
    
    func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        if item == nil {
            return variableTypes.types[index]
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
            } else if item is PSVariableType {
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
            case .Record:
                return "Record"
            }
            
        }
        
        
        fatalError("Column should be name or value column, and items with values should be PSVariableNamedType or PSVariableType ")
    }
    
    
    func outlineView(outlineView: NSOutlineView, shouldExpandItem item: AnyObject) -> Bool {
        expandedItems.append(item)
        return true
    }
    
    func outlineView(outlineView: NSOutlineView, shouldCollapseItem item: AnyObject) -> Bool {
        var newExpandedItems : [AnyObject] = []
        for obj in expandedItems {
            if obj !== item {
                newExpandedItems.append(obj)
            }
        }
        expandedItems = newExpandedItems
        return true
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
    

    
}