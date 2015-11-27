//
//  PSScriptConverter.swift
//  PsyScopeEditor
//
//  Created by James on 12/08/2014.
//

import Foundation

//Converts ghost script to main script, generating layout objects etc for the layoutboard


class PSScriptConverter: NSObject {
    
    @IBOutlet var mainWindowController : PSMainWindowController!
    @IBOutlet var errorHandler : PSScriptErrorViewController!

    var plugins : [PSToolInterface] = []
    var attributePlugins : [PSAttributeInterface] = []
    var entryValueChecker : PSEntryValueChecker!
    
    override func awakeFromNib() {
        let tools : [PSToolInterface] = Array(PSPluginSingleton.sharedInstance.toolObjects.values)
        let events : [PSToolInterface] = Array(PSPluginSingleton.sharedInstance.eventObjects.values)
        plugins = tools + events
        attributePlugins = Array(PSPluginSingleton.sharedInstance.attributeObjects.values)
    }
    
    var ghostScript : PSGhostScript = PSGhostScript()
    
    
    //the script is parsed into a 'ghost script' which just contains the values and names of all the entries and attributes etc.  This function builds the real thing from the ghost - trying its best to use objects which already exist
    func buildFromGhostScript(newGhostScript : PSGhostScript) -> Bool {
        if (ghostScript.errors) {
            //println("Errors detected in script - no building")
            return false
        }
        let scriptData = mainWindowController.scriptData
        print("BEGINNING CONVERSION FROM GHOST TO REAL")
        errorHandler.reset()
        
        scriptData.beginUndoGrouping("Update Layout From Script")
        self.ghostScript = newGhostScript
        
        
        //Stages to process:
        //1. check there are actually ghost entries to process
        //2. check for duplicate entries in the ghost add errors if there are any
        //3. get plugins to identify entries / report any conflicts
        //3.5 check syntax of entries
        //4. match existing entries i.e. if name and type are the same.
        //5. delete no longer existing entries and create new entries which are not present
        
        
        var success = checkForExistingEntries()
        success = success && processOldPsyScopeEntries()
        success = success && checkForDuplicateEntries()
        success = success && checkForIllegalBaseEntryNames()
        success = success && identifyObjectEntries()
        
        success = success && matchExistingEntries()
        errorHandler.presentErrors()
        print("END CONVERSION FROM GHOST TO REAL")
        scriptData.endUndoGrouping(success)

        entryValueChecker = PSEntryValueChecker(scriptData: scriptData)
        entryValueChecker.checkScriptEntryValuesAsync(errorHandler)
        return success
    }
    
    //Check if there are entries on the ghost script
    func checkForExistingEntries() -> Bool {
        if ghostScript.entries.count > 0 {
            return true
        } else {
            errorHandler.newError(PSErrorNoEntries())
            return false
        }
    }
    
    //Remove some old psyscope entries (if importing for example)
    func processOldPsyScopeEntries() -> Bool {
        var entriesToRemove : [PSGhostEntry] = []
        for ge in ghostScript.entries {
            if ge.name == "BuilderData" {
                entriesToRemove.append(ge) //builder data is no longer needed in this version
            } else if ge.name == "Experiment" && ge.currentValue.rangeOfString("@StandardPsyScopeMenuItems") != nil {
                entriesToRemove.append(ge) //old scripts include this entry which is no longer needed... (perhaps should be documented)
                errorHandler.newWarning(PSScriptError(errorDescription: "PsyScopeX Import Warning", detailedDescription: "An entry named 'Experiment' with the value @StandardPsyScopeMenuItems was detected - this is normally from importing an old PsyScopeX script.", solution: "This entry has been deleted, but be aware that you may need to add it again, if you wanted to use the old PsyScopeX GUI with the script.", range: NSMakeRange(0,0)))
            
                for ge2 in ghostScript.entries {
                    if ge2.name == "Menus" {
                        //remove a reference to Experiment in menu
                        if let rangeOfExperiment = ge2.currentValue.rangeOfString("Experiment") {
                            ge2.currentValue.removeRange(rangeOfExperiment)
                        }
                        if ge2.currentValue.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == "" {
                            entriesToRemove.append(ge2)
                        }
                    }
                }
            }
        }
        
        for removeEntry in entriesToRemove {
            ghostScript.entries = ghostScript.entries.filter({ $0 as PSGhostEntry != removeEntry })
        }
        
        return true
    }
    
    //Check for duplicate names returns true of no duplicates
    func checkForDuplicateEntries() -> Bool {
        let duplicates = checkForDuplicates(ghostScript.entries as [PSGhostEntry])
        print("Found no duplicates: \(duplicates)")
        return duplicates
    }
    
