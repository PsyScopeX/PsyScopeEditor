//
//  PSTemplateLayoutBoardClasses.swift
//  PsyScopeEditor
//
//  Created by James on 16/09/2014.
//

import Foundation

//This enum stores a time in ms (or an unknown time) and has a function to convert it into a number of ms
enum EventTime {
    
    case FixedTime(EventMSecs)
    case Unknown(UnknownTime)
    func ToEventMSecs() -> EventMSecs {
        switch (self) {
        case let .FixedTime(ms_after):
            return ms_after
        case let .Unknown(effectiveVisualTime):
            if let effectiveVisualTime = effectiveVisualTime {
                return effectiveVisualTime
            } else {
                return PSDefaultConstants.TemplateLayoutBoard.lengthOfUnknownTimeBars //unknown length = 20 ms equivalent
            }
        }
    }
}

/*************************** EVENT DURATION CONDITIONS ************************/
// Sub classes of EventDurationCondition (which should technically be virtual) represent
// the duration of an event, and use EventTime to provide pixel locations etc for drawing
// also provides the name for it's selection in a menu, and a value for the Duration: entry

class EventDurationCondition {
    private var event_time : EventTime
    init() {
        event_time = EventTime.FixedTime(500)
    }
    
    var textFieldDurationTime : String? {
        get {
            switch (event_time) {
            case let .FixedTime(ms_after):
                let int : Int = Int(ms_after)
                return "\(int)"
            case let .Unknown(reason):
                return nil
            }
        }
    }
    
    func getValue() -> String {
        fatalError("Error must use EventDurationCondition subclass")
        return "Error"
    }
    
    func getDurationMS() -> EventMSecs {
        fatalError("Error must use EventDurationCondition subclass")
        return EventTime.Unknown(nil).ToEventMSecs()
    }
    
    func description() -> String {
        return ""
    }
    
    func durationKnown() -> Bool {
        return false
    }
    
    func getIcons() -> [NSImage] {
        fatalError("Error must use EventDurationCondition subclass")
    }
    
    func getTimelineText() -> String {
        return ""
    }
}

class EventDurationConditionFixedTime : EventDurationCondition {
    
    init(time: Int) {
        super.init()
        event_time = EventTime.FixedTime(CGFloat(time))
    }
    
    override func getDurationMS() -> EventMSecs {
        return event_time.ToEventMSecs()
    }
    
    override func getValue() -> String {
        switch event_time {
        case let .FixedTime(time_ms):
            let int : Int = Int(time_ms)
            return "\(int)"
        default:
            return "Error"
        }
    }
    
    override func description() -> String {
        let int : Int = Int(getDurationMS())
        return "\(int) ms"
    }
    
    override func durationKnown() -> Bool {
        return true
    }
    
    override func getIcons() -> [NSImage] {
        return []
    }
    
    override func getTimelineText() -> String {
        return description()
    }
}

class EventDurationConditionSelfTerminate : EventDurationCondition {
    override init() {
        super.init()
        event_time = EventTime.Unknown(nil)
    }
    
    override func getValue() -> String {
        return "Self_Terminate"
    }
    
    override func getDurationMS() -> EventMSecs {
        return event_time.ToEventMSecs()
    }
    
    override func description() -> String {
        return "Self Terminate"
    }
    
    override func getIcons() -> [NSImage] {
        let image : NSImage = NSImage(contentsOfFile: NSBundle(forClass:self.dynamicType).pathForImageResource("SelfTerminate")!)!
        return [image]
    }
}

class EventDurationConditionTrialEnd : EventDurationCondition {
    override init() {
        super.init()
        event_time = EventTime.Unknown(nil)
    }
    
    override func getValue() -> String {
        return "Trial_End"
    }
    
    override func getDurationMS() -> EventMSecs {
        return event_time.ToEventMSecs()
    }
    
    override func description() -> String {
        return "Trial End"
    }
    
    override func getIcons() -> [NSImage] {
        let image : NSImage = NSImage(contentsOfFile: NSBundle(forClass:self.dynamicType).pathForImageResource("Line")!)!
        return [image]
    }
}

class EventDurationConditionOther : EventDurationCondition {
    var entry : Entry
    var conditionsAttribute : PSConditionAttribute
    init(conditionsEntry : Entry, scriptData : PSScriptData) {
        entry = conditionsEntry
        conditionsAttribute = PSConditionAttribute(condition_entry: entry, scriptData: scriptData)
        super.init()
        event_time = EventTime.Unknown(nil)
    }
    
    func setToNever() {
        entry.currentValue = "Never"
    }
    
    override func getValue() -> String {
        return entry.currentValue
    }
    
