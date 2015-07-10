//
//  PSVariableViewController.swift
//  PsyScopeEditor
//
//  Created by James on 30/01/2015.
//

import Foundation


class PSVariablePropertiesController : PSToolPropertyController {
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(entry : Entry, scriptData : PSScriptData) {
        let bundle = NSBundle(forClass:self.dynamicType)
        super.init(nibName: "VariableView", bundle: bundle, entry: entry, scriptData: scriptData)
        self.entry = entry
    }
    
    //MARK: Outlets
    @IBOutlet var dataFileCheck : NSButton!
    @IBOutlet var initCheck : NSButton!
    @IBOutlet var updateCheck : NSButton!
    @IBOutlet var typePopup : NSPopUpButton!
    @IBOutlet var outlineViewController : PSVariableOutlineViewController!
    @IBOutlet var compositeTypeActionButton : NSButton!
    
    //MARK: Setup
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateUI()
    }
    
    //MARK: Document change
    
    override func refresh() {
        super.refresh()
        updateUI()
    }
    
    func updateUI() {
        //Update variable types
        typePopup.removeAllItems()
        typePopup.addItemsWithTitles(GetVariableTypeNames(scriptData))
        
        //Parse entry type
        var type = "Integer"
        if let typeEntry = scriptData.getSubEntry("Type", entry: entry) {
            type = typeEntry.currentValue
        }
        typePopup.selectItemWithTitle(type)
        
        //Update composite type action button
        let enableCompositeTypeButton = (type == "Array" || type == "Record")
        compositeTypeActionButton.enabled = enableCompositeTypeButton

        
        //Parse update check
        updateCheck.state = 0
        if let updateEntry = scriptData.getSubEntry("Update", entry: entry) {
            if updateEntry.currentValue == "TRUE" {
                updateCheck.state = 1
            }
        }
        
        //Parse init check
        initCheck.state = 0
        if let _ = scriptData.getSubEntry("Init", entry: entry) {
            initCheck.state = 1
        }
        
        //Parse datafile check
        dataFileCheck.state = 0
        let experimentEntry = scriptData.getMainExperimentEntry()
        if let dataVariables = scriptData.getSubEntry("DataVariables", entry: experimentEntry) {
                let dataVariablesList = PSStringList(entry: dataVariables, scriptData: scriptData)
                if dataVariablesList.contains(entry.name) {
                    dataFileCheck.state = 1
                }
        }
        
        //Parse currentValue into outlineView
        outlineViewController.refreshWithEntry(entry, editInitialValues:initCheck.state == 1 )
        
    }
    
    //MARK: Actions / Control delegate
    
    @IBAction func editTypesButton(AnyObject) {
        let typesPopup = PSVariableTypePopup(scriptData: scriptData)
        typesPopup.showPopup()
    }
    
    
    @IBAction func updateEntry(sender : AnyObject) {
        scriptData.beginUndoGrouping("Update Variable")
        
        let typeEntry = scriptData.getOrCreateSubEntry("Type", entry: entry, isProperty: true)
        let typeName = typePopup.selectedItem!.title
        if typeEntry.currentValue != typeName {
            typeEntry.currentValue = typeName
            
            for subEntry in entry.subEntries.array as! [Entry] {
                if subEntry.name != "Type" {
                    scriptData.deleteSubEntryFromBaseEntry(entry, subEntry: subEntry)
                }
            }
            
            if (typeName == "Array" || typeName == "Record") {
                
                //populate with a blank 
                if typeName == "Array" {
                    VariableTypeToEntry(PSVariableType.Array(PSVariableArray()), entry: typeEntry, scriptData: scriptData)
                } else {
                    VariableTypeToEntry(PSVariableType.Record(PSVariableRecord(fields: [])), entry: typeEntry, scriptData: scriptData)
                }
                
                compositeTypeActionButton.performClick(self)
                
            } else {
                //calculate the full variable type
                let type = TypeEntryToFullVariableType(typeEntry, scriptData: scriptData)
                
                //create new VariableValues structure
                let values = PSVariableValuesFromVariableType(entry.name, variableType: type!)
                
                //update structure of entry to match variable type
                UpdateEntryCurrentValuesWithVariableValues(entry, values: values, scriptData: scriptData)
            }
        }
        
        let updateEntry = scriptData.getOrCreateSubEntry("Update", entry: entry, isProperty: true)
        if updateCheck.state == 1 {
            updateEntry.currentValue = "TRUE"
        } else {
            updateEntry.currentValue = "FALSE"
        }
        
        if initCheck.state == 0 {
            scriptData.deleteNamedSubEntryFromParentEntry(entry, name: "Init")
        } else {
            scriptData.getOrCreateSubEntry("Init", entry: entry, isProperty: true)
        }
        
        let experimentEntry = scriptData.getMainExperimentEntry()
        
        if dataFileCheck.state == 0 {
            //ensure it is not there
            
            if let dataVariables = scriptData.getSubEntry("DataVariables", entry: experimentEntry) {
                let dataVariablesList = PSStringList(entry: dataVariables, scriptData: scriptData) 
                dataVariablesList.remove(entry.name)
            }
            
        } else {
            //ensure it is there

            let dataVariables = scriptData.getOrCreateSubEntry("DataVariables", entry: experimentEntry, isProperty: true)
            let dataVariablesList = PSStringList(entry: dataVariables, scriptData: scriptData)
            if !dataVariablesList.contains(entry.name) {
                dataVariablesList.appendAsString(entry.name)
            }
            
        }
        
        scriptData.endUndoGrouping(true)
    }
    

    
}
