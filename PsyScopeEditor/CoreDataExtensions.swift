//
//  CoreDataExtensions.swift
//  PsyScopeEditor
//
//  Created by James on 07/10/2014.
//

import Foundation

extension Entry {
    //return subentries that are not properties
    func getAttributes() -> [Entry] {
        var attributes : [Entry] = []
        for subEntry in self.subEntries.array as! [Entry] {
            if !subEntry.isProperty.boolValue {
                attributes.append(subEntry)
            }
        }
        return attributes
    }
    
    func attributeNamed(_ name : String) -> Entry? {
        let attributes = self.getAttributes()
        for a in attributes {
            if a.name == name {
                return a
            }
        }
        return nil
    }
}
