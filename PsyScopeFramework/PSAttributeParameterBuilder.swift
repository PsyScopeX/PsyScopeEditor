//
//  PSAttributeParameterBuilder.swift
//  PsyScopeEditor
//
//  Created by James on 13/04/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

//Builds an attribute parameter's controls on various view types
public class PSAttributeParameterBuilder {
    
    let defaultYLocation = CGFloat(4)
    let parameter : PSAttributeParameter
    var setupComplete : Bool
    
    public init(parameter : PSAttributeParameter) {
        self.parameter = parameter
        self.setupComplete = false
    }
    
    public init(interface : PSAttributeInterface) {
        self.parameter = interface.attributeParameter() as! PSAttributeParameter
        self.setupComplete = false
    }
    
    private func assertNotSetup() {
        if setupComplete { fatalError("Incorrect use of PSAttributeParameterBuilder (already setup)") }
        setupComplete = true
    }
    
    public func setupEntryCell(cell: PSAttributeEntryCellView) {
        assertNotSetup()
        self.parameter.name = cell.entry.name
        self.parameter.cell = cell
        self.parameter.currentValue = cell.entry.currentValue
        self.parameter.scriptData = cell.scriptData
        self.setPermanentControls(defaultYLocation)
        let width = cell.frame.width - PSDefaultConstants.ActionsBuilder.controlsLeftMargin - PSDefaultConstants.ActionsBuilder.controlsRightMargin
        self.parameter.updateAttributeControl(NSRect(x: PSDefaultConstants.ActionsBuilder.controlsLeftMargin, y: defaultYLocation, width: width, height: 22))
    }
    
    public func setupSingleCell(name : String, cell: PSCellView, currentValue : String) {
        assertNotSetup()
        self.parameter.name = name
        self.parameter.cell = cell
        self.parameter.currentValue = currentValue
        self.parameter.scriptData = cell.scriptData
        self.setPermanentControls(defaultYLocation)
        self.setupComplete = true
        let width = cell.frame.width - PSDefaultConstants.ActionsBuilder.controlsLeftMargin - PSDefaultConstants.ActionsBuilder.controlsRightMargin
        self.parameter.updateAttributeControl(NSRect(x: PSDefaultConstants.ActionsBuilder.controlsLeftMargin, y: defaultYLocation, width: width, height: 22))
    }
    
    public func setupMultiCell(name : String, y : CGFloat, cell: PSCellView, currentValue : String) {
        assertNotSetup()
        self.parameter.name = name
        self.parameter.cell = cell
        self.parameter.currentValue = currentValue
        self.parameter.scriptData = cell.scriptData
        self.setPermanentControls(y)
        let width = cell.frame.width - PSDefaultConstants.ActionsBuilder.controlsLeftMargin - PSDefaultConstants.ActionsBuilder.controlsRightMargin
        self.parameter.updateAttributeControl(NSRect(x: PSDefaultConstants.ActionsBuilder.controlsLeftMargin, y: y, width: width, height: 22))
    }
    
    public func setupTableCell(cell: PSCellView, currentValue : String) {
        assertNotSetup()
        self.parameter.name = ""
        self.parameter.cell = cell
        self.parameter.currentValue = currentValue
        self.parameter.scriptData = cell.scriptData
        self.parameter.updateAttributeControl(NSRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height))
        self.parameter.hideBorders()
    }
    
    public func setupElementViewer(cell: PSAttributeEntryCellView, gotoEntryBlock : () -> ()) {
        assertNotSetup()
        self.parameter.name = cell.entry.name
        self.parameter.cell = cell
        self.parameter.currentValue = cell.entry.currentValue
        self.parameter.scriptData = cell.scriptData
        
        let width = cell.frame.width - PSDefaultConstants.ActionsBuilder.labelsLeftMargin - PSDefaultConstants.ActionsBuilder.controlsRightMargin
        self.parameter.updateAttributeControl(NSRect(x: PSDefaultConstants.ActionsBuilder.labelsLeftMargin, y: defaultYLocation, width: width, height: 22))
        self.setElementViewerControls(gotoEntryBlock)
    }

    func setPermanentControls(y : CGFloat) {
        let x = parameter.cell.frame.width - 17 - 5
        let varybybutton = PSVaryByButton(frame:NSRect(x: x, y: y, width: 22, height: 22))
        varybybutton.autoresizingMask = [NSAutoresizingMaskOptions.ViewMinXMargin, NSAutoresizingMaskOptions.ViewMinYMargin]
        parameter.cell.addSubview(varybybutton)

        
        varybybutton.menu = parameter.scriptData.getVaryByMenu(parameter, action: "clickMenuItem:")
        
        let title_label = NSTextField(frame: NSMakeRect(PSDefaultConstants.ActionsBuilder.labelsLeftMargin, y+3, PSDefaultConstants.ActionsBuilder.controlsLeftMargin - PSDefaultConstants.ActionsBuilder.labelsLeftMargin, 17))
        title_label.autoresizingMask = [NSAutoresizingMaskOptions.ViewMaxXMargin, NSAutoresizingMaskOptions.ViewMinYMargin]
        title_label.stringValue = parameter.name
        title_label.bezeled = false
        title_label.drawsBackground = false
        title_label.editable = false
        title_label.selectable = false
        title_label.font = NSFont.systemFontOfSize(11)
        parameter.cell.addSubview(title_label)
    }
    
    func setElementViewerControls(gotoEntryBlock : () -> ()) {
        //vary by button
        
        let x = parameter.cell.frame.width - 80
        let varybybutton = PSVaryByButton(frame:NSRect(x: x, y: defaultYLocation + 22, width: 22, height: 22))
        //varybybutton.autoresizingMask = NSAutoresizingMaskOptions.ViewMinXMargin | NSAutoresizingMaskOptions.ViewMinYMargin
        varybybutton.menu = parameter.scriptData.getVaryByMenu(parameter, action: "clickMenuItem:")
        parameter.cell.addSubview(varybybutton)
        
        //title
        let title_label = NSTextField(frame: NSMakeRect(PSDefaultConstants.ActionsBuilder.labelsLeftMargin, defaultYLocation + 26, 140, 17))
        //title_label.autoresizingMask = NSAutoresizingMaskOptions.ViewMinXMargin | NSAutoresizingMaskOptions.ViewMinYMargin
        title_label.stringValue = parameter.name
        title_label.bezeled = false
        title_label.drawsBackground = false
        title_label.editable = false
        title_label.selectable = false
        title_label.font = NSFont.systemFontOfSize(12)
        parameter.cell.addSubview(title_label)
        
        //go to button
        if parameter.varyByEntryName != nil {
            let gotoEntryButton = PSBlockButton(frame: NSMakeRect(150, defaultYLocation + 22, 180, 22), block: gotoEntryBlock)
            gotoEntryButton.title = "Goto referenced entry..."
            gotoEntryButton.bezelStyle = NSBezelStyle.RoundedBezelStyle
            parameter.cell.addSubview(gotoEntryButton)
        }
    }
}

class PSBlockButton : NSButton {
    let block : (() -> ())
    init(frame frameRect: NSRect, block : (() -> ())) {
        self.block = block
        super.init(frame: frameRect)
        self.target = self
        self.action = "clickedMyself:"
    }
    
    func clickedMyself(_: AnyObject) {
        block()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}