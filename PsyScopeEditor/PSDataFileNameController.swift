//
//  PSDataFileNameController.swift
//  PsyScopeEditor
//
//  Created by James on 17/06/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSDataFileNameController : NSObject, NSTokenFieldDelegate {
    
    @IBOutlet var tokenField : NSTokenField!
    @IBOutlet var currentDataFileNamePreview : NSTextField!
    @IBOutlet var autoGenerateCheckButton : NSButton!
    
    var tokenCount : Int = 0
    var layoutManager : NSLayoutManager? = nil
    var subjectVariableNames : [String] = []
    var scriptData : PSScriptData! //gets populated by subjectvariablescontroller
    var autoDataFile : PSAutoDataFile!
    
    func reloadData(variables : [PSSubjectVariable]) {
        
        //update list of tokens
        subjectVariableNames = variables.map { $0.name }
        
        //set autodatafile object
        autoDataFile = PSAutoDataFile(scriptData: scriptData, subjectVariableNames: subjectVariableNames)
        
        if autoDataFile.auto {
            autoGenerateCheckButton.state = 1
        } else {
            autoGenerateCheckButton.state = 0
            subjectVariableNames = []  //reset token list for auto completion...
        }
        
        tokenField.objectValue = autoDataFile.autoDataFileElements
        tokenField.tokenizingCharacterSet = nil

    }
    
    // Each element in the array should be an NSString or an array of NSStrings.
    // substring is the partial string that is being completed.  tokenIndex is the index of the token being completed.
    // selectedIndex allows you to return by reference an index specifying which of the completions should be selected initially.
    // The default behavior is not to have any completions.
    func tokenField(tokenField: NSTokenField, completionsForSubstring substring: String, indexOfToken tokenIndex: Int, indexOfSelectedItem selectedIndex: UnsafeMutablePointer<Int>) -> [AnyObject]? {
        let completions = subjectVariableNames.filter({ name in name.lowercaseString.hasPrefix(substring.lowercaseString) })
        return completions
    }
    
    // return an array of represented objects you want to add.
    // If you want to reject the add, return an empty array.
    // returning nil will cause an error.
    func tokenField(tokenField: NSTokenField, shouldAddObjects tokens: [AnyObject], atIndex index: Int) -> [AnyObject] {
        return tokens
    }
    
    func tokenField(tokenField: NSTokenField, displayStringForRepresentedObject representedObject: AnyObject) -> String? {
        let token = representedObject as! String
        
        if subjectVariableNames.contains(token) {
            return "[\(token)]"
        } else {
            return token
        }
    }
    func tokenField(tokenField: NSTokenField, editingStringForRepresentedObject representedObject: AnyObject) -> String? {
        return representedObject as? String
    }
    func tokenField(tokenField: NSTokenField, representedObjectForEditingString editingString: String) -> AnyObject {
        return editingString
    }

    func tokenField(tokenField: NSTokenField, styleForRepresentedObject representedObject: AnyObject) -> NSTokenStyle {
        if autoGenerateCheckButton.state == 1 {
            return NSTokenStyle.Rounded
        } else {
            return NSTokenStyle.None
        }
    }
    
    override func controlTextDidChange(obj: NSNotification) {
        updatePreviewTextView()
    }
    
    override func controlTextDidEndEditing(obj: NSNotification) {
        updatePreviewTextView()
        updateAutoDataFileScriptEntry()
    }
    
    func updateAutoDataFileScriptEntry() {
        scriptData.beginUndoGrouping("Update DataFile Name")
        autoDataFile.auto = (autoGenerateCheckButton.state == 1)
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
    
    func control(control: NSControl, textShouldBeginEditing fieldEditor: NSText) -> Bool {
        scriptData.beginUndoGrouping("Edit DataFile Name")
        self.layoutManager = (fieldEditor as! NSTextView).layoutManager
        return true
    }
    
    func control(control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        scriptData.endUndoGrouping()
        return true
    }
    
    func countAttachmentsInAttributedString(attributedString : NSAttributedString) -> Int {
        let string : NSString = attributedString.string
        let maxIndex = string.length - 1
        var counter : Int = 0
        
        if maxIndex >= 0 {
            for i in 0...maxIndex {
                if string.characterAtIndex(i) == unichar(NSAttachmentCharacter) {
                    counter++
                }
            }
        }
        
        return counter
    }

    
    //MARK: Auto generate check box
    
    @IBAction func autoGenerateCheckButtonClicked(sender : AnyObject) {
        updateAutoDataFileScriptEntry()
    }
}

