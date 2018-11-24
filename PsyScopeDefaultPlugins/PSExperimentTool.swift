//
//  PSExperimentTool.swift
//  PsyScopeEditor
//
//  Created by James on 15/07/2014.
//

import Cocoa

class PSExperimentTool: PSTool, PSToolInterface {
    
    override init() {
        super.init()
        toolType = PSType.Experiment
        helpfulDescriptionString = "Node for defining an experiment"
        iconName = "Experiment-Icon-128"
        iconColor = NSColor.green
        classNameString = "PSExperimentTool"
        section = PSSection.ExperimentDefinitions
        identityProperty = ExperimentsProperties.Experiments
        properties = [ExperimentProperties.Format, ExperimentProperties.InputDevices, ExperimentProperties.Timer, ExperimentProperties.Flags, ExperimentProperties.ScaleBlocks, ExperimentProperties.DataFile]
    }
    
    
    
    struct ExperimentProperties {
        static let Format = PSProperty(name: "Format", defaultValue: "Factor", essential: true)
        static let InputDevices = PSProperty(name: "InputDevices", defaultValue: PSDefaultConstants.DefaultAttributeValues.PSExperimentInputDevices, essential: true)
        static let Timer = PSProperty(name: "Timer", defaultValue: "Macintosh", essential: true)
        static let Flags = PSProperty(name: "Flags", defaultValue: "NO_SAVE_SCREEN", essential: true)
        static let ScaleBlocks = PSProperty(name:"ScaleBlocks", defaultValue: "1", essential: true)
        static let DataFile = PSProperty(name: "DataFile", defaultValue: "\"Experiment Data\"", essential: true)
    }
    
    struct ExperimentsProperties {
        static let Experiments = PSProperty(name: "Experiments",defaultValue: "")
        static let Current = PSProperty(name: "Current", defaultValue: "1", essential: true)
    }
    
    //also perform some overall checks in here
    override func identifyEntries(_ ghostScript: PSGhostScript) -> [PSScriptError] {
        var errors : [PSScriptError] = []
        var foundExperimentsEntry = false
        var foundMainEntry = false
        for ge in ghostScript.entries as [PSGhostEntry]{
            if ge.name == "Experiments" {
                foundExperimentsEntry = true
                ge.type = type() //found experiments entry, update type
                
                //now search for the entry corresponding to the value
                let mainEntryName = ge.currentValue.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
                for ge2 in ghostScript.entries as [PSGhostEntry] {
                    if ge2.name == mainEntryName {
                        foundMainEntry = true
                        if (ge2.type.isEmpty) {
                            ge2.type = type()
                        } else {
                            print("Error here: \(ge2.type) key type already defined")
                            if (ge2.type == type()) {
                                errors.append(PSErrorAlreadyDefinedType(ge2.name, type1: ge2.type))
                            } else {
                                errors.append(PSErrorAmbiguousType(ge2.name, type1: ge2.type, type2: type()))
                            }
                        }
                        break
                    }
                }
                
                //finishedd searching through allentries for main experiment entry - has it been found?
                if (!foundMainEntry) {
                    if ge.currentValue != "" {
                        errors.append(PSErrorEntryNotFound(ge.currentValue, parentEntry: ge.name, subEntry: ""))
                    } else {
                        errors.append(PSErrorNoExperimentsEntry())
                    }
                    
                }
            }
            
            
            
            //check this entry for more than one structural attribute
            var foundAttributes : Int = 0
            for property in PSDefaultConstants.StructuralProperties.MutuallyExclusiveSet {
                for subEntry in ge.subEntries {
                    if subEntry.name == property.name {
                        foundAttributes += 1
                    }
                }
            }
            
            if foundAttributes > 1 {
                errors.append(PSTooManyStructuralAttributesType(ge.name))
            }
            
            
            
        }

        if (!foundExperimentsEntry) {
            errors.append(PSErrorNoExperimentsEntry())
        }
        
        return errors
    }
    
    
    override func validateBeforeRun(_ scriptData: PSScriptData) -> [PSScriptError] {
        //check for data file parameter
        var errors : [PSScriptError] = []
        let entries = scriptData.getBaseEntriesOfType(toolType)
        for entry in entries {
            if entry.name != "Experiments" {
                if let datafile = scriptData.getSubEntry("DataFile", entry: entry) {
                    //ok we have data file
                    if datafile.currentValue == "" {
                        errors.append(PSErrorDataFileEntry())
                    }
                } else {
                    errors.append(PSErrorDataFileEntry())
                }
            }
        }
        return errors
    }
    

    
    override func createObjectWithGhostEntries(_ entries: [PSGhostEntry], withScript scriptData: PSScriptData) -> [LayoutObject]? {
        
        //sometimes the Experiments entry will be the only new object and sometimes just the Experiment entry.
        
        var ghost_main_entry : PSGhostEntry! = nil
        var ghost_experiments_entry : PSGhostEntry! = nil
        //check there is an experiments entry (should be) and only one other
        for entry in entries {
            if entry.name == "Experiments"{
                if (ghost_experiments_entry != nil) {
                    print("Error too many Experiment entries detected???")
                    return nil
                } else {
                    ghost_experiments_entry = entry
                }
            } else {
                if (ghost_main_entry != nil) {
                    print("Error too many experiment name entries detected???")
                    return nil
                } else {
                    ghost_main_entry = entry
                }
            }
        }
        
        var experimentsEntry : Entry! = nil
        var mainEntry : Entry! = nil
        
        if ghost_main_entry != nil {
            // a new main experiment entry has been created
            let new_name = ghost_main_entry.name
            let layout_object = scriptData.createBaseEntryAndLayoutObjectPair(PSSection.ExperimentDefinitions, entryName: new_name, type: toolType)
            mainEntry = layout_object.mainEntry
            updateEntry(mainEntry, withGhostEntry: ghost_main_entry, scriptData: scriptData)
        } else {
            // need to use old one, find in script - there shoudl definitely be one after identify entries
            for entry in scriptData.getBaseEntries() {
                let mainEntryName = ghost_experiments_entry.currentValue.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
                if entry.name == mainEntryName {
                    mainEntry = entry
                    break
                }
            }
            
            if mainEntry == nil {
                fatalError("Could not find main experiment entry, which was supposed to exist.")
            }
        }
        
        var newName = mainEntry.name
        
        if ghost_experiments_entry == nil {
            //no experiments entry has been provided in ghost script - check to see if it already exists
            for entry in scriptData.getBaseEntries() {
                if entry.name == "Experiments" {
                    experimentsEntry = entry
                    mainEntry.layoutObject.addEntriesObject(experimentsEntry)
                    break
                }
            }
        }
        
        if experimentsEntry == nil {
            // a new experiments entry needs to be created
            //get sections
            let root_section = scriptData.getOrCreateSection(PSSection.Root)
            //create main experiments entry
            experimentsEntry = scriptData.insertNewBaseEntry("Experiments", type: toolType)
            
            //if newName has spaces then add quotes
            if (newName?.components(separatedBy: CharacterSet.whitespacesAndNewlines).count)! > 1 {
                newName = "\"\(newName)\""
            }
            experimentsEntry.currentValue = newName
            experimentsEntry.isKeyEntry = false
            
            root_section.addObjectsObject(experimentsEntry)
            
            mainEntry.layoutObject.addEntriesObject(experimentsEntry)
        }
        
        //if there was a ghost entry provided, then update
        if ghost_experiments_entry != nil {
            updateEntry(experimentsEntry, withGhostEntry: ghost_experiments_entry, scriptData: scriptData)
        }
        return [mainEntry.layoutObject]
    }
    
