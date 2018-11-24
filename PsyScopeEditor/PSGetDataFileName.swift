//
//  PSGetDataFileName.swift
//  PsyScopeEditor
//
//  Created by James on 09/11/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

func PSGetDataFileName(_ scriptData : PSScriptData) -> String {
    guard let experimentsEntry = scriptData.getMainExperimentEntryIfItExists(),
        dataFileEntry = scriptData.getSubEntry("DataFile", entry: experimentsEntry) else {
            return ""
    }
    
    if dataFileEntry.currentValue.lowercased() == "@autodatafile" {
        if let adf = scriptData.getBaseEntry("AutoDataFile") {
            return adf.currentValue
        }
    } else {
        return PSUnquotedString(dataFileEntry.currentValue)
    }
    
    return ""
}
