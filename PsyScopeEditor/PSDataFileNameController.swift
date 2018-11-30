//
//  PSDataFileNameController.swift
//  PsyScopeEditor
//
//  Created by James on 17/06/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

/*
 * PSDataFileNameController: Loaded by ExperimentSetup.xib.  Controls everything to do with setting the DataFile's name (either automatically generated or custom)
 *
 */
class PSDataFileNameController : NSObject, NSTokenFieldDelegate, NSTextFieldDelegate {
    
    //MARK: Outlets
    
    @IBOutlet var tokenField : NSTokenField!
    @IBOutlet var currentDataFileNamePreview : NSTextField!
    @IBOutlet var autoGenerateCheckButton : NSButton!
    
    //MARK: Variables
    var tokenCount : Int = 0
    var layoutManager : NSLayoutManager? = nil
    var subjectVariableNames : [String] = []
    var scriptData : PSScriptData! //gets populated by subjectvariablescontroller
    var autoDataFile : PSAutoDataFile!
    
    //MARK: Constants
    
    let bannedCharacters : CharacterSet
    
    //MARK: Setup
    
    override init() {
        let toBeBanned = NSMutableCharacterSet.alphanumeric()
        toBeBanned.addCharacters(in: "-_")
        bannedCharacters = toBeBanned.inverted
        super.init()
    }
    
    //MARK: Refresh
    
    func reloadData(_ variables : [PSSubjectVariable]) { // called by PSSubjectVariablesController's refresh
        
        //update list of tokens
        subjectVariableNames = variables.map { $0.name }
        
        //set autodatafile object
        autoDataFile = PSAutoDataFile(scriptData: scriptData, subjectVariableNames: subjectVariableNames)
        
        if autoDataFile.auto {
            autoGenerateCheckButton.state = NSControl.StateValue.on
        } else {
            autoGenerateCheckButton.state = NSControl.StateValue.off
            subjectVariableNames = []  //reset token list for auto completion...
        }
        
        tokenField.objectValue = autoDataFile.autoDataFileElements
        tokenField.tokenizingCharacterSet = nil

    }
    
    //MARK: NSTokenFieldDelegate
    
    // Each element in the array should be an NSString or an array of NSStrings.
    // substring is the partial string that is being completed.  tokenIndex is the index of the token being completed.
    // selectedIndex allows you to return by reference an index specifying which of the completions should be selected initially.
    // The default behavior is not to have any completions.
    
    func tokenField(_ tokenField: NSTokenField, completionsForSubstring substring: String, indexOfToken tokenIndex: Int, indexOfSelectedItem selectedIndex: UnsafeMutablePointer<Int>?) -> [Any]? {
        
        let completions = subjectVariableNames.filter({ name in name.lowercased().hasPrefix(substring.lowercased()) })
        return completions
    }
    
    // return an array of represented objects you want to add.
    // If you want to reject the add, return an empty array.
    // returning nil will cause an error.
    func tokenField(_ tokenField: NSTokenField, shouldAdd tokens: [Any], at index: Int) -> [Any] {
        for token in tokens {
            if let stringToken = token as? String {
                if stringToken.rangeOfCharacter(from: bannedCharacters) != nil {
                    return []
                }
            }
        }
        return tokens
    }
    
    
    func tokenField(_ tokenField: NSTokenField, displayStringForRepresentedObject representedObject: Any) -> String? {
        let token = representedObject as! String
        
        if subjectVariableNames.contains(token) {
            return "[\(token)]"
        } else {
            return token
        }
    }
    
    func tokenField(_ tokenField: NSTokenField, editingStringForRepresentedObject representedObject: Any) -> String? {
        return representedObject as? String
    }
    
    func tokenField(_ tokenField: NSTokenField, representedObjectForEditing editingString: String) -> (Any)? {
        let cleanEditingString = editingString.components(separatedBy: bannedCharacters).joined(separator: "")
        return cleanEditingString
    }
    
    

    func tokenField(_ tokenField: NSTokenField, styleForRepresentedObject representedObject: Any) -> NSTokenField.TokenStyle {
        if autoGenerateCheckButton.state.rawValue == 1 {
            return NSTokenField.TokenStyle.rounded
        } else {
            return NSTokenField.TokenStyle.none
        }
    }
    
    //MARK: NSTextFieldDelegate
    
    func controlTextDidChange(_ obj: Notification) {
        updatePreviewTextView()
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
        updatePreviewTextView()
        updateAutoDataFileScriptEntry()
    }
    
    func control(_ control: NSControl, textShouldBeginEditing fieldEditor: NSText) -> Bool {
        scriptData.beginUndoGrouping("Edit DataFile Name")
        self.layoutManager = (fieldEditor as! NSTextView).layoutManager
        return true
    }
    
    func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        scriptData.endUndoGrouping()
        return true
    }
    
    //MARK: Update methods
    
    func updateAutoDataFileScriptEntry() {
        scriptData.beginUndoGrouping("Update DataFile Name")
        autoDataFile.auto = (autoGenerateCheckButton.state.rawValue == 1)
        if let stringArray = tokenField.objectValue as? [String] {
            autoDataFile.autoDataFileElements = stringArray
        } else {
            autoDataFile.autoDataFileElements = []
        }
        scriptData.endUndoGrouping()
    }
    
    func updatePreviewTextView() {
        currentDataFileNamePreview.stringValue = autoDataFile.generateCurrentDataFileName()
    }
    
    
    //MARK: Auto generate check box
    
    @IBAction func autoGenerateCheckButtonClicked(_ sender : AnyObject) {
        updateAutoDataFileScriptEntry()
    }
}

