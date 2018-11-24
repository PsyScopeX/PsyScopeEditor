//
//  PSVariableTypePopup.swift
//  PsyScopeEditor
//
//  Created by James on 21/04/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation


class PSVariableTypePopup: NSObject {

    init(scriptData: PSScriptData){
        self.scriptData = scriptData
        self.window = scriptData.window
        super.init()

        
        Bundle(for:type(of: self)).loadNibNamed("VariableTypeBuilder", owner: self, topLevelObjects: &topLevelObjects)
    }
    
    //MARK: Variables / Constants
    
    let scriptData : PSScriptData
    let window : NSWindow
    
    var topLevelObjects : NSArray?
    
    
    //MARK: Outlets
    
    @IBOutlet var controller : PSVariableTypeController!
    @IBOutlet var popupWindow : NSWindow!
    
    //MARK: Setup
    
    func showPopup() {
        
        window.beginSheet(popupWindow, completionHandler: {
            (response : NSApplication.ModalResponse) -> () in
            //[sheet orderOut:self];
            //[NSApp stopModalWithCode:returnCode];
            NSApp.stopModal(withCode: response)
        })
        
        NSApp.runModal(for: popupWindow)
    
    }
    
    //MARK: Actions
    
    @IBAction func closeSheet(_: AnyObject) {
        controller.updateScript()
        window.endSheet(popupWindow)
    }
    

}
