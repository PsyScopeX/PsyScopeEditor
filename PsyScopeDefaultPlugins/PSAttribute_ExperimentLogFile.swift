//
//  PSAttribute_ExperimentLogFile.swift
//  PsyScopeEditor
//
//  Created by James on 28/04/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAttribute_ExperimentLogFile : PSExperimentAttribute {
    
    override init() {
        super.init()
        userFriendlyNameString = "Log File"
        helpfulDescriptionString = "A location to store the log file"
        codeNameString = "LogFile"
        attributeClass = PSAttributeParameter_FileSave.self
        defaultValueString = PSDefaultConstants.DefaultAttributeValues.PSExperimentLogFile
    }
}