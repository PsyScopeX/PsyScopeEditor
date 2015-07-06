//
//  PSAttributeStringCell.swift
//  PsyScopeEditor
//
//  Created by James on 13/02/2015.
//

import Foundation

//holds a single attribute parameter
public class PSAttributeCellView : PSCellView {
    public var attributeParameter : PSAttributeParameter
    public var interface : PSAttributeInterface
    public init(attributeParameter : PSAttributeParameter, interface : PSAttributeInterface, scriptData : PSScriptData) {
        self.attributeParameter = attributeParameter
        self.interface = interface
        
        super.init(frame: NSRect(x: 0, y: 0, width: 200, height: 30))
        self.scriptData = scriptData
        self.autoresizesSubviews = true
        self.toolTip = interface.helpfulDescription()
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}