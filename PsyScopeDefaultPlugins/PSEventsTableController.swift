//
//  PSEventsTableController.swift
//  PsyScopeEditor
//
//  Created by James on 22/05/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSEventsTableController : PSChildTypeViewController {
    
    init?(pluginViewController : PSPluginViewController) {
    
        super.init(pluginViewController: pluginViewController,nibName: "EventsTable")
        pluginViewController.storedDoubleClickAction = { () in
        //TODO bring up template builder
        
        NSNotificationCenter.defaultCenter().postNotificationName("PSShowWindowNotificationForTemplateBuilder", object: pluginViewController.scriptData.document)
        return
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func openTemplateBuilderButtonClicked(_: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("PSShowWindowNotificationForTemplateBuilder", object: pluginViewController.scriptData.document)
    }
}