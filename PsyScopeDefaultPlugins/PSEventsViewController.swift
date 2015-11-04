//
//  PSEventsViewController.swift
//  PsyScopeEditor
//
//  Created by James on 31/08/2014.
//

import Foundation

class PSEventsViewController : PSToolPropertyController, NSWindowDelegate {

    init(entry : Entry, scriptData : PSScriptData) {
        let bundle = NSBundle(forClass:self.dynamicType)
        super.init(nibName: "EventsView", bundle: bundle, entry: entry, scriptData: scriptData)
        storedDoubleClickAction = { () in
            //TODO bring up template builder
            
            NSNotificationCenter.defaultCenter().postNotificationName("PSShowWindowNotificationForTemplateBuilder", object: self.scriptData.document)
            return
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}