//
//  PSAttributePopup.swift
//  PsyScopeEditor
//
//  Created by James on 01/06/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

open class PSAttributePopup : NSObject {

    public var currentValue : PSEntryElement
    public var displayName : String
    public var nibName : String
    public var bundle : Bundle
    @IBOutlet public var attributeSheet : NSWindow!
    public var topLevelObjects : NSArray?
    public var parentWindow : NSWindow!
    public var setCurrentValueBlock : ((PSEntryElement) -> ())?
    
    public init(nibName: String, bundle: Bundle, currentValue : PSEntryElement, displayName : String, setCurrentValueBlock : ((PSEntryElement) -> ())?) {
        self.currentValue = currentValue
        self.nibName = nibName
        self.bundle = bundle
        self.displayName = displayName
        self.setCurrentValueBlock = setCurrentValueBlock
        super.init()
    }

    public func showAttributeModalForWindow(_ window : NSWindow) {
        if (attributeSheet == nil) {
            bundle.loadNibNamed(nibName, owner: self, topLevelObjects: &topLevelObjects)
        }
        
        parentWindow = window
        
        parentWindow.beginSheet(attributeSheet, completionHandler: {
            (response : NSApplication.ModalResponse) -> () in
            NSApp.stopModal(withCode: response)
            
            
        })
        NSApp.runModal(for: attributeSheet)
    }

    @IBAction open func closeMyCustomSheet(_: AnyObject) {
        parentWindow.endSheet(attributeSheet)
        if let setCurrentValueBlock = setCurrentValueBlock {
            setCurrentValueBlock(self.currentValue)
        }
    }
}