    override func getDurationMS() -> EventMSecs {
        return event_time.ToEventMSecs()
    }
    
    override func description() -> String {
        return "Conditions..."
    }
    
    override func getIcons() -> [NSImage] {
        conditionsAttribute.parseFromEntry()
        var icons : [NSImage] = []
        for condition in conditionsAttribute.conditions {
            icons.append(condition.condition.icon())
        }
        
        if icons.count < 1 {
            //then do unknwon
            var image : NSImage = NSImage(contentsOfFile: NSBundle(forClass:self.dynamicType).pathForImageResource("Question-icon")!)!
            icons.append(image)
        }
        
        return icons
    }
}



/*************************** EVENT START CONDITIONS ************************/
// Sub classes of EventStartCondition (which also should technically be virtual) represent
// the start of an event, and use EventTime to provide pixel locations etc for drawing
// also provides the name for it's selection in a menu, and a value for the StartRef: entry


class EventStartCondition {
    
    
    var event_time : EventTime
    init() {
        event_time = EventTime.FixedTime(0)
    }
    
    
    func getStartMS(base_event : PSTemplateEvent) -> EventMSecs {
        return event_time.ToEventMSecs()
    }
    
    var textFieldStartTime : String? {
        get {
            switch (event_time) {
            case let .FixedTime(ms_after):
                let int : Int = Int(ms_after)
                return "\(int)"
            case let .Unknown(reason):
                return nil
            }
        }
    }
    
    func getValue() -> String {
        fatalError("Error use of parent class EventStartCondition")
    }
    
    func getMetaData() -> String {
        return ""
    }
    
    func menuName() -> String {
        fatalError("Error use of parent class EventStartCondition")
    }
    
}

//These event's start times are those related to another event (either start or end)

enum EventStartEventRelatedPosition {
    case Start
    case End
}

class EventStartEventRelated : EventStartCondition {
    
    
    
    var position : EventStartEventRelatedPosition?
    var event : PSTemplateEvent?
    
    convenience init(ev : PSTemplateEvent) {
        self.init()
        event = ev
    }
    
    
}

class EventStartConditionUnscheduled : EventStartCondition {
    override init() {
        super.init()
        event_time = EventTime.Unknown(nil)
    }
    
    init(fakePositionTime : EventMSecs) {
        super.init()
        event_time = EventTime.Unknown(fakePositionTime)
    }
    
    override func menuName() -> String {
        return "Unscheduled"
    }
    
    override func getValue() -> String {
        return "NONE"
    }
    
    override func getMetaData() -> String {
        switch (event_time) {
        case let .Unknown(time):
            if let time = time {
                let intValue = Int(time)
                return "\(intValue)"
            } else {
                return ""
            }
        default:
            return ""
        }
    }
}

class EventStartConditionTrialStart : EventStartCondition {
    override func menuName() -> String {
        return "Trial Start"
    }
    override func getValue() -> String {
        var time_string : String = ""
        switch event_time {
        case let .FixedTime(time_ms):
            let int : Int = Int(time_ms)
            time_string = "\(int)"
        default:
            return "Error"
        }
        return "\"\(time_string) after start of START\""
    }
    
}

class EventStartConditionEventStart : EventStartEventRelated {
    
    override init() {
        super.init()
        position = EventStartEventRelatedPosition.Start
    }
    override func getStartMS(base_event : PSTemplateEvent) -> EventMSecs {
        var (start, end) = event!.getMSRecursively(base_event)
        return start + event_time.ToEventMSecs()
    }
    
    override func menuName() -> String {
        return "Event Start"
    }
    
    override func getValue() -> String {
        var time_string : String = ""
        switch event_time {
        case let .FixedTime(time_ms):
            var int : Int = Int(time_ms)
            time_string = "\(int)"
        default:
            return "Error"
        }
        return "\"\(time_string) after start of \(event!.entry.name)\""
    }
}



class EventStartConditionEventEnd : EventStartEventRelated {
    
    override init() {
        super.init()
        position = EventStartEventRelatedPosition.End
    }
    
    override func getStartMS(base_event : PSTemplateEvent) -> EventMSecs {
        var (start, duration) = event!.getMSRecursively(base_event)
        return start + duration + event_time.ToEventMSecs()
    }
    override func menuName() -> String {
        return "Event End"
    }
    
    override func getValue() -> String {
        var time_string : String = ""
        switch event_time {
        case let .FixedTime(time_ms):
            var int : Int = Int(time_ms)
            time_string = "\(int)"
        default:
            return "Error"
        }
        return "\"\(time_string) after end of \(event!.entry.name)\""
    }
}