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
            outlineView.registerForDraggedTypes(convertToNSPasteboardPasteboardTypeArray([draggedType]))
            outlineView.reloadData()
        }
    }

    
    func refreshWithVariableTypes(_ types : PSVariableTypes, selectItem: AnyObject? = nil) {
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
            let rowForItem = self.outlineView.row(forItem: selectItem)
            if rowForItem != -1 {
                self.outlineView.selectRowIndexes(IndexSet(integer: rowForItem), byExtendingSelection: false)
            }
        }
    }
    
    //MARK: OutlineView Data source
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            return variableTypes.types.count
        }
        
        var typeEnum : PSVariableTypeEnum = .stringType
        
        if let variableNamedType = item as? PSVariableNamedType {
            typeEnum = variableNamedType.type.type
        } else if let variableType = item as? PSVariableType {
            typeEnum = variableType.type
        } else {
            fatalError("Non nil items with children should be PSVariableNamedType or PSVariableType")
        }
        
        switch(typeEnum) {
        case .array:
            return 1
        case let .record(variableRecord):
            return variableRecord.fields.count
        default:
            return 0
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
            return variableTypes.types[index]
        }
        
        var typeEnum : PSVariableTypeEnum = .stringType
        
        if let variableNamedType = item as? PSVariableNamedType {
            typeEnum = variableNamedType.type.type
        } else if let variableType = item as? PSVariableType {
            typeEnum = variableType.type
        } else {
            fatalError("Non nil items with children should be PSVariableNamedType or PSVariableType")
        }
        
        switch(typeEnum) {
        case let .array(variableArray):
            return variableArray.type
        case let .record(variableRecord):
            return variableRecord.fields[index]
        default:
            fatalError("Children should only appear for arrays and records")
        }
        
        
    
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return (self.outlineView(outlineView, numberOfChildrenOfItem: item) > 0)
    }
    
    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        if tableColumn == nameColumn {

            if let variableNamedType = item as? PSVariableNamedType {
                return variableNamedType.name
            } else if item is PSVariableType {
                return "Type"
            } else {
                fatalError("Items with values should be PSVariableNamedType or PSVariableType")
            }
            
        } else if tableColumn == valueColumn {
        
            var typeEnum : PSVariableTypeEnum = .stringType
            
            if let variableNamedType = item as? PSVariableNamedType {
                typeEnum = variableNamedType.type.type
            } else if let variableType = item as? PSVariableType {
                typeEnum = variableType.type
            } else {
                fatalError("Items with values should be PSVariableNamedType or PSVariableType")
            }
            
            switch(typeEnum) {
            case .integerType:
                return "Integer"
            case .longIntegerType:
                return "Long_Integer"
            case .floatType:
                return "Float"
            case .doubleType:
                return "Double"
            case .stringType:
                return "String"
            case let .defined(defined):
                return defined
            case let .array(variableArray):
                return "Array[\(variableArray.count)]"
            case .record:
                return "Record"
            }
            
        }
        
        
        fatalError("Column should be name or value column, and items with values should be PSVariableNamedType or PSVariableType ")
    }
    
    
    func outlineView(_ outlineView: NSOutlineView, shouldExpandItem item: Any) -> Bool {
        expandedItems.append(item as AnyObject)
        return true
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldCollapseItem item: Any) -> Bool {
        var newExpandedItems : [AnyObject] = []
        for obj in expandedItems {
            if obj !== item as AnyObject {
                newExpandedItems.append(obj)
            }
        }
        expandedItems = newExpandedItems
        return true
    }
    
    //MARK: OutlineView Datasource (dragging)
    
    
    //MARK: OutlineViewDelegate
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        if tableColumn == nameColumn {
            let view = outlineView.makeView(withIdentifier: tableColumn!.identifier, owner: nil) as! PSVariableTypeTextFieldCellView
            if let variableNamedType = item as? PSVariableNamedType {
                view.item = variableNamedType
                view.textField!.isEditable = true
                view.textField!.font = NSFont.boldSystemFont(ofSize: 12)
            } else {
                view.item = nil
                view.textField!.isEditable = false
                view.textField!.font = NSFont.systemFont(ofSize: 11)
            }
            
            return view
        } else if tableColumn == valueColumn {
            let view = outlineView.makeView(withIdentifier: tableColumn!.identifier, owner: nil) as! PSVariableTypeComboBoxTableCellView
            view.item = item as AnyObject
            view.comboBox.dataSource = comboBoxDataSource
            view.comboBox.delegate = comboBoxDataSource
            view.comboBox.reloadData()
            
            return view
        }
        
        fatalError("Unknown column type")
    }
    

    
}
