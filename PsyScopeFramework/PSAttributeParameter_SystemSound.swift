//
//  PSAttributeParameter_SystemSound.swift
//  PsyScopeEditor
//
//  Created by James on 04/02/2015.
//

import Foundation

public class PSAttributeParameter_SystemSound : PSAttributeParameter {
    var popUpButton : NSPopUpButton!
    
    override public func setCustomControl(visible: Bool) {

        if visible {
            if popUpButton == nil {
                //add popupbutton
                popUpButton = NSPopUpButton(frame: attributeValueControlFrame, pullsDown: false)
                popUpButton.autoresizingMask = NSAutoresizingMaskOptions.ViewWidthSizable
                popUpButton.target = self
                popUpButton.action = "soundSelected:"
                cell.addSubview(popUpButton)
            } else {
                popUpButton.hidden = false
            }
            updatePopUpMenuContent()
            popUpButton.selectItemWithTitle(currentValue)
        } else {
            if popUpButton != nil {
                popUpButton.hidden = true
            }
        }
    }
    
    
    func soundSelected(item : NSMenuItem) {
        currentValue = item.title
        self.cell.updateScript()
    }
    
    func noneSelected(item : NSMenuItem) {
        currentValue = ""
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
        let librarySources = NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .AllDomainsMask, true)
        
        var sounds : [String] = []
        
        for sourcePath in librarySources {
            let soundSource = NSFileManager.defaultManager().enumeratorAtPath((sourcePath as NSString).stringByAppendingPathComponent("Sounds"))
            if let ss = soundSource {
                while let soundFile = ss.nextObject() as? String {
                    if NSSound(named: (soundFile as NSString).stringByDeletingPathExtension) != nil {
                        sounds.append((soundFile as NSString).stringByDeletingPathExtension)
                    }
                }
            }
        }
        _PSSystemSoundStringList = sounds
        return sounds
    }
}