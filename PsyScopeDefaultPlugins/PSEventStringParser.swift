//
//  PSEventStringParser.swift
//  PsyScopeEditor
//
//  Created by James on 13/09/2014.
//

import Cocoa

class PSEventStringParser: NSObject {
    
    //given a PSTemplateEvent, as well as the other events in the template, this will parse and set the startCondition and durationCondition based on the attributes StartRef and Duration
    class func parseForTemplateLayoutBoardEvent(event : PSTemplateEvent, events : [PSTemplateEvent]) {
        let scriptData = event.scriptData
        
        if let startref = scriptData.getSubEntry("StartRef", entry: event.entry),
            sc = startConditionForStartRefEntry(startref, events: events) {
                event.initStartCondition(sc)
        } else {
            //get index of previous event
            if let index = events.indexOf(event) where index.predecessor() > -1 {
                event.initStartCondition(EventStartConditionDefault(ev: events[index.predecessor()]))
            } else {
                event.initStartCondition(EventStartConditionDefault())
            }
        }
        
        
        
        if let duration = scriptData.getSubEntry("Duration", entry: event.entry),
            dc = durationConditionForEntry(duration, scriptData: scriptData) {
                event.initDurationCondition(dc)
        } else {
            event.initDurationCondition(EventDurationConditionFixedTime(time: 500))
        }
    }
    
    class func startConditionForStartRefEntry(entry : Entry, events : [PSTemplateEvent]) -> EventStartCondition? {
        let string = entry.currentValue
        if string == "NONE" {
            if let positionTime = Int(entry.metaData) {
                return EventStartConditionUnscheduled(fakePositionTime: EventMSecs(positionTime))
            } else {
                return EventStartConditionUnscheduled()
            }
        }
        
        let quoted_string = string.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "\""))
        if string == "" {
            print("Error: empty string")
        }else if quoted_string == string {
            //TODO error
            print("Error: string not in quotes")
        } else {
            var components = quoted_string.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            if components.count == 5 {
                let number = EventTime.FixedTime(CGFloat(NSString(string:components[0]).floatValue))
                switch components[4] {
                    case "START":
                        let event_start = EventStartConditionTrialStart()
                        event_start.event_time = number
                        return event_start
                    default:
                        //need to get event 
                        var event : PSTemplateEvent? = nil
                        for ev in events {
                            if ev.entry.name == components[4] {
                                event = ev
                                break
                            }
                        }
                        
                        if (event == nil) {
                            //TODO error , event not found
                            print("Error: event not found")
                            return nil
                        }
                        
                        switch components[2] {
                            case "start":
                                let event_start = EventStartConditionEventStart()
                                event_start.event = event
                                event_start.event_time = number
                                return event_start
                            case "end":
                                let event_start = EventStartConditionEventEnd()
                                event_start.event = event
                                event_start.event_time = number
                                return event_start
                            default:
                                //TODO error , event not found
                                print("Error: event token start/end not found")
                                return nil
                        }
                    
                }
            }
        }
        //TODO error , event not found
        print("Error: event not found")
        return nil
    }
    
    class func durationConditionForEntry(entry : Entry, scriptData : PSScriptData) -> EventDurationCondition? {
        let string = entry.currentValue
        if string == "Self_Terminate" {
            return EventDurationConditionSelfTerminate()
        } else if string == "Trial_End" {
            return EventDurationConditionTrialEnd()
        } else if let n = Int(string) {
            let event_dur = EventDurationConditionFixedTime(time: n)
            return event_dur
        } else {
            //other condition
            return EventDurationConditionOther(conditionsEntry: entry,scriptData: scriptData)
        }
    }
}
