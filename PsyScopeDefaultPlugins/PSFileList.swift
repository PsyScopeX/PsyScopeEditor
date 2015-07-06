//
//  PSFileList.swift
//  PsyScopeEditor
//
//  Created by James on 27/05/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSFileList {
    
    let entry : Entry
    let scriptData : PSScriptData
    
    init(entry : Entry, scriptData : PSScriptData) {
        self.entry = entry
        self.scriptData = scriptData
    }
    
    var filePath : String {
        get {
            if let fileListEntry = scriptData.getSubEntry("ListFile", entry: entry) {
                return PSScriptFile.PathFromFileRef(fileListEntry.currentValue, scriptData: scriptData)
            } else {
                return ""
            }
        }
        set {
            if "" != newValue {
                let fileListEntry = scriptData.getOrCreateSubEntry("ListFile", entry: entry, isProperty: true)
                fileListEntry.currentValue = PSScriptFile.FileRefFromPath(newValue, scriptData: scriptData)
            } else {
                scriptData.deleteNamedSubEntryFromParentEntry(entry, name: "ListFile")
            }
        }
    }
    
    var fileReader : PSListFileReader? {
        get {
            var error : NSError?
            let listFileReader: PSListFileReader?
            do {
                listFileReader = try PSListFileReader(contentsOfPath: self.filePath)
            } catch var error1 as NSError {
                error = error1
                listFileReader = nil
            }
            if listFileReader == nil {
                PSModalAlert("Error reading file")
            }
            return listFileReader
        }
    }
    
    var numberOfColumns : Int {
        get {
            if let numberOfColumnsEntry = scriptData.getSubEntry("NumberOfColumnsInFile", entry: entry),
             intValue = Int(numberOfColumnsEntry.currentValue) {
                return intValue
            } else if let fileReader = self.fileReader {
                return fileReader.numberOfColumnsInFirstRow
            }
            return 0
        }
        
        set {
            let numberOfColumnsEntry = scriptData.getOrCreateSubEntry("NumberOfColumnsInFile", entry: entry, isProperty: true)
            numberOfColumnsEntry.currentValue = "\(newValue)"
        }
    }
    
    var previewOfContents : [[String]] {
        var error : NSError?
        do {
            let listFileReader = try PSListFileReader(contentsOfPath: self.filePath, forceNumberOfColumns: self.numberOfColumns)
            return listFileReader.rows
        } catch var error1 as NSError {
            error = error1
            PSModalAlert("Error reading file")
            return []
        }
    }
    
    func nameOfColumn(columnIndex : Int) -> String? {
        /*Stimulus: @Column(THIS->ListFile THIS->NumberOfColumnsInFile @[OWNER->Column])
        Column:> 1
        Picture: @Column(THIS->ListFile THIS->NumberOfColumnsInFile @[OWNER->Column])
        Column:> 2
        Font: @Column(THIS->ListFile THIS->NumberOfColumnsInFile @[OWNER->Column])
        Column:> 3*/
        for subEntry in entry.subEntries.array as! [Entry] {
            if let columnSubEntry = scriptData.getSubEntry("Column", entry: subEntry),
                columnInt = Int(columnSubEntry.currentValue) {
                if columnInt == columnIndex {
                    return subEntry.name
                }
            }
        }
        return nil
    }
    
    func setColumn(name : String, columnIndex : Int) {
        let columnEntry = scriptData.getOrCreateSubEntry(name, entry: entry, isProperty: true)
        columnEntry.currentValue = "@Column(THIS->ListFile THIS->NumberOfColumnsInFile @[OWNER->Column])"
        let columnSubEntry = scriptData.getOrCreateSubEntry("Column", entry: columnEntry, isProperty: true)
        columnSubEntry.currentValue = "\(columnIndex)"
                
    }
    
    func setupDefaultSubEntries() {
        if scriptData.getSubEntry("ListFile", entry: entry) == nil {
            scriptData.getOrCreateSubEntry("ListFile", entry: entry, isProperty: true).currentValue = "FileRef(\"NULL\")"
            scriptData.getOrCreateSubEntry("NumberOfColumnsInFile", entry: entry, isProperty: true).currentValue = "NULL"
            scriptData.getOrCreateSubEntry("Levels", entry: entry, isProperty: true).currentValue = "@Column(THIS->ListFile THIS->NumberOfColumnsInFile 1)"
        }
    }
    
    func renameColumnFrom(name : String, toName : String) {
        if let columnEntry = scriptData.getSubEntry(name, entry: entry) {
            columnEntry.name = toName
        }
    }
    
}