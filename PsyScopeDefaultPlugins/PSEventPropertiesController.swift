//
//  PSEventPropertiesController.swift
//  PsyScopeEditor
//
//  Created by James on 06/11/2014.
//

import Foundation




class PSEventPropertiesController : PSToolPropertyController {

    @IBOutlet var popOverStartCondition : NSPopUpButton!
    @IBOutlet var textFieldStartTime : NSTextField!
    @IBOutlet var labelStartEvent : NSTextField!
    
    
    @IBOutlet var durationMatrix : NSMatrix!
    @IBOutlet var durationTimeTextField : NSTextField!
    @IBOutlet var durationConditionsController : PSConditionTableViewController!
   
    
    var popOverStartConditionEvents : [Int : (() -> EventStartCondition, Entry?)] = [:]
    
    var popOverStartConditionEventSubMenus : [NSMenuItem] = []
    var event : PSTemplateEvent!
    
    var templateEntries : [Entry]!
    var firstParse : Bool = false
    var durationEntry : Entry!
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(entry : Entry, scriptData : PSScriptData) {
        let bundle = Bundle(for:type(of: self))
        super.init(nibName: "EventProperties", bundle: bundle, entry: entry, scriptData: scriptData)
        self.entry = entry
        
        //Double clicking brings up actions builder
        storedDoubleClickAction = { () in
            NotificationCenter.default.post(name: Notification.Name(rawValue: "PSShowWindowNotificationForActionsBuilder"), object: self.scriptData.document) }
        durationEntry = scriptData.getOrCreateSubEntry("Duration", entry: entry, isProperty: true)
    }
    
    

    override func awakeFromNib() {
        super.awakeFromNib()

        if !firstParse {
            parseEvent()
        }
    }
    
    
    override func refresh() {
        super.refresh()
        parseEvent()
    }

