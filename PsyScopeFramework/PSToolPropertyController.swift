//
//  PSToolPropertyController.swift
//  PsyScopeEditor
//
//  Created by James on 02/09/2014.
//

import Cocoa

open class PSToolPropertyController: PSPluginViewController, NSTextFieldDelegate {
    
    @IBOutlet var nameTextField : NSTextField!
    
    
    override public init(nibName nibNameOrNil: String, bundle nibBundleOrNil: Bundle, entry : Entry, scriptData : PSScriptData) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil, entry: entry, scriptData: scriptData)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        refreshName()
    }
    
    open func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        if (control == nameTextField) {
            let name = nameTextField.stringValue as String
            setObjectName(name)
        }
        return true
    }
    
    override open func refresh() {
        refreshName()
    }
    
    open func refreshName() {
        if nameTextField != nil {
            nameTextField.stringValue = entry.name
        } else {
            print("NO IBOUTLET SET FOR NAME: " + entry.name) //woops you forgot to set iboutlet
        }
        
    }
    
    
    open func setObjectName(_ new_name : String) {
        scriptData.beginUndoGrouping("Rename object")
        let success = scriptData.renameEntry(entry, nameSuggestion: new_name)
        scriptData.endUndoGrouping(success)
        if (new_name != entry.name) {
            PSModalAlert("You cannot rename this object to \(new_name) as either an entry with this name already exists or it is an invalid entry name (too small / long / incorrect characters) - entry has been given a temporary new name")
        }
        nameTextField.stringValue = entry.name
    }
    
    open func windowWillReturnUndoManager(_ window: NSWindow) -> UndoManager? {
        return scriptData.docMoc.undoManager
    }
    
}
