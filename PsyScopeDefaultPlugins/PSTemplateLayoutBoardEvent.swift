//
//  PSTemplateLayoutBoardEvent.swift
//  PsyScopeEditor
//
//  Created by James on 08/09/2014.
//

import Foundation

typealias EventMSecs = CGFloat
typealias UnknownTime = EventMSecs?

//represents and parses an event entry
class PSTemplateEvent : NSObject, NSPasteboardWriting, NSPasteboardReading {
    var entry : Entry!
    var scriptData : PSScriptData!
    
    init(entry : Entry, scriptData : PSScriptData) {
        self.entry = entry
        self.scriptData = scriptData
        _startCondition = EventStartConditionTrialStart()
        _durationCondition = EventDurationConditionFixedTime(time: 500)
        super.init()
    }
    
    func getMainStimulusAttributeValue() -> String {
        if let tool : AnyObject = scriptData.pluginProvider.getInterfaceForType(PSType.FromName(entry.type)),
            eventTool = tool as? PSEventInterface {
                let name = eventTool.mainStimulusAttributeName
                if name != "" {
                    if let attribute = scriptData.getSubEntry(name, entry: entry) {
                        return attribute.currentValue
                    }
                }
        }
        return ""
    }
    
    
    //these methods allow the setting of the condition without triggering script changes
    func initStartCondition(startCondition : EventStartCondition) {
        _startCondition = startCondition
    }
    
    func initDurationCondition(durationCondition : EventDurationCondition) {
        _durationCondition = durationCondition
    }
    
    var startCondition : EventStartCondition {
        get {
            return _startCondition
        }
        
        set {
            _startCondition = newValue
            let start_ref_entry = scriptData.getOrCreateSubEntry("StartRef", entry: entry, isProperty: true)
            start_ref_entry.currentValue = _startCondition.getValue()
            start_ref_entry.metaData = _startCondition.getMetaData()
        }
    }
    
    var durationCondition : EventDurationCondition {
        get {
            return _durationCondition
        }
        set {
            _durationCondition = newValue
            let duration_entry = scriptData.getOrCreateSubEntry("Duration", entry: entry, isProperty: true)
            
            duration_entry.currentValue = _durationCondition.getValue()
        }
    }
    
    var _startCondition : EventStartCondition
    var _durationCondition : EventDurationCondition
    
    func getMS() -> (start: EventMSecs, duration : EventMSecs) {
        loopLockedItem = false
        var pixels_start_estimate : EventMSecs
        var pixels_duration_estimate : EventMSecs
        (pixels_start_estimate, pixels_duration_estimate) = getMSRecursively(nil)
        if loopLockedItem == true {
            //this item will be locked to beginning of display
            return loopLockedTimes()
        } else {
            
            return (pixels_start_estimate, pixels_duration_estimate)
        }
    }
    
    func loopLockedTimes() -> (start: EventMSecs, duration : EventMSecs) {
        return (CGFloat(20),durationCondition.getDurationMS())
    }
    var loopLockedItem : Bool = false
    
    func getMSRecursively(var base_event : PSTemplateEvent?) -> (start: EventMSecs, duration : EventMSecs) {
        if base_event != self {
            if loopLockedItem {
                return loopLockedTimes()
            }
            
            if base_event == nil { base_event = self }
            let start_time = startCondition.getStartMS(base_event!)
            let end_time = durationCondition.getDurationMS()
            return (start_time, end_time)
        } else {
            //we detected a loop - so set this class as the base object of the loop, and whenever get pixelsrecursievly is alled again on it (i.e. by the getpixels of other object, the searching will stop there
            loopLockedItem = true
            //the following times will eventually be discarded...
            return loopLockedTimes()
        }
    }
    
    
    //Pasteboard stuff
    
    func writableTypesForPasteboard(pasteboard: NSPasteboard) -> [String] {
        return ["psyscope.pstemplateevent"]
    }
    
    func pasteboardPropertyListForType(type: String) -> AnyObject? {
        //must return nsdata object
        let data = scriptData.archiveBaseEntry(entry)
        return data
    }
    
    //unarchive data must be called directly after this init, to associate with script
    required init!(pasteboardPropertyList propertyList: AnyObject,
        ofType type: String) {
        _startCondition = EventStartConditionTrialStart()
        _durationCondition = EventDurationConditionFixedTime(time: 500)
        data = propertyList as! NSData
        super.init()
    }
    
    var data : NSData!
    
    func unarchiveData(scriptData : PSScriptData) {
        self.scriptData = scriptData
        self.entry = scriptData.unarchiveBaseEntry(data)
    }
    
    class func readableTypesForPasteboard(pasteboard: NSPasteboard) -> [String] {
        return ["psyscope.pstemplateevent"]
    }
    
    func delete() {
        scriptData.beginUndoGrouping("Delete Event")
        scriptData.selectionInterface.deleteObject(entry.layoutObject)
        scriptData.endUndoGrouping(true)
    }
    
}



//dictionary [menuName string: (EventStartCondition object, bool (if takes other event))

var EventStartConditions : [String:(() -> EventStartCondition,Bool)] = [
    EventStartConditionUnscheduled().menuName() : ({() -> EventStartCondition in return EventStartConditionUnscheduled()}, false),
    EventStartConditionTrialStart().menuName() : ({() -> EventStartCondition in return EventStartConditionTrialStart()}, false),
    EventStartConditionEventStart().menuName() : ({() -> EventStartCondition in return EventStartConditionEventStart()}, true),
    EventStartConditionEventEnd().menuName()   : ({() -> EventStartCondition in return EventStartConditionEventEnd()}, true)]