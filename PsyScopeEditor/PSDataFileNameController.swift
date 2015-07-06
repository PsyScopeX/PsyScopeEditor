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
    
    var tokenCount : Int = 0
    var layoutManager : NSLayoutManager? = nil
    var subjectVariableNames : [String] = []
    var scriptData : PSScriptData! //gets populated by subjectvariablescontroller
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tokenField.tokenizingCharacterSet = NSCharacterSet(charactersInString: " ")
        currentDataFileNamePreview.stringValue = ""
    }
    
    func reloadData(variables : [PSSubjectVariable]) {
        //update list of tokens
        subjectVariableNames = variables.map { $0.name }
        
        //update tokenfield
        var objectsToAdd : [String] = []
        if let adf = scriptData.getBaseEntry("AutoDatafile"),
            stringSubEntry = scriptData.getSubEntry("Strings", entry: adf) {
                let strings = PSStringList(entry: stringSubEntry, scriptData: scriptData)
                
                for value in strings.values {
                    switch(value) {
                    case let .Function(functionElement):
                        if functionElement.values.count == 2 && functionElement.bracketType == .Expression {
                            let secondValue = functionElement.values[1]
                            if case .StringValue(let value) = secondValue {
                                objectsToAdd.append(value.value)
                            }
                        }
                        break
                    case let .StringValue(stringValue):
                        objectsToAdd.append(stringValue.value)
                        break
                    default:
                        break
                    }
                }
                
        }
        tokenField.objectValue = objectsToAdd
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


        /*
    // By default the tokens have no menu.
    optional func tokenField(tokenField: NSTokenField, menuForRepresentedObject representedObject: AnyObject) -> NSMenu?
    optional func tokenField(tokenField: NSTokenField, hasMenuForRepresentedObject representedObject: AnyObject) -> Bool
    */
    // This method allows you to change the style for individual tokens as well as have mixed text and tokens.
    func tokenField(tokenField: NSTokenField, styleForRepresentedObject representedObject: AnyObject) -> NSTokenStyle {
        return NSTokenStyle.Rounded
    }
    
    override func controlTextDidChange(obj: NSNotification) {
        tokenFieldChanged()
    }
    
    func tokenFieldChanged() {
        if let lm = self.layoutManager {
            let updatedCount = countAttachmentsInAttributedString(lm.attributedString())
            if (updatedCount != self.tokenCount) {
                self.tokenCount = updatedCount
                updatePreviewTextView()
                updateAutoDataFileScriptEntry()
            }
        }
    }
    
    override func controlTextDidEndEditing(obj: NSNotification) {
        tokenFieldChanged()
    }
    
    func updateAutoDataFileScriptEntry() {
        scriptData.beginUndoGrouping("Change DataFile Name")
        
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
            print(newValue)
            strings.currentValue = newValue
        } else {
            strings.currentValue = ""
        }
        
        //if there are tokens then the dialog should be MakeFileName otherwise it should be 'NULL' with the name of the file name as the main Entry's value
        if includesTokens {
            dialog.currentValue = "MakeFileName"
        } else {
            dialog.currentValue = "NULL"
        }
        
        //update current value
        autoDatafile.currentValue = getCurrentValue()
        
        scriptData.endUndoGrouping()
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
        self.layoutManager = (fieldEditor as! NSTextView).layoutManager
        return true
        kUTTypeUTF8PlainText
    }
    
    func countAttachmentsInAttributedString(attributedString : NSAttributedString) -> Int {
        let string : NSString = attributedString.string
        let maxIndex = string.length - 1
        var counter : Int = 0
        
        for i in 0...maxIndex {
            if string.characterAtIndex(i) == unichar(NSAttachmentCharacter) {
                counter++
            }
        }
        
        return counter
    }

}