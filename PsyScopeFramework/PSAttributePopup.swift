//
//  PSAttributePopup.swift
//  PsyScopeEditor
//
//  Created by James on 01/06/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

public class PSAttributePopup : NSObject {

    public var currentValue : String
    public var displayName : String
    public var nibName : String
    public var bundle : NSBundle
    @IBOutlet public var attributeSheet : NSWindow!
    public var topLevelObjects : NSArray?
    public var parentWindow : NSWindow!
    public var setCurrentValueBlock : ((String) -> ())?
    
    public init(nibName: String, bundle: NSBundle, currentValue : String, displayName : String, setCurrentValueBlock : ((String) -> ())?) {
        self.currentValue = currentValue
        self.nibName = nibName
        self.bundle = bundle
        self.displayName = displayName
        self.setCurrentValueBlock = setCurrentValueBlock
        super.init()
    }

    public func showAttributeModalForWindow(window : NSWindow) {
        if (attributeSheet == nil) {
            bundle.loadNibNamed(nibName, owner: self, topLevelObjects: &topLevelObjects)
        }
        
        parentWindow = window
        
        parentWindow.beginSheet(attributeSheet, completionHandler: {
            (response : NSModalResponse) -> () in
            //NSApp.stopModalWithCode(response)
            
            
        })
    }

    @IBAction public func closeMyCustomSheet(_: AnyObject) {
        parentWindow.endSheet(attributeSheet)
        if let setCurrentValueBlock = setCurrentValueBlock {
            setCurrentValueBlock(self.currentValue)
        }
    }
}