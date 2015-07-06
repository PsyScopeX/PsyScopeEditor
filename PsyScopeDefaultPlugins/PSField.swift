//
//  PSField.swift
//  PsyScopeEditor
//
//  Created by James on 13/02/2015.
//

import Foundation

class PSField : PSStringList {
    var type : PSAttributeType
    var list : PSList
    var interface : PSAttributeInterface?
    
    init(entry: Entry, list : PSList, interface: PSAttributeInterface?, scriptData: PSScriptData) {
        self.type = PSAttributeType(fullType: entry.type)
        self.list = list
        self.interface = interface
        super.init(entry: entry, scriptData: scriptData)
    }
    
    func changeType(newType: PSAttributeType) {
        self.type = newType
        self.entry.type = newType.fullType
    }
    
}