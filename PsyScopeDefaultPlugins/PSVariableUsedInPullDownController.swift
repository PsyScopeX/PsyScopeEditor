//
//  PSVariableUsedInPullDownController.swift
//  PsyScopeEditor
//
//  Created by James on 15/06/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSVariableUsedInPullDownController : NSObject {
    
    var controller : PSVariablePropertiesController!
    @IBOutlet var pullDown : NSPopUpButton!

    var entryNames : [String] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //register for NSPopUpButtonWillPopUpNotification
        NotificationCenter.default.addObserver(self, selector: "popUpWillPopUp:", name: NSNotification.Name(rawValue: "NSPopUpButtonWillPopUpNotification"), object: pullDown)
    }
    
    
    func popUpWillPopUp(_: AnyObject) {
        let scriptData = controller.scriptData
        for entryName in entryNames {
            pullDown.removeItem(withTitle: entryName)
        }
        
        entryNames = (scriptData?.searchForEntriesWithReference(controller.entry.name, entries: (scriptData?.getBaseEntries())!).map { $0.name })!
        
        pullDown.addItems(withTitles: entryNames)

    }
    
    @IBAction func pullDownSelected(_: AnyObject) {
        if let entry = controller.scriptData.getBaseEntry(pullDown.selectedItem!.title) {
            controller.scriptData.selectionInterface.selectEntry(entry)
        }
    }
}
