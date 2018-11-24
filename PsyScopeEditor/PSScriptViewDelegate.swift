//
//  PSScriptViewDelegate.swift
//  PsyScopeEditor
//
//  Created by James on 04/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSScriptViewDelegate : NSObject, NSTextViewDelegate, NSTextStorageDelegate {
    @IBOutlet var scriptBoard : NSTextView!
    var scriptWriter : PSScriptWriter!
    @IBOutlet var scriptConverter : PSScriptConverter!
    @IBOutlet var updateScriptButton : NSButton!
    @IBOutlet var buildScriptButton : NSButton!
    @IBOutlet var errorHandler : PSScriptErrorViewController!
    
    var nextEditIsUser : Bool = true;
    var userHasMadeTextEdits = false;
    var userHasMadeGraphicsEdits = false;
    
    /*lazy var parsingQueue : NSOperationQueue = {
        var queue = NSOperationQueue()
        queue.name = "Parsing queue"
        queue.maxConcurrentOperationCount = 1
        return queue
        }()*/
    var readingOperations : [Int : PSScriptReaderOperation] = [:]
    var readingOperationIndex : Int = 0
    
    override func awakeFromNib() {
        scriptBoard.isAutomaticQuoteSubstitutionEnabled = false
        scriptBoard.enabledTextCheckingTypes = 0
        scriptBoard.textStorage!.delegate = self
        
        buildScriptButton.isEnabled = false
        updateScriptButton.isEnabled = true
        //scriptBoard.string = ""
        setDefaultFont()
    }
    
    func setDefaultFont() {
        scriptBoard.textStorage!.font = PSConstants.Fonts.scriptFont
        scriptBoard.font = PSConstants.Fonts.scriptFont
    }
    
    func setup(_ scriptData : PSScriptData) {
        scriptWriter = PSScriptWriter(scriptData: scriptData)
    }
    
    func importScript(_ script : String) {
        //cancel anything in progress
        for operation in readingOperations.values {
            operation.cancel()
        }
        
        build(script)
        PSCleanUpTree(scriptConverter.mainWindowController.scriptData)
    }
    
    //Button for Script -> Objects
    @IBAction func buildScript(_: AnyObject) {
        //convert parsed script to real objects
        var safeToBuild = true
        if (userHasMadeGraphicsEdits) {
            //warn that graphics edits will be overriden
            let question = "Override changes?" // NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message")
            let info = "You have made some changes via the graphical interface, since you began editing the script, these are not reflected in the current script so building will override them." // NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
            let overrideButton = "Override" // NSLocalizedString(@"Quit anyway", @"Quit anyway button title")
            let cancelButton = "Cancel" // NSLocalizedString(@"Cancel", @"Cancel button title")
            let alert = NSAlert()
            alert.messageText = question
            alert.informativeText = info
            alert.addButton(withTitle: overrideButton)
            alert.addButton(withTitle: cancelButton)
            
            let answer = alert.runModal()
            if answer == NSApplication.ModalResponse.alertFirstButtonReturn {
                safeToBuild = true
            } else {
                safeToBuild = false
            }
        }
        
        if (safeToBuild) {
            build(scriptBoard.string)
        }
    }
    
    
    func replaceCurlyQuotes(_ string : String) -> String {
        //replace pesky curly quotes
        // \u2018 (curly right single quote) -> '
        // \u2019 (curly left single quote) -> '
        // \u201c (curly right double quote) -> "
        // \u201d (curly left double quote) -> "
        
        return String(string.characters.map( {
            switch ($0) {
            case "\u{2018}":
                return "'"
            case "\u{2019}":
                return "'"
            case "\u{201c}":
                return "\""
            case "\u{201d}":
                return "\""
            default:
                return $0
            }
            }))
    }
    
    func build(_ script : String) {
        
        
        let script = replaceCurlyQuotes(script)
        
        errorHandler.reset()
        let scriptReader = PSScriptReader(script: script)
        
        var success = scriptReader.errors.count == 0
        
        for e in scriptReader.errors {
            errorHandler.newError(e)
        }
        self.errorHandler.presentErrors()
        
        success = success && scriptConverter.buildFromGhostScript(scriptReader.ghostScript)
        if (success) {
            userHasMadeTextEdits = false //reset flag
            userHasMadeGraphicsEdits = false
            buildScriptButton.isEnabled = false
            updateScriptButton.isEnabled = false
            updateScriptView()
        } else {
            userHasMadeTextEdits = true
            nextEditIsUser = false
            self.scriptBoard.textStorage!.setAttributedString(scriptReader.attributedString)
        }

    }
    
    //Button for Objects -> Script
    @IBAction func updateScript(_: AnyObject) {
        var safeToUpdate = true
        if (userHasMadeTextEdits) {
            //warn that text edits will be overriden
            let question = "Override changes?" // NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message")
            let info = "You have made some changes to the script, these will be overriden when you update." // NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
            let overrideButton = "Override" // NSLocalizedString(@"Quit anyway", @"Quit anyway button title")
            let cancelButton = "Cancel" // NSLocalizedString(@"Cancel", @"Cancel button title")
            let alert = NSAlert()
            alert.messageText = question
            alert.informativeText = info
            alert.addButton(withTitle: overrideButton)
            alert.addButton(withTitle: cancelButton)
            
            let answer = alert.runModal()
            if answer == NSApplication.ModalResponse.alertFirstButtonReturn {
                safeToUpdate = true
            } else {
                safeToUpdate = false
            }
        }
        
        if (safeToUpdate) {
            //reset errors
            self.errorHandler.reset()
            userHasMadeTextEdits = false //reset flag
            userHasMadeGraphicsEdits = false
            buildScriptButton.isEnabled = false
            updateScriptButton.isEnabled = false
            updateScriptView()
            
        }
    }
    
    //called by object changes in MOC
    func scriptHasHadObjectUpdates() {
        userHasMadeGraphicsEdits = true
        if (!userHasMadeTextEdits) {
            updateScriptView() // auto update
        } else {
            updateScriptButton.isEnabled = true
            scrollToSelectedEntry()
        }
    }
    
    //synchronizes script display to object graph
    func updateScriptView() {
        
        //cancel anything in progress
        for oepration in readingOperations.values {
            oepration.cancel()
        }
        
        let readingOperation = PSScriptReaderOperation(scriptWriter: scriptWriter)
        readingOperationIndex += 1
        let index = readingOperationIndex
        readingOperations[index] = readingOperation
        readingOperation.completionBlock = {
            if (readingOperation.isCancelled) { return }
            DispatchQueue.main.async(execute: {
                self.nextEditIsUser = false
                self.scriptBoard.textStorage!.setAttributedString(readingOperation.attributedString);
                self.errorHandler.presentErrors()
                self.userHasMadeGraphicsEdits = false
                self.userHasMadeTextEdits = false
                self.buildScriptButton.isEnabled = false
                self.updateScriptButton.isEnabled = false
                self.readingOperations[index] = nil
                self.scrollToSelectedEntry()
            })
        }
        
        OperationQueue.main.addOperation(readingOperation)
        //parsingQueue.addOperation(readingOperation)
    }
    
    var selectedEntry : Entry?
    
    func selectEntry(_ entry : Entry?) {
        selectedEntry = entry
    }
    
    func scrollToSelectedEntry() {
        if let str = scriptBoard.string, let e = selectedEntry, let name = e.name {
            var range = (str as NSString).range(of: "\n" + name + "::")
            
            if range.location != NSNotFound && range.length > 0 {
                range.length -= 1
                range.location += 1
                scriptBoard.scrollRangeToVisible(range)
                scriptBoard.setSelectedRange(range)
            }
        }
    }
    
    
    
    //called either by user updates or updateScriptView
    override func textStorageDidProcessEditing(_ notification: Notification) {
        if (nextEditIsUser) {
            userHasMadeTextEdits = true
            buildScriptButton.isEnabled = true
            updateScriptButton.isEnabled = true
            
            //start a formatting only update
            let script = replaceCurlyQuotes(scriptBoard.string)
            let readingOperation = PSScriptReaderOperation(script: script)
            readingOperationIndex += 1
            let index = readingOperationIndex
            readingOperations[index] = readingOperation
            readingOperation.completionBlock = {
                if (readingOperation.isCancelled) { return }
                DispatchQueue.main.async(execute: {
                    self.nextEditIsUser = false
                    self.scriptBoard.textStorage!.beginEditing()
                    let minLength = min(readingOperation.attributedString.length, self.scriptBoard.textStorage!.length)
                    
                    let fullRange = NSMakeRange(0, minLength)
                    self.scriptBoard.textStorage!.setAttributes(convertToOptionalNSAttributedStringKeyDictionary([:]), range: fullRange)//clear
                    
                    self.errorHandler.reset()
                    for e in readingOperation.errors {
                        self.errorHandler.newError(e)
                    }
                    
                    self.errorHandler.presentErrors()
                 

                    readingOperation.attributedString.enumerateAttributes(in: fullRange, options: NSAttributedString.EnumerationOptions(rawValue: 0), using: {
                        ( dic :[String : Any], range : NSRange, stop : UnsafeMutablePointer<ObjCBool>) -> Void in
                            self.scriptBoard.textStorage!.setAttributes(convertToOptionalNSAttributedStringKeyDictionary(dic), range: range)
                        })
                    
                    self.scriptBoard.textStorage!.endEditing()
                    self.readingOperations[index] = nil
                })
            }
            //parsingQueue.addOperation(readingOperation)
            OperationQueue.main.addOperation(readingOperation)
        }

        
        nextEditIsUser = true //this is true unless updateScript is called first
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