    func parseEvent() {
 
        //Next read the event strings (e.g. startref and duration)
        templateEntries = scriptData.getParentEntries(entry)
        
        var relatedEvents : [PSTemplateEvent] = []
        for templateEntry in templateEntries {
            for child in templateEntry.layoutObject.childLink.array as! [LayoutObject] {
                if scriptData.typeIsEvent(child.mainEntry.type) && entry.name != child.mainEntry.name {
                    relatedEvents.append(PSTemplateEvent(entry: child.mainEntry,scriptData: scriptData, repeats: 1))
                }
            }
        }
        event = PSTemplateEvent(entry: entry, scriptData: scriptData, repeats: 1)
        PSEventStringParser.parseForTemplateLayoutBoardEvent(event, events: relatedEvents)
        
        //Collate and populate the start condition menu (relies on all events)
        popOverStartConditionEvents = [:]
        var current_tag = 1
        let new_menu = NSMenu()
        for (name , (eventClass, usesEvent)) in EventStartConditions {
            let new_item = NSMenuItem(title: name, action: #selector(PSEventPropertiesController.popOverStartConditionMenuItemSelected(_:)), keyEquivalent: "")
            
            if usesEvent {
                if relatedEvents.count > 0 {
                    new_item.target = self
                    new_item.tag = 0
                    let new_submenu = NSMenu()
                    
                    //get events in template
                    
                    for event in relatedEvents {
                        let new_sm_item = NSMenuItem(title: event.entry.name, action: #selector(PSEventPropertiesController.popOverStartConditionMenuItemSelected(_:)), keyEquivalent: "")
                        new_sm_item.target = self
                        new_sm_item.isEnabled = true
                        new_sm_item.tag = current_tag
                        popOverStartConditionEvents[current_tag] = (eventClass, event.entry)
                        current_tag += 1
                        new_submenu.addItem(new_sm_item)
                    }
                    
                    new_item.submenu = new_submenu
                    new_item.isEnabled = true
                } else {
                    new_item.isEnabled = false
                }
            } else {
                new_item.target = self
                new_item.action = #selector(PSEventPropertiesController.popOverStartConditionMenuItemSelected(_:))
                new_item.target = self
                new_item.tag = current_tag
                popOverStartConditionEvents[current_tag] = (eventClass, nil)
                current_tag += 1
            }
            new_menu.addItem(new_item)
        }
        popOverStartCondition.menu = new_menu
        
        
        //reset all controls to default state
        labelStartEvent.stringValue = ""
        textFieldStartTime.isEnabled = false
        textFieldStartTime.stringValue = ""
        popOverStartCondition.isEnabled = true
        popOverStartCondition.selectItem(withTitle: event.startCondition.menuName())
        
        //does the event have a time associated with it?
        if let startTimeString = event.startCondition.textFieldStartTime {
            textFieldStartTime.isEnabled = true
            textFieldStartTime.stringValue = startTimeString
            
            //does the event have an event associated with it
            if let er = event.startCondition as? EventStartEventRelated, er.event != nil {
                //there is an event
                labelStartEvent.stringValue = "Event: \(er.event!.entry.name)"
            }
        }
        
        
        //parse the duration
        durationTimeTextField.stringValue = ""
        durationTimeTextField.isEnabled = false
        durationConditionsController.disable()
        if let fixed_time = event.durationCondition as? EventDurationConditionFixedTime {
            durationTimeTextField.isEnabled = true
            let int : Int = Int(fixed_time.getDurationMS())
            durationTimeTextField.stringValue = "\(int)"
            durationMatrix.selectCell(withTag: 2)
        } else if let _ = event.durationCondition as? EventDurationConditionSelfTerminate {
            durationMatrix.selectCell(withTag: 1)
        } else if let _ = event.durationCondition as? EventDurationConditionTrialEnd {
            durationMatrix.selectCell(withTag: 0)
        } else if let _ = event.durationCondition as? EventDurationConditionOther {
            durationMatrix.selectCell(withTag: 3)
            durationConditionsController.enable(durationEntry, scriptData: scriptData)
        }

        
        
        
    }
    
    @IBAction func updateDurationCondition(_ sender : AnyObject) {
        scriptData.beginUndoGrouping("Update Event Duration")
        switch (durationMatrix.selectedRow) {
        case 0:
            event.durationCondition = EventDurationConditionTrialEnd()
            durationConditionsController.disable()
            durationTimeTextField.isEnabled = false
        case 1:
            event.durationCondition = EventDurationConditionSelfTerminate()
            durationConditionsController.disable()
            durationTimeTextField.isEnabled = false
        case 2:
            durationTimeTextField.isEnabled = true
            event.durationCondition = EventDurationConditionFixedTime(time: 500)
            
            if durationTimeTextField.stringValue == "" {
                let int : Int = Int(event.durationCondition.getDurationMS())
                durationTimeTextField.stringValue = "\(int)"
            } else {
                durationTimeTextFieldEdited()
            }
            
            durationConditionsController.disable()
        case 3:
            durationTimeTextField.isEnabled = false
            let durationsEntry = scriptData.getOrCreateSubEntry("Duration", entry: event.entry, isProperty: true)
            event.durationCondition = EventDurationConditionOther(conditionsEntry: durationsEntry, scriptData: scriptData)
            (event.durationCondition as! EventDurationConditionOther).setToNever()
            durationConditionsController.enable(durationsEntry, scriptData: scriptData)
        default:
            break
        }
        scriptData.endUndoGrouping(true)
    }
    
    //change event startCondition when menu item is selected
    @objc func popOverStartConditionMenuItemSelected(_ item : NSMenuItem) {
        if let (startCondition, lobject) = popOverStartConditionEvents[item.tag] {
            let new_start_condition = startCondition()
            if let (lobj) = lobject {
                //menu item included an event object
                let nsc = new_start_condition as! EventStartEventRelated //TODO Refactoring here maybe
                nsc.event = PSTemplateEvent(entry: lobj, scriptData: scriptData, repeats: 1)
                labelStartEvent.stringValue = lobj.name
            }
            let double_val = NSString(string: textFieldStartTime.stringValue).doubleValue
            new_start_condition.event_time = EventTime.fixedTime(CGFloat(double_val))
            event.startCondition = new_start_condition //entry automatically updated
            popOverStartCondition.selectItem(withTitle: event.startCondition.menuName())
        }
    }
    
    func durationTimeTextFieldEdited() {
        if let t = Int(durationTimeTextField.stringValue) {
            event.durationCondition = EventDurationConditionFixedTime(time: t)
        } else {
            //incorrect format for int so reset to 0
            durationTimeTextField.stringValue = "0"
            event.durationCondition = EventDurationConditionFixedTime(time: 0)
        }
    }
    
    override func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        if control == textFieldStartTime {
            let selected_start = event.startCondition
            let double_val = NSString(string: textFieldStartTime.stringValue).doubleValue
            selected_start.event_time = EventTime.fixedTime(CGFloat(double_val))
            event.startCondition = selected_start //entry automatically updated
            return true
        } else if control == durationTimeTextField {
            durationTimeTextFieldEdited()
            return true
        }
        
        return super.control(control, textShouldEndEditing: fieldEditor)
    }
}
