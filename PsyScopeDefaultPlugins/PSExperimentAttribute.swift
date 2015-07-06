//
//  PSExperimentAttribute.swift
//  PsyScopeEditor
//
//  Created by James on 17/09/2014.
//

import Foundation

class PSExperimentAttribute : PSAttributeGeneric {
    override init() {
        super.init()
        toolsArray = [PSExperimentTool().type()]
    }
}


class PSExperimentTrialsPerRest : PSExperimentAttribute {
    
    override init() {
        super.init()
        userFriendlyNameString = "Trials Per Rest"
        helpfulDescriptionString = "The number of trials to pass before a rest period"
        codeNameString = "NumTrialsPerRest"
        attributeClass = PSAttributeParameter_Int.self
        defaultValueString = PSDefaultConstants.DefaultAttributeValues.PSExperimentTrialsPerRest
    }
}

class PSExperimentNumberRestPeriods : PSExperimentAttribute {
    
    override init() {
        super.init()
        userFriendlyNameString = "Number of Rests"
        helpfulDescriptionString = "The number of rest periods"
        codeNameString = "NumRestPeriods"
        attributeClass = PSAttributeParameter_Int.self
        defaultValueString = PSDefaultConstants.DefaultAttributeValues.PSExperimentNumberRestPeriods
    }
}

class PSExperimentRestPeriod : PSExperimentAttribute {
    
    override init() {
        super.init()
        userFriendlyNameString = "Rest Duration"
        helpfulDescriptionString = "The length of resting in ms"
        codeNameString = "RestPeriod"
        attributeClass = PSAttributeParameter_Int.self
        defaultValueString = PSDefaultConstants.DefaultAttributeValues.PSExperimentRestPeriod
    }
}

class PSExperimentDataFile : PSExperimentAttribute {
    
    override init() {
        super.init()
        userFriendlyNameString = "Data File"
        helpfulDescriptionString = "A location to store the data file"
        codeNameString = "DataFile"
        attributeClass = PSAttributeParameter_FileSave.self
        defaultValueString = PSDefaultConstants.DefaultAttributeValues.PSExperimentDataFile
    }
}

class PSExperimentDebriefing : PSExperimentAttribute {
    
    override init() {
        super.init()
        userFriendlyNameString = "Debriefing File"
        helpfulDescriptionString = "A text file with the debriefing information in"
        codeNameString = "Debrief"
        attributeClass = PSAttributeParameter_FileOpen.self
        defaultValueString = PSDefaultConstants.DefaultAttributeValues.PSExperimentDebriefing
    }
}

class PSExperimentInstructions : PSExperimentAttribute {
    
    override init() {
        super.init()
        userFriendlyNameString = "Instructions File"
        helpfulDescriptionString = "A text file with the instructions in"
        codeNameString = "Instructions"
        attributeClass = PSAttributeParameter_FileOpen.self
        defaultValueString = PSDefaultConstants.DefaultAttributeValues.PSExperimentInstructions
    }
}

class PSExperimentDecimalPlaces : PSExperimentAttribute {
    
    override init() {
        super.init()
        userFriendlyNameString = "Decimal Places"
        helpfulDescriptionString = "The number of decimal places to store numbers"
        codeNameString = "DecimalPlaces"
        attributeClass = PSAttributeParameter_Int.self
        defaultValueString = PSDefaultConstants.DefaultAttributeValues.PSExperimentDecimalPlaces
    }
}
