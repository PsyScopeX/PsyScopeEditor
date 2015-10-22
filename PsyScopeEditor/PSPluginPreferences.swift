//
//  PSPluginPreferences.swift
//  PsyScopeEditor
//
//  Created by James on 22/10/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation



class PSPluginPreferences : NSViewController, MASPreferencesViewController {
    
    override var identifier : String? { get { return "PluginPreferences" } set { } }
    var toolbarItemImage : NSImage { get { return NSImage(named: NSImageNamePreferencesGeneral)! } }
    var toolbarItemLabel : String! { get { return "Plugins" } }
    
    var windowController : NSWindowController!
    @IBOutlet var pluginPathText : NSTextField!
    @IBOutlet var pluginListTextView : NSTextView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let paths = PSPluginSingleton.sharedInstance.pluginLoader.pluginsLoaded.joinWithSeparator("\n\n")
        pluginListTextView.string = paths
    }
    
    @IBAction func editPluginPath(_: AnyObject) {
        let openPanel = NSOpenPanel()
        openPanel.title = "Choose any file"
        openPanel.showsResizeIndicator = true
        openPanel.showsHiddenFiles = true
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = true
        openPanel.allowsMultipleSelection = false
        //openPanel.allowedFileTypes = [fileType]
        openPanel.beginSheetModalForWindow(self.windowController.window!, completionHandler: {
            (int_code : Int) -> () in
            if int_code == NSFileHandlingPanelOKButton {
                //relative to files location
                let path : NSString = openPanel.URL!.path!
                self.pluginPathText.stringValue = path as String
                NSUserDefaults.standardUserDefaults().setObject(path, forKey: PSPluginPathKey)
            }
            return
        })
    }
    
    @IBAction func resetToDefaultButtonClicked(_:NSButton) {
        NSUserDefaults.standardUserDefaults().setObject(PSPreferences.psyScopeXPath.defaultValue as! String, forKey: PSPluginPathKey)
    }
    
    @IBAction func restartPsyScope(sender : AnyObject) {
        let task = NSTask()
        
        var args: [String] = []
        args.append("-c")
        args.append("sleep 0.2; open \"\(NSBundle.mainBundle().bundlePath)\"")
        
        task.launchPath = "/bin/sh"
        task.arguments = args
        task.launch()
        NSApplication.sharedApplication().terminate(nil)
    }
    
}