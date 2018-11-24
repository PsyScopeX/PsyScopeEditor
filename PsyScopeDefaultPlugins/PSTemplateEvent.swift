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
    var repeats : Int
    
    init(entry : Entry, scriptData : PSScriptData, repeats : Int) {
        self.entry = entry
        self.scriptData = scriptData
        self.repeats = repeats
        _startCondition = EventStartConditionTrialStart()
        _durationCondition = EventDurationConditionFixedTime(time: 500)
        super.init()
    }
    
    func getMainStimulusAttributeValue() -> String {
        if let tool = scriptData.pluginProvider.getInterfaceForType(PSType.FromName(entry.type)),
            let eventTool = tool as? PSEventInterface {
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
    func initStartCondition(_ startCondition : EventStartCondition) {
        _startCondition = startCondition
    }
    
    func initDurationCondition(_ durationCondition : EventDurationCondition) {
        _durationCondition = durationCondition
    }
    
    var startCondition : EventStartCondition {
        get {
            return _startCondition
        }
        
        set {
            _startCondition = newValue
            if newValue is EventStartConditionDefault {
                scriptData.deleteNamedSubEntryFromParentEntry(entry, name: "StartRef")
            } else {
                let start_ref_entry = scriptData.getOrCreateSubEntry("StartRef", entry: entry, isProperty: true)
                start_ref_entry.currentValue = _startCondition.getValue()
                start_ref_entry.metaData = _startCondition.getMetaData()
            }
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
        return (CGFloat(20),durationCondition.getDurationMS() * EventMSecs(repeats))
    }
    var loopLockedItem : Bool = false
    
    func getMSRecursively(_ base_event : PSTemplateEvent?) -> (start: EventMSecs, duration : EventMSecs) {
        var base_event = base_event
        if base_event != self {
            if loopLockedItem {
                return loopLockedTimes()
            }
            
            if base_event == nil { base_event = self }
            let start_time = startCondition.getStartMS(base_event!)
            let end_time = durationCondition.getDurationMS() * EventMSecs(repeats)
            return (start_time, end_time)
        } else {
            //we detected a loop - so set this class as the base object of the loop, and whenever get pixelsrecursievly is alled again on it (i.e. by the getpixels of other object, the searching will stop there
            loopLockedItem = true
            //the following times will eventually be discarded...
            return loopLockedTimes()
        }
    }
    
    
    //Pasteboard stuff
    
    func writableTypes(for pasteboard: NSPasteboard) -> [NSPasteboard.PasteboardType] {
        return [NSPasteboard.PasteboardType(rawValue: "psyscope.pstemplateevent")]
    }
    
    func pasteboardPropertyList(forType type: NSPasteboard.PasteboardType) -> Any? {
// Local variable inserted by Swift 4.2 migrator.
let type = convertFromNSPasteboardPasteboardType(type)

        //must return nsdata object
        let data = scriptData.archiveBaseEntry(entry)
        return data
    }
    
    //unarchive data must be called directly after this init, to associate with script
    required init!(pasteboardPropertyList propertyList: Any,
        ofType type: NSPasteboard.PasteboardType) {
// Local variable inserted by Swift 4.2 migrator.
let type = convertFromNSPasteboardPasteboardType(type)

        _startCondition = EventStartConditionTrialStart()
        _durationCondition = EventDurationConditionFixedTime(time: 500)
        data = propertyList as! Data
        self.repeats = 1
        super.init()
    }
    
    var data : Data!
    
    func unarchiveData(_ scriptData : PSScriptData) {
        self.scriptData = scriptData
        self.entry = scriptData.unarchiveBaseEntry(data)
    }
    
    class func readableTypes(for pasteboard: NSPasteboard) -> [NSPasteboard.PasteboardType] {
        return [NSPasteboard.PasteboardType(rawValue: "psyscope.pstemplateevent")]
    }
    
    func delete() {
        scriptData.beginUndoGrouping("Delete Event")
        scriptData.selectionInterface.deleteObject(entry.layoutObject)
        scriptData.endUndoGrouping(true)
    }
    
}



//dictionary [menuName string: (EventStartCondition object, bool (if takes other event))

var EventStartConditions : [String:(() -> EventStartCondition,Bool)] = [
    EventStartConditionDefault().menuName() : ({() -> EventStartCondition in return EventStartConditionDefault()}, false),
    EventStartConditionUnscheduled().menuName() : ({() -> EventStartCondition in return EventStartConditionUnscheduled()}, false),
    EventStartConditionTrialStart().menuName() : ({() -> EventStartCondition in return EventStartConditionTrialStart()}, false),
    EventStartConditionEventStart().menuName() : ({() -> EventStartCondition in return EventStartConditionEventStart()}, true),
    EventStartConditionEventEnd().menuName()   : ({() -> EventStartCondition in return EventStartConditionEventEnd()}, true)]

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSPasteboardPasteboardType(_ input: NSPasteboard.PasteboardType) -> String {
	return input.rawValue
}
