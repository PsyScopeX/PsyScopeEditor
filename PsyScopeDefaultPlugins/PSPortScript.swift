//
//  PSPortScript.swift
//  PsyScopeEditor
//
//  Created by James on 07/04/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation



class PSPortScript : NSObject {
    
    var scriptData : PSScriptData
    var portNamesEntry : PSStringList
    var portEntries : [PSPort] = []
    var positionEntries : Set<PSPosition> = []
    var entireScreenPort : PSPort?
    
    init(scriptData : PSScriptData) {
        self.scriptData = scriptData
        

        if let portNames = scriptData.getBaseEntry("PortNames") {
            self.portNamesEntry = PSStringList(entry: portNames, scriptData: scriptData)
        } else {
            var newPortNamesEntry = PSStringList(entry: scriptData.getOrCreateBaseEntry("PortNames", type: "PortNames", user_friendly_name: "Port Names", section_name: "PortDefinitions",zOrder: 14), scriptData: scriptData)
            var entireScreen = scriptData.getOrCreateBaseEntry("Entire Screen", type: "Port", user_friendly_name: "Entire Screen", section_name: "PortDefinitions",zOrder: 14)
            entireScreen.currentValue = "Center 100% Center 100% 0"
            newPortNamesEntry.appendAsString("Entire Screen")
            self.portNamesEntry = newPortNamesEntry
        }
        
        super.init()
        
        //get existing ports / positions
        var non_existing_ports : [String] = []
        for port_name in portNamesEntry.stringListLiteralsOnly {
            if let port_entry = scriptData.getBaseEntry(port_name) {
                var port = PSPort(entry: port_entry, scriptData: scriptData, portScript: self)
                portEntries.append(port)
                if port.name == "Entire Screen" {
                    entireScreenPort = port
                }
                port.positions.map { self.positionEntries.insert($0) }
            } else {
                non_existing_ports.append(port_name)
            }
        }
        
        //springclean the portnames entry
        for port_name in non_existing_ports {
            portNamesEntry.remove(port_name)
        }
    }
    
    var portNames : [String] {
        get { return portNamesEntry.stringListLiteralsOnly }
    }
    
    func addPort(name : String) -> PSPort? {
        //first check if entry name is free
        if scriptData.getBaseEntry(name) == nil && portNamesEntry.appendAsString(name) {
            
            var new_entry = scriptData.getOrCreateBaseEntry(name, type: "Port",user_friendly_name: name, section_name: "PortDefinitions", zOrder: 7)
            var port_entry = PSPort(entry: new_entry, scriptData: scriptData, portScript: self)
            portEntries.append(port_entry)
            return port_entry
        }
        return nil
    }
    
    func addPosition(name : String, port : PSPort) -> PSPosition? {
        if let position = port.addPosition(name) {
            positionEntries.insert(position)
            return position
        } else {
            return nil
        }
    }
    
    func deletePosition(position : PSPosition) {
        positionEntries.remove(position)
        position.delete()
    }
    
    func deletePort(port : PSPort) {
        portNamesEntry.remove(port.name as String)
        if let index = portEntries.indexOf(port) {
            portEntries.removeAtIndex(index)
        }
        port.delete()
    }
}