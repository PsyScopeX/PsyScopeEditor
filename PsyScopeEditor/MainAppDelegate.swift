//
//  MainAppDelegate.swift
//  PsyScopeEditor
//
//  Created by James on 15/07/2014.
//  Copyright (c) 2014 James. All rights reserved.
//

import Cocoa


class MainAppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet var menu : NSMenu

    var theAppWideMOC = AppWideMOC.sharedInstance
    var managedObjectContext : NSManagedObjectContext? = nil
    
    func applicationShouldOpenUntitledFile(sender: NSApplication!) -> Bool {
        return true
    }
    
    func applicationWillFinishLaunching(notification: NSNotification!) {
        self.managedObjectContext = theAppWideMOC.managedObjectContext
    }
    
    func applicationDidFinishLaunching(notification: NSNotification!) {
        
    }
    
    @IBAction func saveApplicationState(sender: AnyObject) {
        // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
        var error: NSError? = nil
        
        if let moc = self.managedObjectContext {
            if !moc.commitEditing() {
                println("\(NSStringFromClass(self.dynamicType)) unable to commit editing before saving")
            }
            if !moc.save(&error) {
                NSApplication.sharedApplication().presentError(error)
            }
        }
    }
    
    
    func windowWillReturnUndoManager(window: NSWindow?) -> NSUndoManager? {
        // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
        if let moc = self.managedObjectContext {
            return moc.undoManager
        } else {
            return nil
        }
    }
    
    func applicationShouldTerminate(sender: NSApplication) -> NSApplicationTerminateReply {
        // Save changes in the application's managed object context before the application terminates.
        
        //if !_managedObjectContext {
            // Accesses the underlying stored property because we don't want to cause the lazy initialization
        //    return .TerminateNow
        //}
        let moc = self.managedObjectContext!
        if !moc.commitEditing() {
            println("\(NSStringFromClass(self.dynamicType)) unable to commit editing to terminate")
            return .TerminateCancel
        }
        
        if !moc.hasChanges {
            return .TerminateNow
        }
        
        var error: NSError? = nil
        if !moc.save(&error) {
            // Customize this code block to include application-specific recovery steps.
            let result = sender.presentError(error)
            if (result) {
                return .TerminateCancel
            }
            
            let question = "Could not save changes while quitting. Quit anyway?" // NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message")
            let info = "Quitting now will lose any changes you have made since the last successful save" // NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
            let quitButton = "Quit anyway" // NSLocalizedString(@"Quit anyway", @"Quit anyway button title")
            let cancelButton = "Cancel" // NSLocalizedString(@"Cancel", @"Cancel button title")
            let alert = NSAlert()
            alert.messageText = question
            alert.informativeText = info
            alert.addButtonWithTitle(quitButton)
            alert.addButtonWithTitle(cancelButton)
            
            let answer = alert.runModal()
            if answer == NSAlertFirstButtonReturn {
                return .TerminateCancel
            }
        }
        
        return .TerminateNow
    }

}
