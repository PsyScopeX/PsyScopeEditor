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
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return errors.count + warnings.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if row < errors.count { return  errors[row] } else { return warnings[row - errors.count] }
    }
    
    //MARK: Tableview Delegate
    
    func tableView(_ tableView: PSClickableTableView, didClickTableRow row: Int) {
        let error = row < errors.count ? errors[row] : warnings[row - errors.count]
        
        if let entryName = error.entryName {
                var range = (textView.string as NSString).range(of: "\n" + entryName + "::")
                
                if range.location != NSNotFound && range.length > 0 {
                    range.length -= 1
                    range.location += 1
                    textView.scrollRangeToVisible(range)
                    textView.setSelectedRange(range)
                }
            
        } else if let searchString = error.searchString {
            let range = (textView.string as NSString).range(of: searchString)
            
            if range.location != NSNotFound && range.length > 0 {
                //range.length--
                //range.location++
                textView.scrollRangeToVisible(range)
                textView.setSelectedRange(range)
            }
        }
        if let w = textView.window {
            w.makeFirstResponder(textView)
        }
        setErrorDetailToError(error)
        
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if row < errors.count {
            return tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue:"ErrorView"), owner: nil)
        } else {
            return tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue:"WarningView"), owner: nil)
        }
    }
    
    //MARK: Setting Error Detail
    
    func turnOffErrorDetail() {
        descriptionText.stringValue = ""
        detailedDescriptionText.string = ""
        solutionText.string = ""
    }
    
    func setErrorDetailToError(_ error : PSScriptError) {
        descriptionText.stringValue = error.errorDescription as String
        detailedDescriptionText.string = error.detailedDescription as String
        solutionText.string = error.solution as String
    }


    //MARK: Main methods (old protocol)
    
    func newError(_ newError : PSScriptError) {
        errors.append(newError)
    }
    
    func newWarning(_ newWarning : PSScriptError) {
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
            NotificationCenter.default.post(name: Notification.Name(rawValue: "PSShowErrorsNotification"), object: mainWindowController.document)
        }
    }
}

