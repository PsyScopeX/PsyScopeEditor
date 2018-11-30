//
//  DefaultPlugins.swift
//  PsyScopeEditor
//
//  Created by James on 15/07/2014.
//

import Cocoa

var PSDefaultPluginBundle : Bundle = Bundle(for:DefaultPlugins.self)

public class DefaultPlugins: NSObject, PSPluginInterface {
    

    public static func pluginsFor(_ pluginTypeName: PSPluginType) -> [NSObject.Type] {
        switch pluginTypeName {
            case .tool:
                return [PSExperimentTool.self,PSGroupTool.self, PSBlockTool.self, PSTemplateTool.self, PSListTool.self, PSVariableTool.self, PSBlankEntryTool.self, PSDialogVariableTool.self]
            case .attribute:
                return [PSExperimentDataFields.self, PSExperimentInstructions.self, PSExperimentDebriefing.self, PSExperimentRestPeriod.self, PSExperimentNumberRestPeriods.self, 
                    PSExperimentTrialsPerRest.self, 
                    PSExperimentDecimalPlaces.self, 
                    PSAttribute_ExperimentPrecompile.self, 
                    PSAttribute_ExperimentDefaultColour.self, 
                    PSAttribute_ExperimentBackColour.self, 
                    PSAttribute_Port.self, 
                    PSAttribute_Position.self, 
                    PSAttribute_TextStimulus.self, 
                        PSAttribute_TextStyle.self, 
                        PSAttribute_TextColor.self, 
                        PSAttribute_TextFont.self, 
                        PSAttribute_TextFace.self,
                        PSAttribute_TextSize.self, 
                        PSAttribute_TextEventDegradation.self, 
                        PSAttribute_TextEventSpecial.self, 
                        PSAttribute_TextMask.self, 
                        PSAttributeFlip.self, 
                        PSAttribute_PictureEventFeature.self, 
                        PSAttribute_PictureEventDegradation.self, 
                        PSAttribute_PictureEventDepth.self, 
                        PSAttribute_PictureEventFilename.self, 
                        PSDocumentFileAttribute.self, 
                        PSParagraphStimulusAttribute.self, 
                        PSAttribute_PasteBoardEventDegradation.self, 
                        PSAttribute_PasteBoardEventFlip.self, 
                        PSAttribute_PasteBoardEventPort.self, 
                        PSAttribute_PasteBoardEventDepth.self, 
                        PSAttribute_KeySequenceStimulus.self, 
            PSAttribute_SoundFile.self, 
            PSAttribute_SoundVolume.self, 
            PSAttribute_SoundFeature.self, 
            PSAttribute_SoundChannel.self, 
            PSAttribute_MovieStimulus.self, 
            PSAttribute_MovieTag.self, 
            PSAttribute_MovieRate.self, 
            PSAttribute_MovieRepeat.self, 
            PSAttribute_MovieFromTime.self, 
            PSAttribute_MovieToTime.self, 
            PSAttribute_MovieVolume.self]
            case .event:
                return [PSTimeEvent.self, PSTextEvent.self, PSPictureEvent.self, PSKeySequenceEvent.self, PSMovieEvent.self, PSInputEvent.self, PSSoundEvent.self, PSPasteBoardEvent.self, PSDocumentEvent.self, PSParagraphEvent.self]
            case .windowView:
                return [PSTemplateBuilder.self, PSActionsBuilder.self]
            case .action:
                return [PSAction_AbortEvent.self, PSAction_AddToList.self, PSAction_Beep.self, PSAction_CancelAction.self, PSAction_ClearPort.self, 
                    PSAction_AbortEvent.self, PSAction_ChanceEvent.self, PSAction_ClearScreen.self, PSAction_ClearStim.self, PSAction_DrawAllPortBorders.self, PSAction_DrawPortBorder.self, PSAction_EndEvent.self, PSAction_MaskStim.self, PSAction_NewListItem.self, PSAction_NextCrossing.self, PSAction_QuitBlock.self, PSAction_RemoveFromList.self, PSAction_RemovePortBorder.self, PSAction_RerunTrial.self, PSAction_ReverseVideo.self, PSAction_RT.self, PSAction_RunEvent.self, PSAction_Set.self, PSAction_SetBackColor.self, PSAction_SetDefaultColor.self, PSAction_ScriptEval.self, PSAction_ScheduleEvent.self, PSAction_ShowStim.self, PSAction_UnscheduleEvent.self, PSAction_MousePos.self, PSAction_MouseSwitch.self, PSAction_MouseTo.self, PSAction_MovieDo.self, PSAction_QuitTrial.self, PSAction_SerialOut.self, PSAction_SysCmd.self, PSAction_TCPDo.self, PSAction_GetTimestamp.self]
            case .condition:
                return [PSCondition_Key.self, PSCondition_Mouse.self, PSCondition_Movie.self, PSCondition_Sound.self, PSCondition_SysCmd.self, PSCondition_TCP.self, PSCondition_End.self, PSCondition_Start.self, PSCondition_When.self, PSCondition_ScriptWhen.self]
        }
    }
    
}
