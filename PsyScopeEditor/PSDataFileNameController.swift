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
    
    func reloadData(variables : [PSSubjectVariable]) {
        
        //update list of tokens
        subjectVariableNames = variables.map { $0.name }
        
        //get current value
        guard let experimentsEntry = scriptData.getMainExperimentEntryIfItExists(),
                  dataFileEntry = scriptData.getSubEntry("DataFile", entry: experimentsEntry) else {
            tokenField.stringValue = ""
            autoGenerateCheckButton.state = 0
            tokenField.tokenizingCharacterSet = nil
            return
        }
        
        if dataFileEntry.currentValue.lowercaseString == "@autodatafile" {
        
            //update list of tokens to add
            subjectVariableNames = variables.map { $0.name }

            //update tokenfield with autodatafile contents
            var objectsToAdd : [String] = []
            if let adf = scriptData.getBaseEntry("AutoDataFile"),
                stringSubEntry = scriptData.getSubEntry("Strings", entry: adf) {
                    let strings = PSStringList(entry: stringSubEntry, scriptData: scriptData)
                    
                    for value in strings.values {
                        switch(value) {
                        case let .Function(functionElement):
                            if functionElement.values.count == 2 && functionElement.bracketType == .Expression {
                                let secondValue = functionElement.values[1]
                                if case .StringToken(let value) = secondValue {
                                    objectsToAdd.append(value.value)
                                }
                            }
                            break
                        case let .StringToken(stringValue):
                            objectsToAdd.append(stringValue.value)
                            break
                        default:
                            break
                        }
                    }
                    
            }
            tokenField.tokenizingCharacterSet = NSCharacterSet(charactersInString: " ")
            autoGenerateCheckButton.state = 1
            tokenField.objectValue = objectsToAdd
        } else {
            //no tokens as it will be a fixed string
            subjectVariableNames = []
            tokenField.tokenizingCharacterSet = nil
            autoGenerateCheckButton.state = 0
            tokenField.objectValue = [PSUnquotedString(dataFileEntry.currentValue)]
        }
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
        
        print("Updating auto file script entry")
        if autoGenerateCheckButton.state == 1 {
        
            
            let autoDatafile = scriptData.getOrCreateBaseEntry("AutoDataFile", type: "DialogVariable", user_friendly_name: "AutoDatafile", section_name: "SubjectInfo", zOrder: 78)
            
            //make experiment entry datafile link to this entry
            let experimentEntry = scriptData.getMainExperimentEntry()
            let runLabel = scriptData.getOrCreateSubEntry("RunLabel", entry: experimentEntry, isProperty: true)
            if runLabel.currentValue != "AutoDataFile" { runLabel.currentValue = "AutoDataFile" }
            let dataFile = scriptData.getOrCreateSubEntry("DataFile", entry: experimentEntry, isProperty: true)
            dataFile.currentValue = "@AutoDataFile"
            
            let dialog = scriptData.getOrCreateSubEntry("Dialog", entry: autoDatafile, isProperty: true)
            let strings = scriptData.getOrCreateSubEntry("Strings", entry: autoDatafile, isProperty: true)
            let folder = scriptData.getOrCreateSubEntry("Folder", entry: autoDatafile, isProperty: true)
            let useDir = scriptData.getOrCreateSubEntry("UseDir", entry: autoDatafile, isProperty: true)
            
            if folder.currentValue != "" { folder.currentValue = "" }
            if useDir.currentValue != "FALSE" { folder.currentValue = "" }
            
            //First find out if there are tokens
            var includesTokens = false
            if let stringArray = tokenField.objectValue as? [String] {
                for string in stringArray {
                    if subjectVariableNames.contains(string) {
                        includesTokens = true
                        break
                    }
                }
            }
            
            //update strings (only if includes tokens)
            if let stringArray = tokenField.objectValue as? [String] {
                var previewString : [String] = []
                
                for string in stringArray {
                    //got a string object - need to check if its a variable - if so use it's current value
                    if subjectVariableNames.contains(string) {
                        previewString.append("@\"\(string)\"")
                    } else {
                        previewString.append("\"\(string)\"")
                    }
                }
                
                let newValue = " ".join(previewString)
                
                strings.currentValue = newValue
            } else {
                strings.currentValue = ""
            }
            
            print("Strings: " + strings.currentValue)
            
            //if there are tokens then the dialog should be MakeFileName otherwise it should be 'NULL' with the name of the file name as the main Entry's value
            if includesTokens {
                dialog.currentValue = "MakeFileName"
            } else {
                dialog.currentValue = "NULL"
            }
            
            print("Dialog: " + dialog.currentValue)
            
            //update current value
            autoDatafile.currentValue = getCurrentValue()
            
            print("AutoDataFile: " + autoDatafile.currentValue)
            
        } else {
            //not auto generated
            if let stringArray = tokenField.objectValue as? [String] {
                let dataFileName = " ".join(stringArray)
                let experimentsEntry = scriptData.getMainExperimentEntry()
                let dataFileEntry = scriptData.getOrCreateSubEntry("DataFile", entry: experimentsEntry, isProperty: true)
                let newValue = "\"\(dataFileName)\""
                
                dataFileEntry.currentValue = newValue
            }
        }
    }
    
    func updatePreviewTextView() {
        currentDataFileNamePreview.stringValue = getCurrentValue()
    }
    
    func getCurrentValue() -> String {
        if let values = tokenField.objectValue as? [String] {
            var previewString : String = ""
            for value in values {
                //got a string object - need to check if its a variable - if so use it's current value
                if subjectVariableNames.contains(value) {
                    //search for variable entry
                    if let entry = scriptData.getBaseEntry(value) {
                        previewString += entry.currentValue
                    } else {
                        previewString += "\(value)"
                    }
                    //insert current value of entry
                } else {
                    previewString += value
                }
            }
            return previewString
        }
        return ""
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
        
        let experimentsEntry = scriptData.getMainExperimentEntry()
        let dataFileEntry = scriptData.getOrCreateSubEntry("DataFile", entry: experimentsEntry, isProperty: true)
        scriptData.beginUndoGrouping("Change Datafile name generation")
        if autoGenerateCheckButton.state == 0 {
            //switch to default
            dataFileEntry.currentValue = "ExperimentData"
        } else {
            dataFileEntry.currentValue = "@AutoDataFile"
        }
        scriptData.endUndoGrouping(true)
    }
}