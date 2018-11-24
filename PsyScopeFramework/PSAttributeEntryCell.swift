//
//  PSAttributeCell.swift
//  PsyScopeEditor
//
//  Created by James on 09/02/2015.
//

import Foundation

//stores an entry and updates entry when updateScript is called
open class PSAttributeEntryCellView : PSAttributeCellView {
    var entry : Entry

    public init(entry: Entry, attributeParameter: PSAttributeParameter, interface: PSAttributeInterface, scriptData: PSScriptData) {
        self.entry = entry
        super.init(attributeParameter: attributeParameter,interface: interface,scriptData: scriptData)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

        
    open override func updateScript() {
        super.updateScript()
        self.entry.currentValue = self.attributeParameter.currentValue.stringValue()
    }

}
