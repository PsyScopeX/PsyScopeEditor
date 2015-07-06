//
//  PSAttributeEvent.swift
//  PsyScopeEditor
//
//  Created by James on 18/11/2014.
//

import Foundation

class PSAttributeEvent: PSAttributeGeneric {
    
    
    override init() {
        super.init()
        userFriendlyNameString = "Event"
        helpfulDescriptionString = "Allows you to pick an existing event from all possible events"
        codeNameString = "Event"
        attributeClass = PSAttributeParameter_Event.self
    }
}


//allows user to pick an event of currently existing ones - current value is the name of an event
class PSEventPicker : PSAttributePopup {
    
    @IBOutlet var eventsPopup : NSPopUpButton!
    
    var events : [Entry] = []
    var scriptData : PSScriptData
    
    init(currentValue: String, scriptData: PSScriptData, setCurrentValueBlock : ((String)->())?){
        self.scriptData = scriptData
        super.init(nibName: "EventPicker",bundle: NSBundle(forClass:self.dynamicType), currentValue: currentValue, displayName: "Event", setCurrentValueBlock: setCurrentValueBlock)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        updatePopUpMenuContent()
        eventsPopup.selectItemWithTitle(self.currentValue)
    }
    
    func eventSelected(item : NSMenuItem) {
        self.currentValue = item.title
    }
    func updatePopUpMenuContent() {
        
        //start condition events - needs to be updated everytime new event is added, whence in its own routine
        events = scriptData.getAllEvents()
        var new_menu = NSMenu()
        for event in events {
            var new_item = NSMenuItem(title: event.name, action: "eventSelected:", keyEquivalent: "")
            new_item.target = self
            new_item.action = "eventSelected:"
            new_menu.addItem(new_item)
        }
        eventsPopup.menu = new_menu
    }
}