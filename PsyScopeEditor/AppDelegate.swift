//
//  MainAppDelegate.swift
//  PsyScopeEditor
//
//  Created by James on 15/07/2014.
//

import Cocoa


class AppDelegate: NSObject, NSApplicationDelegate {
    
    override init() {
        super.init()
        // Register the preference defaults early.
        let appDefaults = PSPreferences.getDefaults()
        UserDefaults.standard.register(defaults: appDefaults)
    }

    @IBOutlet var menu : NSMenu!
    
    
    @IBAction func openPreferences(_ sender : AnyObject) {
        preferencesWindowController.showWindow(nil)
    }
    
    lazy var preferencesWindowController : NSWindowController = {
        let layoutVC = PSCleanUpLayoutPreferences(nibName: "CleanUpLayoutPreferences", bundle: nil)!
        let psyScopeVC = PSPsyScopeXPreferences(nibName: "PsyScopeXPreferences", bundle: nil)!
        let pluginVC = PSPluginPreferences(nibName: "PluginPreferences", bundle: nil)!
        
        var controllers : [NSViewController] = [layoutVC, psyScopeVC, pluginVC]
        // To add a flexible space between General and Advanced preference panes insert [NSNull null]:
        var _preferencesWindowController = MASPreferencesWindowController(viewControllers: controllers, title: "Preferences")

        psyScopeVC.windowController = _preferencesWindowController
        pluginVC.windowController = _preferencesWindowController
        return _preferencesWindowController!
        
    } ()
    

    
    
    
    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        return true
    }
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        print("Will finish launching")
    }
    
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplicationTerminateReply {

        return .terminateNow
    }

}
