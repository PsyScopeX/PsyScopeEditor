//
//  PSWindowViewWindowController.swift
//  PsyScopeEditor
//
//  Created by James on 17/12/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

class PSWindowViewWindowController : NSWindowController, NSWindowDelegate {
    
    @IBOutlet var leftPanel : NSView!
    @IBOutlet var midPanel : NSView!
    
    var scriptData : PSScriptData!
    var leftView : NSView!
    var rightView : NSView!
    
    func setup(scriptData : PSScriptData, leftView : NSView?, rightView : NSView) {
        self.scriptData = scriptData
        self.leftView = leftView
        self.rightView = rightView
        scriptData.addWindowController(self)
        
    }
    
    override func awakeFromNib() {
        leftPanel.addSubview(leftView)
        midPanel.addSubview(rightView)
        leftView.frame = leftPanel.bounds
        rightView.frame = midPanel.bounds
    }
    
    func windowWillClose(notification: NSNotification) {
        scriptData.removeWindowController(self)
    }
}