//
//  DefaultPlugins.swift
//  PsyScopeEditor
//
//  Created by James on 15/07/2014.
//

import Cocoa

var PSDefaultPlugins : [PSToolInterface] = DefaultPlugins.getAllTools()

var PSDefaultPluginBundle : NSBundle = NSBundle(forClass:DefaultPlugins.self)

class DefaultPlugins: NSObject, PSPluginInterface {
    
    class func getAllTools() -> [PSToolInterface] {
        var return_array : [PSToolInterface] = []
        for tool in pluginsFor(.Tool)! {
            if let tool_name = tool as? String {
                let instance = instantiatePlugin(tool_name) as! PSToolInterface
                return_array.append(instance)
            }
        }
        
        for event in pluginsFor(.Event)! {
            if let tool_name = event as? String {
                let instance = instantiatePlugin(tool_name) as! PSToolInterface
                return_array.append(instance)
            }
        }
        return return_array
    }
  
    class func initializeClass(theBundle : NSBundle?) -> Bool {
        return true
    }
    
    class func pluginsFor(pluginTypeName: PSPluginType) -> [AnyObject]? {
        switch pluginTypeName {
            case .Tool:
                return ["PSExperimentTool","PSGroupTool", "PSBlockTool","PSTemplateTool","PSListTool", "PSTableTool", "PSVariableTool","PSBlankEntryTool", "PSDialogVariableTool"]
            case .Attribute:
                return ["PSExperimentDataFields", "PSExperimentInstructions", "PSExperimentDebriefing", "PSExperimentRestPeriod", "PSExperimentNumberRestPeriods",
                    "PSExperimentTrialsPerRest",
                    "PSExperimentDecimalPlaces",
                    "PSAttribute_ExperimentPrecompile",
                    "PSAttribute_ExperimentDefaultColour",
                    "PSAttribute_ExperimentBackColour",
                    "PSAttribute_ExperimentInputDevices",
                    "PSAttribute_Port",
                    "PSAttribute_Position",
                    "PSAttribute_TextStimulus",
                        "PSAttribute_TextStyle",
                        "PSAttribute_TextColor",
                        "PSAttribute_TextFont",
                        "PSAttribute_TextFace",
                    
                        "PSAttribute_TextSize",
                        "PSAttribute_TextEventDegradation",
                        "PSAttribute_TextEventSpecial",
                        "PSAttribute_TextMask",
                        "PSAttributeFlip",
                        "PSAttribute_PictureEventFeature",
                        "PSAttribute_PictureEventDegradation",
                        "PSAttribute_PictureEventDepth",
                        "PSAttribute_PictureEventFilename",
                        "PSDocumentFileAttribute",
                        "PSParagraphStimulusAttribute",
                        "PSAttribute_PasteBoardEventDegradation",
                        "PSAttribute_PasteBoardEventFlip",
                        "PSAttribute_PasteBoardEventPort",
                        "PSAttribute_PasteBoardEventDepth",
                        "PSAttribute_KeySequenceStimulus",
            "PSAttribute_SoundFile",
            "PSAttribute_SoundVolume",
            "PSAttribute_SoundFeature",
            "PSAttribute_SoundChannel",
            "PSAttribute_MovieStimulus",
            "PSAttribute_MovieTag",
            "PSAttribute_MovieRate",
            "PSAttribute_MovieRepeat",
            "PSAttribute_MovieFromTime",
            "PSAttribute_MovieToTime",
            "PSAttribute_MovieVolume"]
            case .Event:
                return ["PSTimeEvent", "PSTextEvent", "PSPictureEvent", "PSKeySequenceEvent", "PSMovieEvent", "PSInputEvent", "PSSoundEvent", "PSPasteBoardEvent", "PSDocumentEvent", "PSParagraphEvent"]
            case .WindowView:
                return ["PSTemplateBuilder", "PSActionsBuilder"]
            case .Action:
                return ["PSAction_AbortEvent", "PSAction_AddToList","PSAction_Beep","PSAction_CancelAction","PSAction_ClearPort",
                    "PSAction_AbortEvent", "PSAction_ChanceEvent", "PSAction_ClearScreen", "PSAction_ClearStim", "PSAction_DrawAllPortBorders", "PSAction_DrawPortBorder","PSAction_EndEvent","PSAction_MaskStim","PSAction_NewListItem","PSAction_NextCrossing","PSAction_QuitBlock","PSAction_RemoveFromList","PSAction_RemovePortBorder","PSAction_RerunTrial","PSAction_ReverseVideo","PSAction_RT","PSAction_RunEvent","PSAction_Set","PSAction_SetBackColor","PSAction_SetDefaultColor","PSAction_ScriptEval","PSAction_ScheduleEvent","PSAction_ShowStim","PSAction_UnscheduleEvent","PSAction_MousePos","PSAction_MouseSwitch","PSAction_MouseTo","PSAction_MovieDo", "PSAction_QuitTrial","PSAction_SerialOut","PSAction_SysCmd", "PSAction_TCPDo", "PSAction_Tobii", "PSAction_TobiiPlus", "PSAction_GetTimestamp"]
            case .Condition:
                return ["PSCondition_Key","PSCondition_Mouse","PSCondition_Movie", "PSCondition_Sound", "PSCondition_SysCmd", "PSCondition_TCP","PSCondition_TobiiPlus", "PSCondition_End", "PSCondition_Start", "PSCondition_When", "PSCondition_ScriptWhen"]
            default:
                return []
        }
    }
    
    class func getInstanceOfType(pluginType : String) -> PSToolInterface {
        for plugin in PSDefaultPlugins {
            if plugin.type() == pluginType {
                return plugin
            }
        }
        fatalError("Plugin \"\(pluginType)\" not found")
    }
    
    class func instantiatePlugin(pluginName: String!) -> AnyObject! {
        let className = fixSwiftClassName(pluginName)
        let anyobjectype : AnyObject.Type = NSClassFromString(className)!
        let nsobjectype : NSObject.Type = anyobjectype as! NSObject.Type
        return nsobjectype.init()

    }
    
    class func getPSExtensionClass(pluginName: String!) -> AnyObject! {
        let className = fixSwiftClassName(pluginName)
        let class_from_string: AnyClass! = NSClassFromString(className)
        return class_from_string
    }
    
    class func fixSwiftClassName(string : String) -> String {
        if string.rangeOfString("PsyScopeDefaultPlugins.") == nil {
            return "PsyScopeDefaultPlugins.\(string)"
        }
        return string
    }
}
