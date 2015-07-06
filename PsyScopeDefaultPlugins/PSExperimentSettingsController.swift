//
//  PSExperimentSettingsController.swift
//  PsyScopeEditor
//
//  Created by James on 04/08/2014.
//  Copyright (c) 2014 James. All rights reserved.
//

import Cocoa

class PSExperimentSettingsController: NSObject, NSTextFieldDelegate {

    @IBOutlet var viewController : PSPluginViewController!
    @IBOutlet var experimentNameTextField : NSTextField!
    var managedObjectContext : NSManagedObjectContext!
    override func awakeFromNib() {
        managedObjectContext = viewController.entry.managedObjectContext
        experimentNameTextField.stringValue = viewController.entry.name
    }
    
    func control(control: NSControl!, textShouldEndEditing fieldEditor: NSText!) -> Bool {
        if (control == experimentNameTextField) {
            setExperimentName(experimentNameTextField.stringValue)
        }
        return true
    }
    
    func setExperimentName(new_name : String) {
        viewController.entry.name = new_name
        var fetch = NSFetchRequest(entityName: "Entry")
        fetch.predicate = NSPredicate(format: "name = 'Experiments'")
        var experiments_entry = managedObjectContext.executeFetchRequest(fetch, error: nil) as [Entry]
        experiments_entry.first?.currentValue = new_name
        
    }
}