    //returns true if no duplicate
    func checkForDuplicates(ghostEntriesArray : [PSGhostEntry]) -> Bool {
        var noduplicates = true
        let endIndex = ghostEntriesArray.count - 1
        if endIndex == -1 { return true }
        for i in 0...endIndex {
            //check for duplicate entry at this level
            if (i < endIndex) {
                for j in (i+1)...(endIndex){
                    if ghostEntriesArray[i].name == ghostEntriesArray[j].name {
                        errorHandler.newError(PSErrorDoubleEntry(ghostEntriesArray[i].name,range: ghostEntriesArray[i].range))
                        noduplicates = false
                        
                    }
                }
            }
            
            //check for duplicate sub entries, recursively
            noduplicates = checkForDuplicates(ghostEntriesArray[i].subEntries as [PSGhostEntry]) && noduplicates
            
        }
        
        return (noduplicates)
    }
    
    
    //3. check for illegal names
    func checkForIllegalBaseEntryNames() -> Bool {
        let reservedNames = mainWindowController.scriptData.pluginProvider.illegalEntryNames
        var noIllegalNames = true
        for ghostEntry in ghostScript.entries {
            if reservedNames.contains(ghostEntry.name) {
                errorHandler.newError(PSErrorIllegalEntryName(ghostEntry.name,range: ghostEntry.range))
                noIllegalNames = false
            }
        }
        return noIllegalNames
    }
    
    //4. get plugins to identify entries and attributes
    func identifyObjectEntries() -> Bool {

        //3.1 get each plugin to identify entries
        var errors : [PSScriptError] = []
        for tool_plugin in plugins  {
            errors += tool_plugin.identifyEntries(ghostScript)
        }
        
        //3.2 get attributes to identify entries
        for attribute_plugin in attributePlugins {
            errors += attribute_plugin.identifyEntries(ghostScript) as! [PSScriptError]
        }
        
        //Now for entries without a type, call them blank entries
        for ge in ghostScript.entries as [PSGhostEntry] {
            if ge.type == "" {
                errorHandler.newWarning(PSScriptError(errorDescription: "Unidentified Entry", detailedDescription: "Entry named \(ge.name) type not identified", solution: "This is normally fine, if you have been doing custom scripting", range: ge.range))
            }
        }
        
        addPluginErrors(errors)
        print("Errors found during plugin identification: \(errors.count)")
        return errors.count == 0
    }
    
    func addPluginErrors(errorArray : [PSScriptError]) {
        errorArray.forEach({errorHandler.newError($0)})
        errorHandler.presentErrors()
    }
    
