//
//  PStableViewControlller.swift
//  PsyScopeEditor
//
//  Created by James on 17/09/2014.
//

import Foundation

class PSTableViewController : PSToolPropertyController, NSWindowDelegate {
    
    init(entry : Entry, scriptData : PSScriptData) {
        var bundle = NSBundle(forClass:self.dynamicType)
        super.init(nibName: "TableView", bundle: bundle, entry: entry, scriptData: scriptData)
        storedDoubleClickAction = { () in
            self.editObjectsButton(self)
            return
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    var tableBuilder : PSTableBuilder?
    
    @IBAction func editObjectsButton(sender : AnyObject) {
        if let tb = self.tableBuilder {
            if (!tb.window.visible) {
                tb.window.makeKeyAndOrderFront(sender)
            }
        } else {
            self.tableBuilder = PSTableBuilder(theScriptData: self.scriptData, theTableEntry: self.entry)
            tableBuilder?.showWindow()
            tableBuilder?.window.delegate = self
        }
        
    }
    
    func windowShouldClose(sender: AnyObject!) -> Bool {
        tableBuilder?.deregister()
        tableBuilder = nil
        return true
    }

}