    override func createLinkFrom(_ parent: Entry, to child: Entry, withScript scriptData: PSScriptData) -> Bool {
        
        if PSTool.createLinkFromToolToList(parent, to: child, withScript: scriptData) {
            return true
        }
        
        //Experiment has to be parent
        if parent.type == "Experiment" {
            //get the type of child which the parent already has (if any)
            let childrenOfParent : [Entry] = scriptData.getChildEntries(parent)
            var currentChildType : String = ""
            for childOfParent in childrenOfParent {
                if childOfParent.type != "List" {
                    currentChildType = childOfParent.type
                    break
                }
            }
            
            if scriptData.typeIsEvent(currentChildType) {
                currentChildType = "Event"
            }
            
            if currentChildType != "" {
                //found a child type - need to check if it's the same
                switch (currentChildType) {
                    case "Group":
                        if child.type == "Group" {
                            //can link
                            scriptData.createLinkFrom(parent, to: child, withAttribute: "Groups")
                        } else {
                            //cannot link
                            return false
                        }
                    case "Block":
                        if child.type == "Group" {
                            scriptData.moveParentLinks(parent, newParent: child, withAttribute: "Blocks")
                            scriptData.createLinkFrom(parent, to: child, withAttribute: "Groups")
                            return true
                        } else if child.type == "Block" {
                            scriptData.createLinkFrom(parent, to: child, withAttribute: "Blocks")
                            return true
                        } else {
                            return false
                        }
                    case "Template":
                        if child.type == "Group" {
                            scriptData.moveParentLinks(parent, newParent: child, withAttribute: "Templates")
                            scriptData.createLinkFrom(parent, to: child, withAttribute: "Groups")
                            return true
                        } else if child.type == "Block" {
                            scriptData.moveParentLinks(parent, newParent: child, withAttribute: "Templates")
                            scriptData.createLinkFrom(parent, to: child, withAttribute: "Blocks")
                            return true
                        } else if child.type == "Template" {
                            scriptData.createLinkFrom(parent, to: child, withAttribute: "Templates")
                            return true
                        } else {
                            return false
                        }
                    case "Event":
                        if child.type == "Group" {
                            scriptData.moveParentLinks(parent, newParent: child, withAttribute: "Events")
                            scriptData.createLinkFrom(parent, to: child, withAttribute: "Groups")
                            return true
                        } else if child.type == "Block" {
                            scriptData.moveParentLinks(parent, newParent: child, withAttribute: "Events")
                            scriptData.createLinkFrom(parent, to: child, withAttribute: "Blocks")
                            return true
                        } else if child.type == "Template" {
                            scriptData.moveParentLinks(parent, newParent: child, withAttribute: "Events")
                            scriptData.createLinkFrom(parent, to: child, withAttribute: "Templates")
                            return true
                        } else if scriptData.typeIsEvent(child.type) {
                            scriptData.createLinkFrom(parent, to: child, withAttribute: "Events")
                            return true
                        } else {
                            return false
                        }
                    default:
                        fatalError("Unknown child type: '\(currentChildType)' for Experiment entry")
                }
            } else {
                if child.type == "Group" {
                    scriptData.createLinkFrom(parent, to: child, withAttribute: "Groups")
                    return true
                } else if child.type == "Block" {
                    scriptData.createLinkFrom(parent, to: child, withAttribute: "Blocks")
                    return true
                } else if child.type == "Template" {
                    scriptData.createLinkFrom(parent, to: child, withAttribute: "Templates")
                    return true
                } else if scriptData.typeIsEvent(child.type) {
                    scriptData.createLinkFrom(parent, to: child, withAttribute: "Events")
                    return true
                } else {
                    return false
                }
            }
            
        } else {
            return false
        }
        return false
    }
    