    //5. match existing entries i.e. if name and type are the same.
    //6. delete no longer existing entries and create new entries which are not present
    func matchExistingEntries() -> Bool {
    
        let scriptData = mainWindowController.scriptData
        //next for each key entry/attribute, scan for this in the ghost objects,
        let baseEntries = scriptData.getBaseEntries()
        
        var entries_to_delete : [Entry] = []
        var namesOfEntriesThatWereNotIdentifiedButRetainType : [String] = []
        
        for real_entry in baseEntries {
            
            //delete entries which are no longer there
            var deleted = true
            for ge in ghostScript.entries as [PSGhostEntry] {
                
                if ge.name == real_entry.name {
                    //matching name
                    if ge.type == real_entry.type {
                        print("Found matching \(real_entry.name) of type \(real_entry.type) in ghostscript...")
                        deleted = false
                    } else if ge.type == "BlankEntry" {
                        namesOfEntriesThatWereNotIdentifiedButRetainType.append(real_entry.name)
                        print("Found entry \(real_entry.name) of type \(real_entry.type) in ghostscript...   ...not identified, but keeping same identity.")
                        ge.type = real_entry.type
                        deleted = false
                    }
                    
                    if (!deleted) {
                        //and for entries which are the same change the attributes
                        if let plugin = PSPluginSingleton.sharedInstance.getPlugin(ge.type) {
                            plugin.updateEntry(real_entry, withGhostEntry: ge, scriptData: scriptData)
                        } else if let attribute = PSPluginSingleton.sharedInstance.attributeObjects[ge.type] {
                            attribute.updateEntry(real_entry, withGhostEntry: ge, scriptData: scriptData)
                        } else {
                            //error?
                        }
                        ge.instantiated = true
                    }
                }
         
            }
        
            if (deleted) {
                print ("Did not find entry \(real_entry.name) of type \(real_entry.type) in script, deleting...")
                entries_to_delete.append(real_entry)
            }
        }
        
        print("Entries before deletion")
        for e in scriptData.getBaseEntries() { print(e.name, terminator: "") }
        print("=======")
        for delete_entry in entries_to_delete {
            print("Deleting former entry \(delete_entry.name)")
            scriptData.deleteBaseEntry(delete_entry) //in layout controller, make sure it knows this object is to be deleted
            
        }
        
        print("=======")
        print("Entries after deletion")
        for e in scriptData.getBaseEntries() { print(e.name, terminator: "") }
        print("=======")
        
        var all_new_lobjects : [LayoutObject] = []
        
        //instantiate attribute related entries which are new
        for attribute in attributePlugins {
            var new_entries : [PSGhostEntry] = []
            for ge in ghostScript.entries as [PSGhostEntry] {
                if (!ge.instantiated && (ge.type == attribute.codeName())) {
                    new_entries.append(ge)
                }
            }
            
            if new_entries.count > 0 {
                let new_lobjects = attribute.createBaseEntriesWithGhostEntries(new_entries, withScript: scriptData)
                
                //if nil, then the creation failed
                if (new_lobjects == nil) {
                    print("Unable to create objects of type " + attribute.codeName())
                } else {
                    
                    //give the new objects coordinates
                    print("Created new layout object of type " + attribute.codeName())
                    for lobject in new_lobjects as! [LayoutObject] {
                        all_new_lobjects.append(lobject)
                    }
                }
            }
        }
            
        //instantiate entries which are new
        for plugin in plugins  {
            print("Instantiating new entries for type: \(plugin.type())")
            var new_entries : [PSGhostEntry] = []
            for ge in ghostScript.entries as [PSGhostEntry] {
                if (!ge.instantiated && (ge.type == plugin.type())) {
                    print(" - \(ge.name)")
                    new_entries.append(ge)
                }
            }
            
            if new_entries.count > 0 {
                if let new_lobjects = plugin.createObjectWithGhostEntries(new_entries, withScript: scriptData) {
                    //give the new objects coordinates
                    print("Created new layout object of type " + plugin.type())
                    for lobject in new_lobjects {
                        all_new_lobjects.append(lobject)
                    }
                } else {
                    print("Unable to create objects of type " + plugin.type())
                }
            }
            
        }
        
        //which objects have not been instantiated?
        let uninstantiated : [PSGhostEntry] = ghostScript.entries.filter({ !$0.instantiated })
        if let pstool = scriptData.pluginProvider.getInterfaceForType(PSType.UndefinedEntry) {
            if let new_lobjects = pstool.createObjectWithGhostEntries(uninstantiated, withScript: scriptData) {
                new_lobjects.forEach({all_new_lobjects.append($0)})
            }
        }

        

        //now run through the updating of links and positions
        //mocEntries = docMoc.getAllObjectsOfEntity("Entry", responder: NSApp as? NSResponder) as [Entry]
        let mocLobjects = scriptData.getLayoutObjects()
        
        for lobject in mocLobjects {
            //first delete all child links
            lobject.removeChildLink(lobject.childLink)
            //then instantiate all child links
            for ge in ghostScript.entries as [PSGhostEntry] {
                if (ge.name == lobject.mainEntry.name) {
                    for linkedge in ge.links {
                        for lobject2 in mocLobjects {
                            if lobject2.mainEntry.name == linkedge.name {
                                //hurrah a link
                                lobject.addChildLinkObject(lobject2)
                            }
                        }
                    }
                }
            }
        }
        
        //finally position the objects correctly
        positionNewLayoutObjects(all_new_lobjects, all_lobjects: mocLobjects)
        
        if namesOfEntriesThatWereNotIdentifiedButRetainType.count > 0 {
        
            let warningText = "Warning: The following entry(s) were not correctly identified in the script, but have retained their former identity:\n\n \(namesOfEntriesThatWereNotIdentifiedButRetainType.joinWithSeparator(" ") ) \n\n\nThis normally arises if you have an object such as a Template, which is not referenced in any 'Templates:' sub entry.  This warning can be safely ignored, unless you recently deleted an entry of one type and created a new entry with the same name.   To avoid this warning, link the entry to it's parent."
        
            PSModalAlert(warningText)
        }
        return true
    }
    
    func positionNewLayoutObjects(new_lobjects : [LayoutObject], all_lobjects : [LayoutObject]) {
        
        let scriptData = mainWindowController.scriptData
        
        //to flag unpositioned objects
        for new_lobject in new_lobjects {
            new_lobject.xPos = -1
            new_lobject.yPos = -1
        }
        
        //sort by number of children
        let lobjects = new_lobjects.sort({ (s1: LayoutObject, s2: LayoutObject) -> Bool in
            return s1.childLink.count > s2.childLink.count })
        
        for new_lobject in lobjects {
            if new_lobject.xPos == -1 {
                //get already position parent
                for p in new_lobject.parentLink as! Set<LayoutObject> {
                    if p.xPos != -1 {
                        PSPositionNewObjectWithParent(new_lobject, parentObject: p)
                        PSSortSubTree(new_lobject, scriptData: scriptData) //ok position for this object, so sort its children
                        break
                    }
                }
                
            }
        }
        
        
        //for un positioned objects put in a free spot
        for new_lobject in lobjects {
            if new_lobject.xPos == -1 {
                PSPutInFreeSpot(new_lobject, scriptData: scriptData)  // automatically sorts sub tree
            }
        }
        
    }

    
    
    
    
    
    func findFreeSpot(lobject : LayoutObject, all_lobjects : [LayoutObject]) {
        //todo check screen coordinate
        //for now, pile at 50,50 going up
        let x : Float = 50
        var y : Float = 50
        var tooClose = true
        repeat {
            tooClose = false
            for lobj in all_lobjects {
                let x_diff = (lobj.xPos.floatValue - x)
                let y_diff = (lobj.yPos.floatValue - y)
                if ((x_diff * x_diff) + (y_diff * y_diff) < 250) {
                    y += 50
                    tooClose = true
                }
            }
        } while (tooClose)
        lobject.xPos = NSNumber(float: x)
        lobject.yPos = NSNumber(float: y)
    }
    
}