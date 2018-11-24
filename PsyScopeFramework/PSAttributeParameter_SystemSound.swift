//
//  PSAttributeParameter_SystemSound.swift
//  PsyScopeEditor
//
//  Created by James on 04/02/2015.
//

import Foundation

open class PSAttributeParameter_SystemSound : PSAttributeParameter {
    var popUpButton : NSPopUpButton!
    
    override open func setCustomControl(_ visible: Bool) {

        if visible {
            if popUpButton == nil {
                //add popupbutton
                popUpButton = NSPopUpButton(frame: attributeValueControlFrame, pullsDown: false)
                popUpButton.autoresizingMask = NSAutoresizingMaskOptions.viewWidthSizable
                popUpButton.target = self
                popUpButton.action = "soundSelected:"
                cell.addSubview(popUpButton)
            } else {
                popUpButton.isHidden = false
            }
            updatePopUpMenuContent()
            popUpButton.selectItem(withTitle: currentValue.stringValue())
        } else {
            if popUpButton != nil {
                popUpButton.isHidden = true
            }
        }
    }
    
    
    func soundSelected(_ item : NSMenuItem) {
        currentValue = PSGetFirstEntryElementForStringOrNull(item.title)
        self.cell.updateScript()
    }
    
    func noneSelected(_ item : NSMenuItem) {
        currentValue = .null
        self.cell.updateScript()
    }
    
    func updatePopUpMenuContent() {
        
        let new_menu = NSMenu()
        let new_item = NSMenuItem(title: "Default Sound", action: "noneSelected:", keyEquivalent: "")
        new_item.target = self
        new_item.action = "noneSelected:"
        new_menu.addItem(new_item)
        for sound in PSSystemSoundStringList {
            let new_item = NSMenuItem(title: sound, action: "soundSelected:", keyEquivalent: "")
            new_item.target = self
            new_item.action = "soundSelected:"
            new_menu.addItem(new_item)
        }
        
        
        
        popUpButton.menu = new_menu
    }
}

var _PSSystemSoundStringList : [String]? = nil
var PSSystemSoundStringList : [String] {
    
    get {
        if let s = _PSSystemSoundStringList {
            return s
        }
        //get system sounds
        let librarySources = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .allDomainsMask, true)
        
        var sounds : [String] = []
        
        for sourcePath in librarySources {
            let soundSource = FileManager.default.enumerator(atPath: (sourcePath as NSString).appendingPathComponent("Sounds"))
            if let ss = soundSource {
                while let soundFile = ss.nextObject() as? String {
                    if NSSound(named: (soundFile as NSString).deletingPathExtension) != nil {
                        sounds.append((soundFile as NSString).deletingPathExtension)
                    }
                }
            }
        }
        _PSSystemSoundStringList = sounds
        return sounds
    }
}
