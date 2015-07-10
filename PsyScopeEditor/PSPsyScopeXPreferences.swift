//
//  PSPsyScopeXPreferences.swift
//  PsyScopeEditor
//
//  Created by James on 29/06/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

class PSPsyScopeXPreferences : NSViewController, MASPreferencesViewController {
    
    override var identifier : String? { get { return "PsyScopeXPreferences" } set { } }
    var toolbarItemImage : NSImage { get { return NSImage(named: NSImageNamePreferencesGeneral)! } }
    var toolbarItemLabel : String! { get { return "PsyScopeX" } }
    
    var windowController : NSWindowController!
    @IBOutlet var psyScopeXPathText : NSTextField!
    
    @IBAction func editPsyScopeXPath(_: AnyObject) {
        let openPanel = NSOpenPanel()
        openPanel.title = "Choose any file"
        openPanel.showsResizeIndicator = true
        openPanel.showsHiddenFiles = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = true
        openPanel.allowsMultipleSelection = false
        //openPanel.allowedFileTypes = [fileType]
        openPanel.beginSheetModalForWindow(self.windowController.window!, completionHandler: {
        (int_code : Int) -> () in
            if int_code == NSFileHandlingPanelOKButton {
                //relative to files location
                let path : NSString = openPanel.URL!.path!
                self.psyScopeXPathText.stringValue = path as String
                NSUserDefaults.standardUserDefaults().setObject(path, forKey: "psyScopeXPath")
            }
            return
        })
    }
    
}