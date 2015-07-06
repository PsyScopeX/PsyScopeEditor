//
//  PSGroupsTableController.swift
//  PsyScopeEditor
//
//  Created by James on 26/05/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSGroupsTableController : PSChildTypeViewController {
    
    init?(pluginViewController : PSPluginViewController) {
        super.init(pluginViewController: pluginViewController,nibName: "GroupsTable")
        pluginViewController.storedDoubleClickAction = nil
        tableEntryName = "Groups"
        tableTypeName = "Group"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}