    //
//  PSErrorOutlineView.swift
//  PsyScopeEditor
//
//  Created by James on 14/08/2014.
//

import Cocoa



//provides errors to an NSOutlineView
class PSScriptErrorViewController: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    @IBOutlet var textView : NSTextView!
    @IBOutlet var tableView : NSTableView!
    @IBOutlet var document : Document!
    @IBOutlet var errorPopoverController : PSScriptErrorPopoverController!
    
    var errors : [PSScriptError] = []
    
    //MARK: Tableview Datasource
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return errors.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        return errors[row]
    }
    
    //MARK: Tableview Delegate
    
    func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        let error = errors[row]
        
        if let errorEntry = error.entry {
            let baseEntry = document.scriptData.getBaseEntryOfSubEntry(errorEntry)
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
        
        let errorView = tableView.viewAtColumn(0, row: row, makeIfNecessary: true)!
        errorPopoverController.showPopoverForError(error, errorView: errorView)
        
        
        return true
    }

    //MARK: Main methods (old protocol)
    
    func newError(newError : PSScriptError) {
        errors.append(newError)
    }
    
    func reset() {
        errors = []
    }
    
    func presentErrors() {
        tableView.reloadData()
        if errors.count > 0 {
            NSNotificationCenter.defaultCenter().postNotificationName("PSShowErrorsNotification", object: document)
        }
    }
}
