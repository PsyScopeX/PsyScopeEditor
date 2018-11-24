//
//  PSAttributePickerEntry.swift
//  PsyScopeEditor
//
//  Created by James on 16/04/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

//automatically updates an entry with attributes that are picked while popup is open
open class PSAttributePickerEntry : PSAttributePicker {
    
    public init(entry: Entry, scriptData: PSScriptData) {
        self.entry = entry
        super.init(scriptData: scriptData)
    }
    
    let entry : Entry
    
    //MARK: Overrides
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        //populate existing entries
        if let ea = entry.subEntries.array as? [Entry] {
            for entry in ea {
                if entry.type != "" {
                    let type = PSAttributeType(fullType: entry.type)
                    self.existingAttributes.append(type)
                }
            }
        }
        
        //auto select entries category if found
        for category in categories {
            if category.name == self.entry.type {
                self.attributePopupButton.selectItem(withTitle: category.userFriendlyName)
                break
            }
        }
    }
    
    override func attributeButtonClicked(_ row : Int, clickedOn : Bool) {
        super.attributeButtonClicked(row, clickedOn: clickedOn)
        let type = tableViewAttributes[row].type
        let interface = tableViewAttributes[row].attribute
        if clickedOn {
            addAttributeToEntry(interface!, type: type)
        } else {
            removeAttributeFromEntry(interface!)
        }
    }
    
    
    
    // MARK: Entry Modification
    
    func addAttributeToEntry(_ interface : PSAttributeInterface, type : PSAttributeType) {
        //add the new entry - warn if exisiting incompatible type
        if let existing_att = scriptData.getSubEntry(interface.codeName(), entry: entry) {
            if existing_att.type != type.fullType {
                //are the types compatible?
                let exisiting_type = PSAttributeType(fullType: existing_att.type)
                var incompatible = true
                for compatibleTool in interface.tools() as! [String] {
                    if compatibleTool == exisiting_type.parentType.name {
                        incompatible = false
                    }
                }
                if incompatible {
                    //show warning
                    let question = "Do you want to replace attribute \"\(interface.codeName())\" of type \"\(exisiting_type.parentType.name)\" with type \"\(type.parentType.name)\"?"
                    let info = "These attributes have the same name, but are not compatible, and take different types of values."
                    let quitButton = "Replace"
                    let cancelButton = "Cancel"
                    let alert = NSAlert()
                    alert.messageText = question
                    alert.informativeText = info
                    alert.addButton(withTitle: quitButton)
                    alert.addButton(withTitle: cancelButton)
                    
                    let answer = alert.runModal()
                    if answer == NSApplication.ModalResponse.alertFirstButtonReturn {
                        existing_att.type = type.fullType
                        existing_att.currentValue = interface.defaultValue()
                        existing_att.isProperty = false
                    }
                } else {
                    let question = "There is already an attribute \"\(interface.codeName())\" of type \"\(exisiting_type.parentType.name)\" in this entry which is compatible with type \"\(type.parentType.name)\"."
                    let info = "These attributes are interchangable, and have the same name, but it is not possible to have more than one."
                    let okButton = "OK"
                    let alert = NSAlert()
                    alert.messageText = question
                    alert.informativeText = info
                    alert.addButton(withTitle: okButton)
                    _ = alert.runModal()
                }
                
            } else {
                //attribute with same type found - maybe is incorrectly property?
                existing_att.type = type.fullType
                existing_att.currentValue = interface.defaultValue()
                existing_att.isProperty = false
            }
        } else {
            let att = scriptData.getOrCreateSubEntry(interface.codeName(), entry: entry, isProperty: false, type: type)
            att.currentValue = interface.defaultValue()
            att.type = type.fullType
        }
    }
    
    func removeAttributeFromEntry(_ interface : PSAttributeInterface) {
        scriptData.deleteNamedSubEntryFromParentEntry(entry, name: interface.codeName())
    }

}
