//
//  PSDefaultPropertiesView.swift
//  PsyScopeEditor
//
//  Created by James on 24/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSDefaultPropertiesViewController : PSToolPropertyController {
    
    @IBOutlet var valueText : NSTextField!
    
    init(entry : Entry, scriptData : PSScriptData) {
        let bundle = Bundle(for:type(of: self))
        super.init(nibName: "DefaultPropertiesView", bundle: bundle, entry: entry, scriptData: scriptData)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        parseValue()
    }
    
    override func refresh() {
        super.refresh()
        parseValue()
    }
    
    func parseValue() {
        valueText.stringValue = entry.currentValue
    }
    
    override func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        updateEntry()
        return super.control(control, textShouldEndEditing: fieldEditor)
    }
    
    func updateEntry() {
        entry.currentValue = valueText.stringValue
    }
}
