//
//  PSVariableViewController.swift
//  PsyScopeEditor
//
//  Created by James on 30/01/2015.
//

import Foundation

let PSVariableTypesAllowedInDataFile = ["Integer","Long_Integer", "Float", "Double", "String"]

class PSVariablePropertiesController : PSToolPropertyController {
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(entry : Entry, scriptData : PSScriptData) {
        let bundle = Bundle(for:type(of: self))
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
        typePopup.addItems(withTitles: GetVariableTypeNames(scriptData))
        
        //Parse entry type
        var type = "Integer"
        if let typeEntry = scriptData.getSubEntry("Type", entry: entry) {
            type = typeEntry.currentValue
        }
        typePopup.selectItem(withTitle: type)
        
        //Update composite type action button
        let enableCompositeTypeButton = (type == "Array" || type == "Record")
        compositeTypeActionButton.isEnabled = enableCompositeTypeButton

        
        //Parse update check
        updateCheck.state = NSControl.StateValue.off
        if let updateEntry = scriptData.getSubEntry("Update", entry: entry) {
            if updateEntry.currentValue == "TRUE" {
                updateCheck.state = NSControl.StateValue.on
            }
        }
        
        //Parse init check
        initCheck.state = NSControl.StateValue.off
        if let _ = scriptData.getSubEntry("Init", entry: entry) {
            initCheck.state = NSControl.StateValue.on
        }
        
        //check if variable is allowed in datafile
        if PSVariableTypesAllowedInDataFile.contains(type) {
            //Parse datafile check
            dataFileCheck.isEnabled = true
            dataFileCheck.state = NSControl.StateValue.off
            let experimentEntry = scriptData.getMainExperimentEntry()
            if let dataVariables = scriptData.getSubEntry("DataVariables", entry: experimentEntry) {
                let dataVariablesList = PSStringList(entry: dataVariables, scriptData: scriptData)
                if dataVariablesList.contains(entry.name) {
                    dataFileCheck.state = NSControl.StateValue.on
                }
            }
        } else {
            dataFileCheck.isEnabled = false
            dataFileCheck.state = NSControl.StateValue.off
        }
        
        
        
        //Parse currentValue into outlineView
        outlineViewController.refreshWithEntry(entry, editInitialValues:initCheck.state.rawValue == 1 )
        
    }
    
    //MARK: Actions / Control delegate
    
    @IBAction func editTypesButton(_: AnyObject) {
        let typesPopup = PSVariableTypePopup(scriptData: scriptData)
        typesPopup.showPopup()
    }
    
    
    @IBAction func updateEntry(_ sender : AnyObject) {
        scriptData.beginUndoGrouping("Update Variable")
        
        let typeEntry = scriptData.getOrCreateSubEntry("Type", entry: entry, isProperty: true)
        let typeName = typePopup.selectedItem!.title
        if typeEntry.currentValue != typeName {
            
            //type was changed - remove from datafile if not allowed
            if !PSVariableTypesAllowedInDataFile.contains(typeName) {
                dataFileCheck.state = NSControl.StateValue.off
                dataFileCheck.isEnabled = false
            }
            
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
        if updateCheck.state.rawValue == 1 {
            updateEntry.currentValue = "TRUE"
        } else {
            updateEntry.currentValue = "FALSE"
        }
        
        if initCheck.state.rawValue == 0 {
            scriptData.deleteNamedSubEntryFromParentEntry(entry, name: "Init")
        } else {
            scriptData.getOrCreateSubEntry("Init", entry: entry, isProperty: true)
        }
        
        let experimentEntry = scriptData.getMainExperimentEntry()
        
        if dataFileCheck.state.rawValue == 0 {
            //ensure it is not there
            
            if let dataVariables = scriptData.getSubEntry("DataVariables", entry: experimentEntry) {
                let dataVariablesList = PSStringList(entry: dataVariables, scriptData: scriptData) 
                dataVariablesList.remove(entry.name)
                if dataVariablesList.count == 0 {
                    scriptData.deleteSubEntryFromBaseEntry(experimentEntry, subEntry: dataVariables)
                }
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
