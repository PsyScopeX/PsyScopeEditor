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
    var positionEntries : Set<PSPosition> = [] //stores all positions from all ports
    var entireScreenPort : PSPort?  //special port representing entire screen (non selectable)
    
    init(scriptData : PSScriptData) {
        self.scriptData = scriptData
        

        if let portNames = scriptData.getBaseEntry("PortNames") {
            self.portNamesEntry = PSStringList(entry: portNames, scriptData: scriptData)
        } else {
            let newPortNamesEntry = PSStringList(entry: scriptData.getOrCreateBaseEntry("PortNames", type: PSType.PortNames), scriptData: scriptData)
            let entireScreen = scriptData.getOrCreateBaseEntry("Entire Screen", type: PSType.Port)
            entireScreen.currentValue = "Center 100% Center 100% 0"
            newPortNamesEntry.appendAsString("Entire Screen")
            self.portNamesEntry = newPortNamesEntry
        }
        
        super.init()
        
        //get existing ports / positions
        var non_existing_ports : [String] = []
        for port_name in portNamesEntry.stringListLiteralsOnly {
            if let port_entry = scriptData.getBaseEntry(port_name) {
                
                //Create and add port
                let port = PSPort(entry: port_entry, scriptData: scriptData, portScript: self)
                portEntries.append(port)
                
                
                //Note entire screen port
                if port.name == "Entire Screen" {
                    entireScreenPort = port
                }
                
                //Add positions to main list
                _ = port.positions.map { self.positionEntries.insert($0) }
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
    
    func addPort(_ name : String) -> PSPort? {
        //first check if entry name is free
        if scriptData.getBaseEntry(name) == nil && portNamesEntry.appendAsString(name) {
            
            let new_entry = scriptData.getOrCreateBaseEntry(name, type: PSType.Port)
            let port_entry = PSPort(entry: new_entry, scriptData: scriptData, portScript: self)
            portEntries.append(port_entry)
            port_entry.updateEntryValue()
            return port_entry
        }
        return nil
    }
    
    func addPosition(_ name : String, port : PSPort) -> PSPosition? {
        if let position = port.addPosition(name) {
            positionEntries.insert(position)
            return position
        } else {
            return nil
        }
    }
    
    func deletePosition(_ position : PSPosition) {
        positionEntries.remove(position)
        position.delete()
    }
    
    func deletePort(_ port : PSPort) {
        portNamesEntry.remove(port.name as String)
        if let index = portEntries.index(of: port) {
            portEntries.remove(at: index)
        }
        port.delete()
    }
}
