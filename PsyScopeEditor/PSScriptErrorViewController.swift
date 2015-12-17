    //
//  PSErrorOutlineView.swift
//  PsyScopeEditor
//
//  Created by James on 14/08/2014.
//

import Cocoa



//provides errors to an NSOutlineView
class PSScriptErrorViewController: NSObject, NSTableViewDataSource, NSTableViewDelegate, PSClickableTableViewDelegate {
    @IBOutlet var textView : NSTextView!
    @IBOutlet var tableView : NSTableView!
    @IBOutlet var mainWindowController : PSMainWindowController!
    @IBOutlet var descriptionText : NSTextField!
    @IBOutlet var detailedDescriptionText : NSTextView!
    @IBOutlet var solutionText : NSTextView!

    var errors : [PSScriptError] = []
    var warnings : [PSScriptError] = []
    
    //MARK: Setup
    
    override func awakeFromNib() {
        super.awakeFromNib()
        turnOffErrorDetail()
    }
    
    //MARK: Tableview Datasource
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return errors.count + warnings.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        if row < errors.count { return  errors[row] } else { return warnings[row - errors.count] }
    }
    
    //MARK: Tableview Delegate
    
    func tableView(tableView: PSClickableTableView, didClickTableRow row: Int) {
        let error = row < errors.count ? errors[row] : warnings[row - errors.count]
        
        if let errorEntry = error.entry {
            let baseEntry = mainWindowController.scriptData.getBaseEntryOfSubEntry(errorEntry)
            if let str = textView.string, name = baseEntry.name {
                var range = (str as NSString).rangeOfString("\n" + name + "::")
                
                if range.location != NSNotFound && range.length > 0 {
                    range.length--
                    range.location++
                    textView.scrollRangeToVisible(range)
                    textView.setSelectedRange(range)
                }
            }
        } else {
            textView.setSelectedRange(error.range)
            textView.scrollRangeToVisible(error.range)
        }
        if let w = textView.window {
            w.makeFirstResponder(textView)
        }
        setErrorDetailToError(error)
        
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if row < errors.count {
            return tableView.makeViewWithIdentifier("ErrorView", owner: nil)
        } else {
            return tableView.makeViewWithIdentifier("WarningView", owner: nil)
        }
    }
    
    //MARK: Setting Error Detail
    
    func turnOffErrorDetail() {
        descriptionText.stringValue = ""
        detailedDescriptionText.string = ""
        solutionText.string = ""
    }
    
    func setErrorDetailToError(error : PSScriptError) {
        descriptionText.stringValue = error.errorDescription as String
        detailedDescriptionText.string = error.detailedDescription as String
        solutionText.string = error.solution as String
    }


    //MARK: Main methods (old protocol)
    
    func newError(newError : PSScriptError) {
        errors.append(newError)
    }
    
    func newWarning(newWarning : PSScriptError) {
        warnings.append(newWarning)
    }
    
    func reset() {
        turnOffErrorDetail()
        errors = []
        warnings = []
    }
    
    func presentErrors() {
        tableView.reloadData()
        if errors.count > 0 || warnings.count > 0 {
            NSNotificationCenter.defaultCenter().postNotificationName("PSShowErrorsNotification", object: mainWindowController.document)
        }
    }
}
