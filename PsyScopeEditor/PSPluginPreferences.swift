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
        let paths = PSPluginSingleton.sharedInstance.pluginLoader.pluginsLoaded.joined(separator: "\n\n")
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
        openPanel.beginSheetModal(for: self.windowController.window!, completionHandler: {
            (int_code : Int) -> () in
            if int_code == NSFileHandlingPanelOKButton {
                //relative to files location
                let path : NSString = openPanel.url!.path!
                self.pluginPathText.stringValue = path as String
                UserDefaults.standard.set(path, forKey: PSPluginPathKey)
            }
            return
        })
    }
    
    @IBAction func resetToDefaultButtonClicked(_:NSButton) {
        UserDefaults.standard.set(PSPreferences.psyScopeXPath.defaultValue as! String, forKey: PSPluginPathKey)
    }
    
    @IBAction func restartPsyScope(_ sender : AnyObject) {
        let task = Process()
        
        var args: [String] = []
        args.append("-c")
        args.append("sleep 0.2; open \"\(Bundle.main.bundlePath)\"")
        
        task.launchPath = "/bin/sh"
        task.arguments = args
        task.launch()
        NSApplication.shared().terminate(nil)
    }
    
}
