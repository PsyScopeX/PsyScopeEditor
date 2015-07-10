//
//  PSToolPropertyController.swift
//  PsyScopeEditor
//
//  Created by James on 02/09/2014.
//

import Cocoa

public class PSToolPropertyController: PSPluginViewController, NSTextFieldDelegate {
    
    @IBOutlet var nameTextField : NSTextField!
    
    
    override public init(nibName nibNameOrNil: String, bundle nibBundleOrNil: NSBundle, entry : Entry, scriptData : PSScriptData) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil, entry: entry, scriptData: scriptData)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        refreshName()
    }
    
    public func control(control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        if (control == nameTextField) {
            let name = nameTextField.stringValue as String
            setObjectName(name)
        }
        return true
    }
    
    override public func refresh() {
        refreshName()
    }
    
    public func refreshName() {
        if nameTextField != nil {
            nameTextField.stringValue = entry.name
        } else {
            print("NO IBOUTLET SET FOR NAME: " + entry.name) //woops you forgot to set iboutlet
        }
        
    }
    
    
    public func setObjectName(new_name : String) {
        scriptData.beginUndoGrouping("Rename object")
        scriptData.renameEntry(entry, nameSuggestion: new_name)
        scriptData.endUndoGrouping(true)
        if (new_name != entry.name) {
            PSModalAlert("You cannot rename this object to \(new_name) as either an entry with this name already exists or it is an invalid entry name - entry has been given a temporary new name")
        }
        nameTextField.stringValue = entry.name
    }
    
    public func windowWillReturnUndoManager(window: NSWindow) -> NSUndoManager? {
        return scriptData.docMoc.undoManager
    }
    
}
