//
//  PSImportFileToolBrowser.swift
//  PsyScopeEditor
//
//  Created by James on 17/02/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSImportFileBrowserViewDelegate : PSToolBrowserViewDelegate {
    
    func setPossibleTypes(tools : [PSToolInterface]) {
        possTypes = []
        for t in tools {
            for pse in pluginProvider.eventExtensions {
                if pse.type == t.type() {
                    possTypes.append(pse)
                }
            }
        }
    }
    
    var possTypes : [PSExtension] = []
    
    override func refresh() {
        arrayController.content = possTypes
        objectTableView.reloadData()
    }
}