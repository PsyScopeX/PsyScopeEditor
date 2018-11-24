//
//  PSVariableTypeController.swift
//  PsyScopeEditor
//
//  Created by James on 22/04/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation



class PSVariableTypeController : NSObject {
    
    //MARK: Outlets
    @IBOutlet var outlineViewDelegate : PSVariableTypeOutlineViewDelegate!
    @IBOutlet var comboBoxDelegate : PSVariableTypeComboBoxDelegate!
    @IBOutlet var popupController : PSVariableTypePopup!
    @IBOutlet var addDeleteSegmentedControl : NSSegmentedControl!
    
    //MARK: Variables
    var scriptData : PSScriptData!
    var variableTypes : PSVariableTypes = PSVariableTypes(types: [])
    
    
    //MARK: Start / Refresh
    
    override func awakeFromNib() {
        super.awakeFromNib()
        scriptData = popupController.scriptData
        variableTypes = GetCustomVariableTypes(popupController.scriptData)
        comboBoxDelegate.refreshController = refresh
        refresh()
    }
    
    func refresh(_ selectItem : AnyObject? = nil) {
        
        comboBoxDelegate.refreshWithVariableTypeNames(GetVariableTypeNames(variableTypes))
        outlineViewDelegate.refreshWithVariableTypes(variableTypes, selectItem: selectItem)
    }
    
    
    //MARK: Update script
    
    func updateScript() {
        
        scriptData.beginUndoGrouping("Update Variable Type")
        
        // remove existint Types
        let existingTypes = GetCustomVariableTypes(scriptData).types
        
        for type in existingTypes {
            if let entryToDelete = scriptData.getBaseEntry( type.name ) {
                scriptData.deleteMainEntry(entryToDelete)
            }
        }
        
        //add updated set
        for newType in variableTypes.types {
            
            if scriptData.getBaseEntryNames().contains(newType.name) {
                newType.name = scriptData.getNextFreeBaseEntryName(newType.name)
            }
            
            let entry = scriptData.getOrCreateBaseEntry(newType.name, type: PSType.Variable)
            
            VariableNamedTypeToEntry(newType, entry: entry, scriptData: scriptData)
        }
        
        //update expTypes variable
        let newTypeNames : [String] = variableTypes.types.map({ $0.name })

        let expEntry = scriptData.getMainExperimentEntry()
        let expVariables = scriptData.getOrCreateSubEntry("ExpTypes", entry: expEntry, isProperty: true)
        
        let list = PSStringList(entry: expVariables, scriptData: scriptData)
        
        list.stringListRawUnstripped = newTypeNames
        

        
        scriptData.endUndoGrouping(true)
        
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
        if outlineViewDelegate.outlineView.selectedRow > -1 {
            let item : AnyObject? = outlineViewDelegate.outlineView.item(atRow: outlineViewDelegate.outlineView.selectedRow) as AnyObject
            
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
        
        //not a record so jsut add new variable type
        
        let name = "CustomType"
        variableTypes.types.append(PSVariableNamedType(name: name, type: PSVariableType()))
        refresh()
    }
    
    func deleteVariableType() {
        if outlineViewDelegate.outlineView.selectedRow > -1 {
            let item : AnyObject? = outlineViewDelegate.outlineView.item(atRow: outlineViewDelegate.outlineView.selectedRow) as AnyObject
            let parent : AnyObject? = outlineViewDelegate.outlineView.parent(forItem: item) as AnyObject
            
            if let namedType = item as? PSVariableNamedType {
                if parent == nil {
                    variableTypes.types = variableTypes.types.filter({ $0 !== namedType })
                } else {
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
