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
        let typeEntry = scriptData?.getOrCreateSubEntry("Type", entry: propertiesController.entry, isProperty: true)
        
        let namedType = EntryToVariableNamedType(typeEntry!, scriptData: propertiesController.scriptData)
        variableType = namedType.type
        comboBoxDataSource.refreshController = refresh
        refresh()
        popover.show(relativeTo: compositeTypeActionButton.bounds, of: compositeTypeActionButton, preferredEdge: NSRectEdge.minY)
    }
    
    @IBAction func applyButtonPressed(_: AnyObject) {
        updateScript()
    }
    
    //MARK: Setup / refresh
    
    func refresh(_ selectItem: AnyObject? = nil) {
        
        //the reason for doing this, is that sometimes combo boxes delegate get fired, during reloadData, when the first responder changes, causing nested reload datas.
        if !refreshing {
            refreshing = true
            comboBoxDataSource.refreshWithVariableTypeNames(GetVariableTypeNames(propertiesController.scriptData))
        
       
            outlineView.reloadData()
            outlineView.expandItem(nil, expandChildren: true) //expand all items
            
            //if provided, select the given item
            if let selectItem: AnyObject = selectItem {
                let rowForItem = self.outlineView.row(forItem: selectItem)
                if rowForItem != -1 {
                    self.outlineView.selectRowIndexes(IndexSet(integer: rowForItem), byExtendingSelection: false)
                }
            }
            refreshing = false
        }
    }
    
    //MARK: Update script
    
    func updateScript() {
        let scriptData = propertiesController.scriptData
        scriptData?.beginUndoGrouping("Update Variable Type")
        let typeEntry = scriptData?.getOrCreateSubEntry("Type", entry: propertiesController.entry, isProperty: true)
        VariableTypeToEntry(variableType, entry: typeEntry!, scriptData: scriptData!)
        scriptData?.endUndoGrouping(true)
        
    }
    
    //MARK: OutlineView Data source
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        
        if item == nil {
            return 1
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
        case .array(_):
            return 1
        case let .record(variableRecord):
            return variableRecord.fields.count
        default:
            return 0
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
            return variableType
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
            } else if let _ = item as? PSVariableType {
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
            case .record(_):
                return "Record"
            }
            
        }
        
        
        fatalError("Column should be name or value column, and items with values should be PSVariableNamedType or PSVariableType ")
    }
    
    
    
    //MARK: OutlineView Datasource (dragging)
    
    
    //MARK: OutlineViewDelegate
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        if tableColumn == nameColumn {
            let view = outlineView.make(withIdentifier: tableColumn!.identifier, owner: nil) as! PSVariableTypeTextFieldCellView
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
            let view = outlineView.make(withIdentifier: tableColumn!.identifier, owner: nil) as! PSVariableTypeComboBoxTableCellView
            view.item = item as AnyObject
            view.comboBox.dataSource = comboBoxDataSource
            view.comboBox.delegate = comboBoxDataSource
            view.comboBox.reloadData()
            
            return view
        }
        
        fatalError("Unknown column type")
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
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
            let item : AnyObject? = outlineView.item(atRow: outlineView.selectedRow) as AnyObject
            
            var typeOfRow : PSVariableTypeEnum = .stringType //temp value
            
            if let namedType = item as? PSVariableNamedType {
                typeOfRow = namedType.type.type
            } else if let variableType = item as? PSVariableType {
                typeOfRow = variableType.type
            }
            
            switch(typeOfRow) {
            case .record(let recordVariable):
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
            let item : AnyObject? = outlineView.item(atRow: outlineView.selectedRow) as AnyObject
            let parent : AnyObject? = outlineView.parent(forItem: item) as AnyObject
            
            if let namedType = item as? PSVariableNamedType {
                if parent != nil {
                    //should be a field
                    var typeOfRow : PSVariableTypeEnum = .stringType //temp value
                    if let variableNamedType = parent as? PSVariableNamedType {
                        typeOfRow = variableNamedType.type.type
                    } else if let variableType = parent as? PSVariableType {
                        typeOfRow = variableType.type
                    }
                    
                    switch(typeOfRow) {
                    case .record(let recordVariable):
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
