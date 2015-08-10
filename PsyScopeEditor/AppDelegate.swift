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
        NSUserDefaults.standardUserDefaults().registerDefaults(appDefaults)
    }

    @IBOutlet var menu : NSMenu!
    
    
    @IBAction func openPreferences(sender : AnyObject) {
        preferencesWindowController.showWindow(nil)
    }
    
    lazy var preferencesWindowController : NSWindowController = {
        var layoutVC = PSCleanUpLayoutPreferences(nibName: "CleanUpLayoutPreferences", bundle: nil)!
        var psyScopeVC = PSPsyScopeXPreferences(nibName: "PsyScopeXPreferences", bundle: nil)!
        
        var controllers : [NSViewController] = [layoutVC, psyScopeVC]
        // To add a flexible space between General and Advanced preference panes insert [NSNull null]:
        var _preferencesWindowController = MASPreferencesWindowController(viewControllers: controllers, title: "Preferences")

        psyScopeVC.windowController = _preferencesWindowController
        return _preferencesWindowController
        
    } ()
    

    
    
    
    func applicationShouldOpenUntitledFile(sender: NSApplication) -> Bool {
        return true
    }
    
    func applicationWillFinishLaunching(notification: NSNotification) {
        print("Will finish launching")
    }
    
    
    func applicationShouldTerminate(sender: NSApplication) -> NSApplicationTerminateReply {

        return .TerminateNow
    }

}
