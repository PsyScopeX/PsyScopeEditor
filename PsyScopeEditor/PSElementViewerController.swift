//
//  PSElementViewerController.swift
//  PsyScopeEditor
//
//  Created by James on 29/05/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSElementViewerController : NSObject {
    
    @IBOutlet var document : Document!
    @IBOutlet var elementViewerPopover : NSPopover!
    @IBOutlet var elementViewerView : NSView!
    
    let genericInterface = PSAttributeGeneric()
    
    func showForView(view: NSView, attributeEntry: Entry) {
        //remove existing elements
        elementViewerView.subviews = []
        
        //identify attribute type
        var attributeInterface : PSAttributeInterface = genericInterface
        if let interface : PSAttributeInterface = document.scriptData.getAttributeInterfaceForAttributeEntry(attributeEntry) {
            attributeInterface = interface
        }
        
        //build attribute cell
        let attributeParameter = attributeInterface.attributeParameter() as! PSAttributeParameter
        let cell = PSAttributeEntryCellView(entry: attributeEntry, attributeParameter: attributeParameter, interface: genericInterface, scriptData: document.scriptData)
        cell.frame = elementViewerView.frame
        let builder = PSAttributeParameterBuilder(parameter: attributeParameter)
        builder.setupElementViewer(cell, gotoEntryBlock: {
            var entryToSelect = self.document.scriptData.getBaseEntry(attributeParameter.varyByEntryName!)
            self.document.selectionController.selectEntry(entryToSelect) })
        
        //add to elementViewer view
        
        elementViewerView.addSubview(cell)
        
        //show popover
        elementViewerPopover.showRelativeToRect(view.frame, ofView: view, preferredEdge: NSRectEdge.MinY)
    }
}