    override func deleteLinkFrom(_ parent: Entry, to child: Entry, withScript scriptData: PSScriptData) -> Bool {
        var childAttributeName : String = ""
        
        if scriptData.typeIsEvent(child.type) {
            childAttributeName = "Events"
        } else if child.type != "" {
            childAttributeName = child.type + "s"
        }
        
        
        if childAttributeName != "" {
            scriptData.removeLinkFrom(parent, to: child, withAttribute: childAttributeName)
            return true
        } else {
            return false
        }
    }
   
    //returns nil if cannot create object e.g. is unique
    override func createObject(_ scriptData: PSScriptData) -> Entry? {
        //check if key entry names are already in script
        let free = scriptData.baseEntriesAreFree(["Experiments"])
        
        if (!free.isFree) {
            //TODO handle error with free
            return nil
        }
        
        //get sections
        let root_section = scriptData.getOrCreateSection(PSSection.Root)
        
        let layout_object = scriptData.createBaseEntryAndLayoutObjectPair(section, entryName: "Experiment", type: toolType)
        let experiment_main_entry = layout_object.mainEntry
        //create main experiments entry
        let experiments_entry = scriptData.insertNewBaseEntry("Experiments",type: toolType)
        experiments_entry.name = "Experiments"
        experiments_entry.currentValue = experiment_main_entry?.name
        experiments_entry.isKeyEntry = false
        experiments_entry.type = type()
        root_section.addObjectsObject(experiments_entry)
        
        layout_object.addEntriesObject(experiments_entry)
        
        //now do properties
        for property in properties {
            scriptData.addDefaultProperty(property, entry: experiment_main_entry!)
        }
        
        scriptData.addDefaultProperty(ExperimentsProperties.Current, entry: experiments_entry)
        
    
        return experiment_main_entry
    }
    
    override func updateEntry(_ realEntry: Entry, withGhostEntry ghostEntry: PSGhostEntry, scriptData: PSScriptData) {
        
        
        if realEntry.name == "Experiments" {
            PSUpdateEntryWithGhostEntry(realEntry, ghostEntry: ghostEntry, scriptData: scriptData)
            scriptData.assertPropertyIsPresent(ExperimentsProperties.Current, entry: realEntry)
        } else {
            super.updateEntry(realEntry, withGhostEntry: ghostEntry, scriptData: scriptData)
        }


    }
    
    //cannot delete experiment tool
    override func deleteObject(_ lobject: Entry, withScript scriptData: PSScriptData) -> Bool {
        return false
    }
    
    //cannot add new experiment tools
    override func appearsInToolMenu() -> Bool { return false }
    
    override func getPropertiesViewController(_ entry: Entry, withScript scriptData: PSScriptData) -> PSPluginViewController? {
        
        return PSExperimentViewController(entry: entry, scriptData: scriptData)
    }

}


func PSErrorDataFileEntry() -> PSScriptError {
    let d = "The -DataFile- sub entry must be defined, and have a valid file name as its value"
    let s = "Add DataFile sub entry to the main experiment entry, and set it's value"
    return PSScriptError(errorDescription: "Missing DataFile Sub Entry", detailedDescription: d, solution: s)
    
}

func PSTooManyStructuralAttributesType(_ name : String) -> PSScriptError {
    let d = "Two or more mutually exclusive structural attributes in entry"
    let s = "Structural attributes (Experiments, Groups, Blocks, Templates, Events) are mutually exclusive - make sure each entry has only one type of these"
    return PSScriptError(errorDescription: "Too Many Structural Attributes Error",detailedDescription: d,solution: s, entryName: name)
}

func PSErrorNoExperimentsEntry() -> PSScriptError {
        let d = "The -Experiments- entry must be defined, and have as it's value the name of a single experiment entry"
        let s = "Add Experiments entry to script"
        return PSScriptError(errorDescription: "Missing Experiments Entry", detailedDescription: d, solution: s)
    
}
