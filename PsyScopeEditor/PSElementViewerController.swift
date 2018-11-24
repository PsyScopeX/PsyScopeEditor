//
//  PSElementViewerController.swift
//  PsyScopeEditor
//
//  Created by James on 29/05/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSElementViewerController : NSObject {
    
    @IBOutlet var mainWindowController : PSMainWindowController!
    @IBOutlet var elementViewerPopover : NSPopover!
    @IBOutlet var elementViewerView : NSView!
    
    let genericInterface = PSAttributeGeneric()
    
    func showForView(_ view: NSView, attributeEntry: Entry) {
        //remove existing elements
        elementViewerView.subviews = []
        
        //identify attribute type
        var attributeInterface : PSAttributeInterface = genericInterface
        if let interface : PSAttributeInterface = mainWindowController.scriptData.getAttributeInterfaceForAttributeEntry(attributeEntry) {
            attributeInterface = interface
        }
        
        //build attribute cell
        let attributeParameter = attributeInterface.attributeParameter() as! PSAttributeParameter
        let cell = PSAttributeEntryCellView(entry: attributeEntry, attributeParameter: attributeParameter, interface: genericInterface, scriptData: mainWindowController.scriptData)
        cell.frame = elementViewerView.frame
        let builder = PSAttributeParameterBuilder(parameter: attributeParameter)
        builder.setupElementViewer(cell, gotoEntryBlock: {
            let entryToSelect = self.mainWindowController.scriptData.getBaseEntry(attributeParameter.varyByEntryName!)
            self.mainWindowController.selectionController.selectEntry(entryToSelect) })
        
        //add to elementViewer view
        
        elementViewerView.addSubview(cell)
        
        //show popover
        elementViewerPopover.show(relativeTo: view.frame, of: view, preferredEdge: NSRectEdge.minY)
    }
}
