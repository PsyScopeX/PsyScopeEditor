//
//  Constants.swift
//  PsyScopeEditor
//
//  Created by James on 03/09/2014.
//

import Cocoa

class PSDefaultConstants {
    
    struct Spacing {
        //template layout board stuff
        static let TLBlabelYOffset = -8
        static let TLBlabelX = 0
        static let TLBfontSize : CGFloat = CGFloat(14)
        static let TLBiconX = 110
        static let TLBboxX = 145
        static let TLBeventYSpacing : Int = 40
        static let TLBtimeBarWidth : CGFloat = CGFloat(20)
        static let TLBlabelLength : CGFloat = CGFloat(80)
        static let TLBtimeBarViewHeight = CGFloat(30)

        //vary by icon size
        static let VaryByIconSize = CGFloat(20)
        static let VaryByTextYOffset = CGFloat(6)
    }
    
    //These refer to string pairs dictionaries held in DefaultPluginResources.plist
    struct StringPairDictionaryResources {
        static let ExperimentDataFieldsCheckBoxes = "experimentDataFieldsCheckBoxes"
    }
    
    struct ActionsBuilder {
        static let headerLeftMargin = CGFloat(20)
        static let labelsLeftMargin = CGFloat(12)
        static let labelsRightMargin = CGFloat(10)
        static let controlsLeftMargin = CGFloat(75)
        static let controlsRightMargin = CGFloat(27)
        static let summaryLabelLeftMargin = CGFloat(100)
    }
    
    struct TemplateLayoutBoard {
        static let fixedTimeColor =
         NSColor(calibratedRed: 0.40, green: 0.67, blue: 0.82, alpha: 1).CGColor
         //NSColor(calibratedRed: 0.73, green: 0.84, blue: 0.89, alpha: 1).CGColor
//lucaL changed to experiment for a more uniform interface. I remove the change in color for the moment
        //NSColor(calibratedRed: 0.40, green: 0.67, blue: 0.82, alpha: 1).CGColor
        static let unknownTimeColor =
        NSColor(calibratedRed: 0.40, green: 0.67, blue: 0.82, alpha: 1).CGColor
        //NSColor(calibratedRed: 0.73, green: 0.84, blue: 0.89, alpha: 1).CGColor
        
        //lucaL changed to experiment for a more uniform interface
        //NSColor(calibratedRed: 0.67, green: 0.40, blue: 0.82, alpha: 1).CGColor
        static let lengthOfUnknownTimeBars = CGFloat(100)
    }
    

    
    struct DefaultAttributeValues {
        //Basic attributes
        static let PSExperimentBackColour = "White"
        static let PSExperimentDefaultColour = "Black"
        static let PSExperimentPrecompile = "All"
        static let PSExperimentDataFields = ""
        static let PSExperimentInstructions = ""
        static let PSExperimentLogFile = ""
        static let PSExperimentDebriefing = ""
        static let PSExperimentRestPeriod = "1000"
        static let PSExperimentNumberRestPeriods = "1"
        static let PSExperimentTrialsPerRest = "10"
        static let PSExperimentDecimalPlaces = "2"
        static let PSAttribute_Port = ""
        static let PSAttribute_Position = ""
        static let PSAttribute_TextStimulus = ""
        static let PSAttribute_TextStyle = "Chicago"
        static let PSAttribute_TextColor = "0 0 0"
        static let PSAttribute_TextFont = "Chicago"
        static let PSAttribute_TextFace = "Bold"
        static let PSAttribute_TextSize = "12"
        static let PSAttribute_TextEventDegradation = "0.0 0.0"
        static let PSAttribute_TextEventSpecial = ""
        static let PSAttribute_TextMask = "X"
        static let PSAttributeFlip = ""
        static let PSAttribute_PictureEventFeature = ""
        static let PSAttribute_PictureEventDegradation = "0.0 0.0"
        static let PSAttribute_PictureEventDepth = "1"
        static let PSAttribute_PictureEventFilename = ""
        static let PSAttribute_ParagraphEventStimulus = ""
        static let PSAttribute_PasteBoardEventDegradation = "0.0 0.0"
        static let PSAttribute_PasteBoardEventDepth = "1"
        
        //Different values for Duration for events
        static let PSDefaultEventDuration = "Key[ Any ]"
        static let PSMovieEventDuration = "Movie[ Done ]"
        static let PSSoundEventDuration = "Sound[]"
        
        //Default value for start ref for events
        static let PSDefaultEventStartRef = "\"0 after end of START\""
        
        
        static let PSTextEventDuration = "Key[ Any ]"
        static let PSPictureEventDuration = "Key[ Any ]"
        static let PSKeySequenceEventDuration = "Key [ Return ]"
 
        static let PSInputEventDuration = "Key[ Any ]"
  
        static let PSPasteBoardEventDuration = "Key[ Any ]"
        static let PSDocumentEventDuration = "Key[ Any ]"
        static let PSParagraphEventDuration = "Key[ Any ]"
        static let PSTimeEventDuration = "500"
        
    
    }
    
    struct StructuralProperties {
        static let Experiments = PSProperty(name: "Experiments",defaultValue: "")
        static let Groups = PSProperty(name: "Groups", defaultValue: "")
        static let Blocks = PSProperty(name: "Blocks", defaultValue: "")
        static let Templates = PSProperty(name: "Templates", defaultValue: "")
        static let Events = PSProperty(name: "Events", defaultValue: "")
        static let Factors = PSProperty(name: "Factors", defaultValue: "")
        static let MutuallyExclusiveSet = [StructuralProperties.Experiments,
            StructuralProperties.Groups,
            StructuralProperties.Blocks,
            StructuralProperties.Templates,
            StructuralProperties.Events]
        static let All = [StructuralProperties.Experiments,
                        StructuralProperties.Groups,
                        StructuralProperties.Blocks,
                        StructuralProperties.Templates,
                        StructuralProperties.Events,
                        StructuralProperties.Factors]
    }
}

