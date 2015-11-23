//
//  PSScriptErrorPopoverController.swift
//  PsyScopeEditor
//
//  Created by James on 28/04/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSScriptErrorPopoverController : NSObject {
    
    //MARK: Outlets
    @IBOutlet var errorPopover : NSPopover!
    @IBOutlet var descriptionText : NSTextField!
    @IBOutlet var detailedDescriptionText : NSTextView!
    @IBOutlet var solutionText : NSTextView!
    
    //MARK: Main method
    func showPopoverForError(error : PSScriptError, errorView : NSView) {
        
        descriptionText.stringValue = error.errorDescription as String
        detailedDescriptionText.string = error.detailedDescription as String
        solutionText.string = error.solution as String
        
        errorPopover.showRelativeToRect(errorView.bounds, ofView: errorView, preferredEdge: NSRectEdge.MinY)
    }
}