//
//  PSScriptData.swift
//  PsyScopeEditor
//
//  Created by James on 07/02/2015.
//

import Foundation



//This contains various public functions for the script core-data manipulations.  In general, nothing should be added or taken away from the documents MOC, by anything other than this class, and this class should be used to access the objects.

extension NSManagedObjectContext {
    public func getAllObjectsOfEntity(_ name : String) -> [NSManagedObject] {
        
        let fetch = NSFetchRequest<NSFetchRequestResult>()
        fetch.entity = NSEntityDescription.entity(forEntityName: name, in: self)
        
        do {
            let return_value = try self.fetch(fetch) as! [NSManagedObject]
            return return_value
        } catch {
            print(error)
        }

        return []
    }
    
    public func insertNewObjectOfEntity(_ name : String) -> NSManagedObject {
        return NSEntityDescription.insertNewObject(forEntityName: name, into: self) as NSManagedObject
    }
    
}


extension NSMenu {
    public func setAllTargetsAndActions(_ target : AnyObject, action : Selector) {
        
        for subItem in self.items as [NSMenuItem] {
            if subItem.tag != 0 || subItem.hasSubmenu {
                subItem.target = target
                subItem.action = action
            }
            if let subMenu = subItem.submenu {
                subMenu.setAllTargetsAndActions(target, action: action)
            }
        }
    }
}


public class PSScriptData : NSObject {
    
    public init(docMoc: NSManagedObjectContext, pluginProvider: PSPluginProvider, document: NSDocument, selectionInterface: PSSelectionInterface) {
        self.docMoc = docMoc
        self.pluginProvider = pluginProvider
        self.document = document
        self.inUndoGrouping = false
        self.undoGrouping = ""
        self.selectionInterface = selectionInterface
        let toBeBanned = NSMutableCharacterSet.alphanumeric()
        toBeBanned.addCharacters(in: "-_")
        bannedNameCharacters = toBeBanned.inverted
        super.init()
    }
    
    //MARK: Dependencies / Variables
    
    public let pluginProvider : PSPluginProvider
    public let docMoc : NSManagedObjectContext
    public let document : NSDocument
    public var window : NSWindow!
    var inUndoGrouping : Bool
    var undoGrouping : String
    public let selectionInterface : PSSelectionInterface
    fileprivate var _scriptObject : Script?
    public let bannedNameCharacters : CharacterSet

    
    //MARK: Windows
    
    public func addWindowController(_ windowController : NSWindowController) {
        self.document.addWindowController(windowController)
    }
    
    public func removeWindowController(_ windowController : NSWindowController) {
        self.document.addWindowController(windowController)
    }
    
    public func getWindowControllersAssociatedWithEntry(_ entry : Entry) -> [PSEntryWindowController] {
        var windowControllers : [PSEntryWindowController] = []
        for windowController in self.document.windowControllers {
            if let entryWindowController = windowController as? PSEntryWindowController, entryWindowController.entry == entry {
                    windowControllers.append(entryWindowController)
            }
        }
        return windowControllers
    }
    
    //MARK: Directory
    
    public func documentDirectory() -> String? {
        if let url = document.fileURL {
            return (url.path as NSString).deletingLastPathComponent
        }
        return nil
    }
    
    public func alertIfNoValidDocumentDirectory() -> Bool {
        if let _ = documentDirectory() {
            return true
        } else {
            PSModalAlert("You need to save the document before running or storing file names")
        }
        return false
    }
    
    /*func document(doc : NSDocument, didSave : Bool, contextInfo : UnsafeMutablePointer<Void>) {
        println()
    }*/
    
    
    //MARK: Attribute Source Menu

    public func identifyAsAttributeSourceAndReturnRepresentiveString(_ string : String) -> (NSAttributedString, String)? {
        //cycle through attributeTools and ask them to identify themselves
        for (_, tool) in pluginProvider.attributeSourceTools {
            let t = tool as PSToolInterface
            let attributedString = t.identifyAsAttributeSourceAndReturnRepresentiveString(string)
            if attributedString.count == 2 {
                let returnValue = (attributedString[0] as! NSAttributedString, attributedString[1] as! String)
                return returnValue
            }
            
        }
        return nil
    }
    
    
    public func getVaryByMenu(_ target : AnyObject, action : Selector) -> NSMenu {
        let menu = self.selectionInterface.varyByMenu()
        menu.setAllTargetsAndActions(target, action: action)
        
        return menu
    }
    
    public func valueForMenuItem(_ menuItem : NSMenuItem, original : String, originalFullType : PSAttributeType?) -> String? {
        if menuItem.title == "Define Value" {
            return nil
        } else if menuItem.title == "Enter Formula" {
            return nil
        } else if let entry = menuItem.representedObject as? Entry,
            let tool = pluginProvider.getInterfaceForType(PSType.FromName(entry.type)) {
                
                return tool.menuItemSelectedForAttributeSource(menuItem.title, tag: menuItem.tag, entry: entry, originalValue: original, originalFullType: originalFullType, scriptData: self)
        } else if let tool = menuItem.representedObject as? PSToolInterface {
            return tool.menuItemSelectedForAttributeSource(menuItem.title, tag: menuItem.tag, entry: nil, originalValue: original, originalFullType: originalFullType, scriptData: self)
        } else {
            return original
        }
    }
    
    
    //MARK: Setup
    
    var scriptObject : Script {
        get {
            
            if let _scriptObject = _scriptObject {
                return _scriptObject
            }
            
            let scripts = docMoc.getAllObjectsOfEntity("Script") as! [Script]
            if (scripts.count == 1) {
                let script : Script = scripts.first!
                _scriptObject = script
                return script
            } else if (scripts.count == 0) {
                let new_script = docMoc.insertNewObjectOfEntity("Script") as! Script
                _scriptObject = new_script
                return new_script
            }
            
            fatalError("Too many scripts in file - an error has occurred")
        }
    }
    
    public func setUpInitialScriptState() {
        docMoc.undoManager!.disableUndoRegistration()
        
        //create experiment icon
        if let new_entry = createNewObjectFromTool(PSType.Experiment) {
            new_entry.layoutObject.xPos = 150
            new_entry.layoutObject.yPos = 50
            renameEntry(new_entry, nameSuggestion: "NewExperiment")
            
            
            //create subject information stuff
            if let subjectName = createNewObjectFromTool(PSType.SubjectInfo) {
                
                renameEntry(subjectName,nameSuggestion: "SubjectName")
                subjectName.currentValue = "SUBJECT NAME"
                
            }
            
            if let subjectNumber = createNewObjectFromTool(PSType.SubjectInfo) {
                renameEntry(subjectNumber,nameSuggestion: "SubjectNumber")
                subjectNumber.currentValue = "1"
                let type = getOrCreateSubEntry("Type", entry: subjectNumber, isProperty: true)
                type.currentValue = "Integer"
            }
            
            if let runNumber = createNewObjectFromTool(PSType.SubjectInfo) {
                renameEntry(runNumber,nameSuggestion: "RunNumber")
                runNumber.currentValue = "1"
                let type = getOrCreateSubEntry("Type", entry: runNumber, isProperty: true)
                type.currentValue = "Integer"
            }
        }
        
        
        
    
        docMoc.processPendingChanges()
        docMoc.undoManager!.enableUndoRegistration()
        docMoc.undoManager!.removeAllActions()
        selectionInterface.refresh()
    }
    
    //MARK: Attribute Interface
    
    public func getAttributeInterfaceForAttributeEntry(_ entry : Entry) -> PSAttributeInterface? {
        return getAttributeInterfaceForFullType(entry.type)
    }
    
    public func getAttributeInterfaceForFullType(_ fullType : String) -> PSAttributeInterface? {
        
        for att in pluginProvider.attributes {
            if att.fullType == fullType {
                //found the extension
                return att.interface
            }
        }
        
        return PSAttributeGeneric()
    }
    
    //MARK: Sorting
    
    //sorts an array of layout objects via their names - not a safe public function, no checks performed...
    public func sortLayoutObjects(_ lobjects : [LayoutObject], order : [String]) -> [LayoutObject] {
        var return_array : [LayoutObject] = []
        for name in order {
            for obj in lobjects {
                if obj.mainEntry.name == name {
                    return_array.append(obj)
                    break
                }
            }
        }
        
        return return_array
    }
    
    //MARK: Get entries
    
    //to be used when building objects during script creation etc
    public func getMainExperimentEntryIfItExists() -> Entry? {
        if let exps = getBaseEntry("Experiments"),
            let expEntry = getBaseEntry(exps.currentValue) {
                return expEntry
        }
        return nil
    }
    
    public func getMainExperimentEntry() -> Entry {
        if let expEntry = getMainExperimentEntryIfItExists() {
                return expEntry
        }
        fatalError("No experiments entry found!!")
    }
    
    public func getBaseEntriesOfType(_ type : PSType) -> [Entry] {
        let entries = self.getBaseEntries()
        return entries.filter({
            (entry : Entry) -> (Bool) in
            return entry.type == type.name
        })
    }
    
    public func getLinkedParentEntriesOfType(_ type : String, entry : Entry) -> [Entry] {
        var parents : [Entry] = []
        let linkObjects = entry.layoutObject.parentLink as! Set<LayoutObject>
        for linkObject in linkObjects {
            if linkObject.mainEntry.type == type {
                //then add
                parents.append(linkObject.mainEntry)
            }
            //now do parents
            let other_parents : [Entry] = getLinkedParentEntriesOfType(type, entry: linkObject.mainEntry)
            parents += other_parents
        }
        return parents
    }
    
    public func getBaseEntryOfSubEntry(_ entry : Entry) -> Entry {
        if let e = entry.parent {
            return getBaseEntryOfSubEntry(e)
        } else {
            return entry
        }
    }
    
    public func getBaseEntry(_ base_entry_name : String) -> Entry? {
        let base_entries = self.getBaseEntries()
        let quotes = CharacterSet(charactersIn: "\"")
        let strippedName = base_entry_name.trimmingCharacters(in: quotes)
        //println("striped: " + strippedName)
        for a in base_entries {
            
            //println("compagin: " + a.name.stringByTrimmingCharactersInSet(quotes))
            
            if (a.name.trimmingCharacters(in: quotes) == strippedName ) {
                return a
            }
        }
        return nil
    }
    
    
    public func getSubEntry(_ sub_entry_name : String, entry : Entry) -> Entry? {
        let sub_entries = entry.subEntries.array as! [Entry]
        for a in sub_entries {
            if (a.name == sub_entry_name) {
                return a
            }
        }
        return nil
    }
    
    public func getOrCreateBaseEntry(_ name: String, type : PSType, section : PSSection? = nil) -> Entry {
        
        let psSection = section != nil ? section! : type.defaultSection
        
        let existing_entry = getBaseEntry(name)
        let section = getOrCreateSection(psSection)
        if let ee = existing_entry {
            ee.userFriendlyName = name
            ee.parentSection = section
            ee.type = type.name
            return ee
        }
        
        let new_base_entry = self.insertNewBaseEntry(name, type: type)
        new_base_entry.userFriendlyName = name
        new_base_entry.parentSection = section
        return new_base_entry
    }
    
    public func getLayoutObjects() -> [LayoutObject] {
        return docMoc.getAllObjectsOfEntity("LayoutObject") as! [LayoutObject]
    }
    
    public func getBaseEntriesWithLayoutObjects() -> [Entry] {
        let layoutObjects = docMoc.getAllObjectsOfEntity("LayoutObject") as! [LayoutObject]
        var entries : [Entry] = []
        for lobj in layoutObjects {
            if lobj.mainEntry != nil {
                entries.append(lobj.mainEntry)
            }
        }
        return entries
    }
    
    public func getBaseEntries() -> [Entry] {
        return scriptObject.entries.array as! [Entry]
    }
    
    public func getSections() -> [Section] {
        return scriptObject.sections.array as! [Section]
    }
    
    public func getChildEntries(_ entry : Entry) -> [Entry] {
        let lobjects = Array(entry.layoutObject.childLink.array as! [LayoutObject])
        return lobjects.map({
            (lobj : LayoutObject) -> Entry in
            return lobj.mainEntry
        })
    }
    
    public func getParentEntries(_ entry : Entry) -> [Entry] {
        let lobjects = Array(entry.layoutObject.parentLink as! Set<LayoutObject>)
        return lobjects.map({
            (lobj : LayoutObject) -> Entry in
            return lobj.mainEntry
        })
    }
    
    
    //MARK: Get names
    
    public func getNamesOfEntries(_ entries : [Entry]) -> [String] {
        return entries.map({
            (entry : AnyObject) -> String in
            return entry.name
        })
    }
    
    public func getBaseEntryNames() -> [String] {
        return getNamesOfEntries(scriptObject.entries.array as! [Entry])
    }
    
    public func getAllEntryNames() -> [String] {
        //TODO probably can replace with more efficient MOC fetch
        let entries = docMoc.getAllObjectsOfEntity("Entry") as! [Entry]
        let names : [String] = entries.map({
            (entry : Entry) -> String in
            if (entry.name != nil) {
                return entry.name
            }
            return ""
        })
        return names
    }
    
    public func getSubEntryNames(_ entry : Entry) -> [String] {
        var names : [String] = []
        for subEntry in entry.subEntries.array as! [Entry] {
            names.append(subEntry.name)
        }
        return names
    }
    
    
    //MARK: Entry naming
    
    //returns true if no entries with names in given array.  Returns false if
    //so, plus name of first one detected as taken
    public func baseEntriesAreFree(_ new_entries : [String]) -> (isFree : Bool, notFreeString : String?) {
        let current_entries : [String] = getBaseEntryNames()
        for e in new_entries {
            if current_entries.contains(e) {
                return (false, e)
            }
        }
        return (true, nil)
    }
    
    //give it a name e.g. Experiment and will return the next available by adding a number on the end if needed
    public func getNextFreeBaseEntryName(_ entryName : String) -> String {
        let entryNames = getBaseEntryNames()
        return getNextFreeEntryNameFromExistingNamesArray(entryName, existingNames: entryNames)
    }
    
    public func getNextFreeSubEntryName(_ entryName : String, parentEntry : Entry) -> String {
        let subEntryNames = (parentEntry.subEntries.array as! [Entry]).map { $0.name! }
        return getNextFreeEntryNameFromExistingNamesArray(entryName, existingNames: subEntryNames)
    }
    
    func getNextFreeEntryNameFromExistingNamesArray(_ entryName : String, existingNames : [String]) -> String {
        //strip existing number at end
        var entry_base = entryName.trimmingCharacters(in: CharacterSet(charactersIn: " 1234567890"))
        if entry_base == "" { entry_base = "Entry" }
        
        var isFree = false
        var run :Int = 0
        var testName = entry_base
        repeat {
            isFree = true
            if (run > 0) { testName = entry_base + "\(run)" }
            if existingNames.contains(testName) ||  pluginProvider.entryNameIsReservedOrIllegal(testName) { isFree = false }
            run += 1
        } while (!isFree)
        
        return testName
    }
    
    @discardableResult
    public func renameEntry(_ entry : Entry, nameSuggestion : String) -> Bool {
        if nameSuggestion.count < 3 { return false }
        if nameSuggestion.rangeOfCharacter(from: bannedNameCharacters) != nil { return false }
        
        var siblingEntries : [Entry]
        //check siblings for same name
        if let parentEntry = entry.parent,
            let siblings = parentEntry.subEntries {
            
                for sibling in siblings {
                    if (sibling as! Entry).name == nameSuggestion {
                        return renameEntry(entry, nameSuggestion: nameSuggestion + "_2")
                    }
                }
                siblingEntries = siblings.array as! [Entry]
        } else {
            siblingEntries = getBaseEntries()
        }
        
        //also check with reserved names
        if pluginProvider.entryNameIsReservedOrIllegal(nameSuggestion) {
            return renameEntry(entry, nameSuggestion: nameSuggestion + "_2") //recurse
        }
        
        //check for valid characters
        if nameSuggestion.trimmingCharacters(in: entryNameCharacterSet) == "" {
            //SUCCESS
            let oldName = entry.name
            
            //Offer to rename other similar named entries if appropriate
            let baseEntrNames = getBaseEntryNames()
            var baseEntryNamesToChange : [(oldName: String, newName : String)] = []
            for baseEntryName in baseEntrNames {
                if (baseEntryName.range(of: oldName!) != nil) && (baseEntryName != oldName) {
                    baseEntryNamesToChange.append((baseEntryName,baseEntryName.replacingOccurrences(of: oldName!, with: nameSuggestion)))
                }
            }
            
            if baseEntryNamesToChange.count > 0 {
                let new_alert = NSAlert()
                let inputView = NSView(frame: NSMakeRect(0, 0, 400, CGFloat(24 * baseEntryNamesToChange.count)))
                var checkBoxes : [NSButton] = []
                for (index,val) in baseEntryNamesToChange.enumerated() {
                    let newCheckBox = NSButton(frame: NSMakeRect(0, CGFloat(index * 24), 400, 24))
                    newCheckBox.state = NSControl.StateValue.on
                    newCheckBox.setButtonType(NSButton.ButtonType.switch)
                    newCheckBox.title = "\(val.oldName) -> \(val.newName)"
                    inputView.addSubview(newCheckBox)
                    checkBoxes.append(newCheckBox)
                }
                
                new_alert.accessoryView = inputView
                new_alert.messageText = "Some similar named entries have been found do you want to rename these entries too? (Recommended to do so if you are unsure)"
                new_alert.runModal()
                
                for (index,cb) in checkBoxes.enumerated() {
                    let baseEntryNameToChange = baseEntryNamesToChange[index]
                    if cb.state.rawValue == 1 {
                        if let entry = getBaseEntry(baseEntryNameToChange.oldName) {
                            renameEntry(entry, nameSuggestion: baseEntryNameToChange.newName)
                        }
                    }
                }
                
            }
            
            
            entry.name = nameSuggestion
            
            //if a base entry, then need to change references to it from other parts of the script (otherwise just in siblings)
            searchAndReplaceValues(oldName!, newName: nameSuggestion, entries: siblingEntries)
            
            
            return true
        } else {
            let splitByBadChars = nameSuggestion.components(separatedBy: entryNameCharacterSet.inverted)
            return renameEntry(entry, nameSuggestion: splitByBadChars.joined(separator: "_"))
        }
    }
    
    lazy var entryNameCharacterSet : CharacterSet = {
        () -> CharacterSet in
        var allowed_characters = NSMutableCharacterSet(charactersIn: " _\"")
        allowed_characters.formUnion(with: CharacterSet.alphanumerics)
        return allowed_characters as CharacterSet
        }()
    
    //MARK: Entry inserting

    //main point to insert an entry
    fileprivate func insertNewEntry(_ name : String, typeName : String) -> Entry {
        let new_entry = docMoc.insertNewObjectOfEntity("Entry") as! Entry
        new_entry.currentValue = ""
        new_entry.comments = ""
        new_entry.metaData = ""
        new_entry.isKeyEntry = false
        new_entry.name = name
        new_entry.type = typeName
        new_entry.isProperty = false
        new_entry.userFriendlyName = name
        return new_entry
    }
    
    public func insertNewBaseEntry(_ name : String, type : PSType) -> Entry {
        assert(!getBaseEntryNames().contains(name), "Name has to be valid and not already a base entry")
        
        let new_entry = insertNewEntry(name, typeName : type.name)
        scriptObject.addEntriesObject(new_entry)
        return new_entry
    }
    
    public func insertNewSubEntryForEntry(_ name : String, entry : Entry, type : PSAttributeType) -> Entry {
        assert(!(entry.subEntries.array as! [Entry]).map { $0.name! }.contains(name), "Name has to be valid and not already a sub Entry")
        
        let new_sub_entry = self.insertNewEntry(name, typeName: type.fullType)
        entry.addSubEntriesObject(new_sub_entry)
        return new_sub_entry
    }
    
    public func insertNewLayoutObject(_ mainEntry : Entry, otherEntries : [Entry] = []) -> LayoutObject {
        let new_lobject = docMoc.insertNewObjectOfEntity("LayoutObject") as! LayoutObject
        new_lobject.addEntriesObject(mainEntry)
        for other_entry in otherEntries {
            new_lobject.addEntriesObject(other_entry)
        }
        new_lobject.mainEntry = mainEntry
        PSPositionNewObject(new_lobject, scriptData: self)
        return new_lobject
    }
    

    //MARK: Attribute List
    
    public func addItemToAttributeList(_ attribute_name : String, entry : Entry, item : String) {
        let sub_entry = getOrCreateSubEntry(attribute_name, entry: entry, isProperty: true)
        
        let string_list = PSStringList(entry: sub_entry, scriptData: self)
        
        
        if (string_list.contains(item)) {
            //TODO error, link already created
            return
        }
        
        string_list.appendAsString(item)
    }
    
    //removes from list, doesn't remove object
    public func removeItemFromAttributeList(_ attribute_name : String, entry : Entry, item : String) {
        if let sub_entry = getSubEntry(attribute_name, entry: entry) {
            let string_list = PSStringList(entry: sub_entry, scriptData: self)
            string_list.remove(item)
        }
  
    }
    
    public func addItemToBaseList(_ name: String, type : PSType, section: PSSection, itemToAdd : String) {
        let entry = getOrCreateBaseEntry(name, type: type, section: section)
        let list = PSStringList(entry: entry, scriptData: self)
        list.appendAsString(itemToAdd)
    }

    public func removeItemFromBaseList(_ entryName : String, item : String) {
        if let entry = getBaseEntry(entryName) {
            let list = PSStringList(entry: entry, scriptData: self)
            list.remove(item)
        }
    }
    
    

    
    //MARK: Get or create
    
    //default sub_entry should set up all values
    public func getOrCreateSubEntry(_ name : String, entry : Entry, isProperty : Bool, type : PSAttributeType! = nil) -> Entry {
        
        
        if let existing_entry = getSubEntry(name, entry: entry) {
            
            if existing_entry.isProperty.boolValue != isProperty { existing_entry.isProperty = isProperty as NSNumber }
            
            if !isProperty && existing_entry.type != type.fullType {
                
                //check if type is compatible?
                fatalError("Types do not match on attribute!!")
            }
            return existing_entry
        }
        
        if type == nil && isProperty == false {
            PSModalAlert("The entry: -\(String(describing: entry.name ))- tried to create attribute named -\(name)- but no type was specified!")
        }
        
        if type != nil {
            let new_sub_entry = insertNewSubEntryForEntry(name, entry: entry, type : type)
            new_sub_entry.userFriendlyName = name
            new_sub_entry.isProperty = isProperty as NSNumber
            return new_sub_entry
        } else {
            let new_sub_entry = insertNewSubEntryForEntry(name, entry: entry, type : PSAttributeType(fullType: ""))
            new_sub_entry.userFriendlyName = name
            new_sub_entry.isProperty = isProperty as NSNumber
            return new_sub_entry
        }
    }
    
    
    public func getOrCreateSection(_ section : PSSection) -> Section {
        let exisiting_sections = docMoc.getAllObjectsOfEntity("Section") as! [Section]
        for s in exisiting_sections {
            if s.sectionName == section.name {
                return s
            }
        }
        
        let new_section = docMoc.insertNewObjectOfEntity("Section") as! Section
        scriptObject.addSectionsObject(new_section)
        new_section.sectionName = section.name
        new_section.scriptOrder = section.zOrder as NSNumber
        return new_section
    }
    
    public func createBaseEntryAndLayoutObjectPair(_ section : PSSection, entryName : String, type : PSType) -> LayoutObject {
        //get sections
        let section = self.getOrCreateSection(section)
        
        //create main block entry
        let new_name = self.getNextFreeBaseEntryName(entryName)
        let new_entry = self.insertNewBaseEntry(new_name, type: type)
        
        new_entry.isKeyEntry = true
        section.addObjectsObject(new_entry)
        
        //create the layout object
        let layout_object = self.insertNewLayoutObject(new_entry)
        
        //add the attributes that create optional windows
        //self.createAttributesFromAttributePlugins(new_entry)
        return layout_object
    }
    
    public func createNewObjectFromTool(_ type : PSType) -> Entry? {
        if let pstool = self.pluginProvider.getInterfaceForType(type) {
            return pstool.createObject(self)
        }
        
        return nil
    }
    
    //MARK: Delete
    
    public func deleteMainEntry(_ entry : Entry) {
        //get all parent Links
        if let lobject = entry.layoutObject {
            for parent in lobject.parentLink as! Set<LayoutObject> {
                for subEntry in parent.mainEntry.subEntries {
                    let stringList = PSStringList(entry: subEntry as! Entry, scriptData: self)
                    stringList.remove(entry.name)
                }
            }
        }
        deleteEntry(entry) //should cascade to all entries associated
    }
    
    public func deleteNamedSubEntryFromParentEntry(_ baseEntry : Entry, name : String) {
        if let subEntry = getSubEntry(name, entry: baseEntry) {
            deleteSubEntryFromBaseEntry(baseEntry, subEntry: subEntry)
        }
    }
    
    public func deleteSubEntryFromBaseEntry(_ baseEntry : Entry, subEntry: Entry) {
        baseEntry.removeSubEntriesObject(subEntry)
        deleteEntry(subEntry)
    }
    
    public func deleteBaseEntry(_ entry : Entry) {
        scriptObject.removeEntriesObject(entry)
        deleteEntry(entry)
    }
    
    public func deleteBaseEntryByName(_ entryName : String) {
        if let entry = getBaseEntry(entryName) {
            self.deleteBaseEntry(entry)
        }
    }
    
    fileprivate func deleteEntry(_ entry : Entry) {
        docMoc.delete(entry)
    }
    
    public func deleteSubEntries(_ entry : Entry) {
        for subEntry in entry.subEntries.array as! [Entry] {
            entry.removeSubEntriesObject(subEntry)
            deleteEntry(subEntry)
        }
    }


    
    //MARK: Undo grouping
    
    var undoLevel : Int = 0
    
    public func beginUndoGrouping(_ name : String) {
        
        if undoLevel == 0 {
            docMoc.undoManager!.beginUndoGrouping()
            docMoc.undoManager!.setActionName(name)
        }
        undoLevel += 1
        print("Begin undo grouping: \(name) - level: \(undoLevel)")
    }
    
    public func endUndoGrouping(_ success : Bool = true) {
        if undoLevel > 0 {

            undoLevel -= 1
            print("End undo grouping - level: \(undoLevel)")
            
            if undoLevel == 0 {
                docMoc.undoManager!.endUndoGrouping()
                if (!success) { docMoc.undoManager!.undoNestedGroup() }
                selectionInterface.refresh()
            }
        }
    }
    
    public var inUndoGroup : Bool {
        return undoLevel > 0
    }
    
    //MARK: Linking
    
    public func createLinkFrom(_ parent:Entry, to child:Entry, withAttribute attribute_name:String){
        addItemToAttributeList(attribute_name, entry: parent, item: child.name)
        parent.layoutObject.addChildLinkObject(child.layoutObject)
    }
    
    public func removeLinkFrom(_ parent:Entry, to child:Entry, withAttribute attribute_name:String){
        removeItemFromAttributeList(attribute_name, entry: parent, item: child.name)
        parent.layoutObject.removeChildLinkObject(child.layoutObject)
    }
    
    public func moveParentLinks(_ oldParent : Entry, newParent: Entry, withAttribute attribute_name:String) {
        
        if let oldParentSubEntry = getSubEntry(attribute_name, entry: oldParent) {
            let oldParentSubEntryList = PSStringList(entry: oldParentSubEntry, scriptData: self)
            let newParentSubEntry = getOrCreateSubEntry(attribute_name, entry: newParent, isProperty: oldParentSubEntry.isProperty.boolValue, type: PSAttributeType(fullType: oldParentSubEntry.type))
            let newParentSubEntryList = PSStringList(entry: newParentSubEntry, scriptData: self)
            
            for child_lobject in oldParent.layoutObject.childLink.array as! [LayoutObject]{
                if oldParentSubEntryList.contains(child_lobject.mainEntry.name) {
                    newParent.layoutObject.addChildLinkObject(child_lobject)
                    oldParent.layoutObject.removeChildLinkObject(child_lobject)
                    
                    //add the entries to the the new list
                    if !newParentSubEntryList.contains(child_lobject.mainEntry.name) {
                        newParentSubEntryList.appendAsString(child_lobject.mainEntry.name)
                    }
                }
            }
            
            oldParent.removeSubEntriesObject(oldParentSubEntry)
            
            //remove newParentSubEntry if its empty (shouldnt really occur?)
            if newParentSubEntryList.count == 0 {
                newParent.removeSubEntriesObject(newParentSubEntry)
            }
        }
        
        
    }
    
    
    //MARK: Searching

    
    public func searchAndReplaceValues(_ oldName : String, newName : String, entries : [Entry]) {
        for entry in entries {
            let stringList = PSStringList(entry: entry, scriptData: self)
            
            stringList.renameAllStringTokens(oldName, newName: newName)
            stringList.updateEntry()
            
            let sub_objects = entry.subEntries.array as! [Entry]
            searchAndReplaceValues(oldName, newName: newName, entries: sub_objects)
        }
    }
    
    public func searchForEntriesWithReference(_ reference : String, entries : [Entry]) -> [Entry] {
        var returnEntries : [Entry] = []
        for entry in entries {
            let stringList = PSStringList(entry: entry, scriptData: self)
            if stringList.searchForStringToken(reference) {
                returnEntries.append(entry)
            }else if searchForEntriesWithReference(reference, entries: entry.subEntries.array as! [Entry]).count > 0 {
                returnEntries.append(entry)
            }
        }
        return returnEntries
    }

    
    //MARK: Properties

    
    public func propertyValue(_ property : PSProperty, entry : Entry) -> String {
        return propertyValue(property.name, entry: entry, defaultValue: property.defaultValue)
    }
    
    public func propertyUpdate(_ property : PSProperty, entry : Entry, currentValue : String) {
        propertyUpdate(property.name, entry: entry, currentValue: currentValue, defaultValue: property.defaultValue, essential: property.essential)
    }
    
    public func propertyValue(_ name : String, entry : Entry, defaultValue : String) -> String {
        if let existing_entry = getSubEntry(name, entry: entry) {
            return existing_entry.currentValue
        } else {
            return defaultValue
        }
    }
    
    public func assertPropertyIsPresent(_ property : PSProperty, entry : Entry) {
        //ensure property is present with current value
        if let existing_entry = getSubEntry(property.name, entry: entry) {
            existing_entry.isProperty = true
            return
        }
        
        //create property if essential
        if property.essential {
            let new_sub_entry = insertNewSubEntryForEntry(property.name, entry: entry, type : PSAttributeType(fullType: ""))
            new_sub_entry.userFriendlyName = property.name
            new_sub_entry.isProperty = true
            new_sub_entry.currentValue = property.defaultValue
        }
    }
    
    public func addDefaultProperty(_ property : PSProperty, entry : Entry) {
        //ensure property is present with current value
        if let existing_entry = getSubEntry(property.name, entry: entry) {
            existing_entry.isProperty = true
            existing_entry.currentValue = property.defaultValue
            return
        }
        
        //create property
        let new_sub_entry = insertNewSubEntryForEntry(property.name, entry: entry, type : PSAttributeType(fullType: ""))
        new_sub_entry.userFriendlyName = property.name
        new_sub_entry.isProperty = true
        new_sub_entry.currentValue = property.defaultValue
    }
    
    
    public func propertyUpdate(_ name : String, entry : Entry, currentValue : String, defaultValue : String, essential : Bool) {
        //if currentValue = defaultValue, will delete the attribute entry
        if currentValue == defaultValue {
            if !essential {
                deleteNamedSubEntryFromParentEntry(entry, name: name)
            }
            return
        }
        
        //ensure property is present with current value
        if let existing_entry = getSubEntry(name, entry: entry) {
            existing_entry.isProperty = true
            existing_entry.currentValue = currentValue
            return
        }
        
        //create property
        let new_sub_entry = insertNewSubEntryForEntry(name, entry: entry, type : PSAttributeType(fullType: ""))
        new_sub_entry.userFriendlyName = name
        new_sub_entry.isProperty = true
        new_sub_entry.currentValue = currentValue
        return
    }
    
    //MARK: Archiving
    
    public func archiveBaseEntry(_ entry : Entry) -> Data {
        var dict : [AnyHashable: Any] = [:]
        
        //archive attributes
        let attributes : [NSString] = Array(entry.entity.attributesByName.keys) as [NSString]
        for at in attributes {
            let val = entry.value(forKey: at as NSString as String) as! NSObject?
            if let v = val {
                dict[at] = v
            }
        }
        
        //now the subentries
        var subEntries : [AnyObject] = []
        for attribute in entry.subEntries.array as! [Entry] {
            let attribute_dict = PSAttributeEntryToNSDictionary(attribute)
            subEntries.append(attribute_dict)
        }
        
        dict["subEntries"] = subEntries
        
        //now all child links have to be copied too
        var linkedObjects : [Data] = []
        for linkedObject in entry.layoutObject.childLink.array as! [LayoutObject]{
            let data = archiveBaseEntry(linkedObject.mainEntry)
            linkedObjects.append(data)
        }
        
        dict["linkedObjects"] = linkedObjects
        
        //finally the position
        dict["layoutObjectXPos"] = entry.layoutObject.xPos
        dict["layoutObjectYPos"] = entry.layoutObject.yPos
        
        return NSKeyedArchiver.archivedData(withRootObject: dict)
    }
    
    
    
    //creates copy of entry from nsdata, remember to rename the base entry that is returned
    public func unarchiveBaseEntry(_ data : Data) -> Entry? {
        let data_dict = NSKeyedUnarchiver.unarchiveObject(with: data) as! NSDictionary
        let type = data_dict["type"] as! String
        //create brand new object of type, and replace attributes
        var new_entry : Entry
        
        if let ne = self.createNewObjectFromTool(PSType.FromName(type)) { new_entry = ne }
        else { return nil }
        
        
        new_entry.layoutObject.xPos = 100
        new_entry.layoutObject.yPos = 100
        
        //delete existing subEntries
        let existing_ses = new_entry.subEntries.array as! [Entry]
        for se in existing_ses {
            self.deleteEntry(se)
        }
        
        var nameChanges : [String : String] = [:]
        
        
        for kvp in data_dict {
            
            let key = kvp.key as! NSString
            print("key \(key) value \(kvp.value)")
            switch(key) {
            case "subEntries":
                if let subSet = kvp.value as? [AnyObject] {
                    let relatedObjects = new_entry.mutableOrderedSetValue(forKey: "subEntries")
                    for subDict in subSet {
                        //create a new object
                        if let sd = subDict as? NSDictionary {
                            let new_subentry = PSCreateEntryFromDictionary(self.docMoc, dict: sd)
                            relatedObjects.add(new_subentry)
                        }
                    }
                }
            case "linkedObjects":
                if let child_objects = kvp.value as? [Data] {
                    for co in child_objects {
                        if let new_child_entry = unarchiveBaseEntry(co) {
                            new_entry.layoutObject.addChildLinkObject(new_child_entry.layoutObject)
                            //rename entry and remember the name change, to do search and replace
                            //once sure that all attributes processed
                            
                            
                            let new_name = self.getNextFreeBaseEntryName(new_child_entry.name)
                            nameChanges[new_child_entry.name] = new_name
                            new_child_entry.name = new_name
                        }
                    }
                }
            case "name":
                let new_name = getNextFreeBaseEntryName(kvp.value as! String)
                new_entry.setValue(new_name, forKey: key as String)
                
            case "layoutObjectXPos":
                let xval : NSNumber = kvp.value as! NSNumber
                new_entry.layoutObject.xPos = xval.intValue + 100 as NSNumber
            case "layoutObjectYPos":
                new_entry.layoutObject.yPos = kvp.value as? NSNumber
            default:
                new_entry.setValue(kvp.value, forKey: key as String)
                
            }
        }
        
        for (old_name, new_name): (String, String) in nameChanges {
            self.searchAndReplaceValues(old_name, newName: new_name, entries: [new_entry])
        }
        
        return new_entry
        
    }
    
    //MARK: Event related
    
    //check if the layout object supplied is an event in this template
    public func isEventAndOnThisTemplate(_ eventObject : LayoutObject, templateObject : LayoutObject) -> Bool {
        return ((templateObject.childLink.array as! [LayoutObject]).contains(eventObject) && eventObject.mainEntry != nil && typeIsEvent(eventObject.mainEntry.type))
    }
    
    public func createNewEventFromTool(_ type : String, templateObject : LayoutObject) -> Entry? {
        //println("Creating event type: " + type)
        let index = templateObject.childLink.count
        return createNewEventFromTool(type, templateObject: templateObject, order: index)
        
    }
    
    
    
    public func moveEvent(_ eventEntry : Entry, inTemplate templateEntry : Entry, toIndex index : Int) {
        
        if let sub_entry = getSubEntry("Events", entry: templateEntry) {
            let string_list = PSStringList(entry: sub_entry, scriptData: self)
            
            if let oldIndex = string_list.indexOfValueWithString(eventEntry.name) {
                string_list.swap(oldIndex, index2: index)
            } else {
                //Todo error
            }
        } else {
            //Todo error
        }
    }
    
    public func moveEvent(_ templateEntry : Entry, fromIndex : Int, toIndex : Int) {
        if let sub_entry = getSubEntry("Events", entry: templateEntry) {
            let string_list = PSStringList(entry: sub_entry, scriptData: self)
            string_list.move(fromIndex, to: toIndex)
        }
    }
    
    public func createNewEventFromTool(_ type : String, templateObject : LayoutObject, order : Int) -> Entry? {
        //println("Creating event type: " + type)
        if let psevent = self.pluginProvider.eventPlugins[type],
            let new_entry = psevent.createObject(self) {
            let event_type_entry = getOrCreateSubEntry("EventType", entry: new_entry, isProperty: true)
            event_type_entry.currentValue = type
            new_entry.layoutObject.icon = getIconForType(new_entry.type)
            
            let sub_entry = getOrCreateSubEntry("Events", entry: templateObject.mainEntry, isProperty: true)
            
            let string_list = PSStringList(entry: sub_entry, scriptData: self)
            
            templateObject.addChildLinkObject(new_entry.layoutObject)
            string_list.insert(new_entry.name, index: order)
            createLinkFrom(templateObject.mainEntry, to:new_entry, withAttribute: "Events")
            PSPositionNewObject(new_entry.layoutObject,scriptData: self)
            return new_entry
        }
        return nil
    }
    
    public func getIconForType(_ type : String) -> NSImage! {
        
        
        for anObject in pluginProvider.eventExtensions {
            if anObject.type == type {
                return anObject.icon as NSImage
            }
        }
        return nil
    }
    
    public func typeIsEvent(_ type : String) -> Bool {
        if eventTypes == nil {
            eventTypes = []
            for anObject in pluginProvider.eventExtensions {
                eventTypes!.append(anObject.type)
            }
        }
        
        for et in eventTypes {
            if type == et { return true }
        }
        return false
    }
    var eventTypes : [String]! = nil
    
    public func getAllEvents() -> [Entry] {
        var eventEntries : [Entry] = []
        let baseEntries = self.getBaseEntries()
        for entry in baseEntries {
            if self.typeIsEvent(entry.type) {
                eventEntries.append(entry)
            }
        }
        return eventEntries
    }

}

//MARK: Archiving functions

//warning only use this to copy attributes, and things which dont have a layout object / section
public func PSAttributeEntryToNSDictionary(_ object : NSManagedObject) -> NSDictionary {
    let attributes = Array(object.entity.attributesByName.keys)
    let relationships = Array(object.entity.relationshipsByName.keys)
    let dict : NSMutableDictionary = [:]
    for at in attributes as [NSString] {
        let val = object.value(forKey: at as String) as! NSObject?
        if let v = val {
            dict.setValue(v, forKey: at as String)
        }
    }
    
    for rel in relationships as [NSString] {
        let val = object.value(forKey: rel as String) as! NSObject?
        //this will be the subentries
        if let set = val as? NSSet {
            let dictSet = NSMutableSet(capacity: set.count)
            for subObject in set as! Set<NSManagedObject> {
                dictSet.add(PSAttributeEntryToNSDictionary(subObject))
            }
            dict.setValue(dictSet, forKey: rel as String)
        } else {
            //all other relationships are not important for attributes
            //if need be extend this class to deal with the one- to one relationships
        }
    }
    
    return dict as NSDictionary
}

public func NSDictionaryToPSAttributeEntry(_ object : NSManagedObject, dict : NSDictionary) {
    let moc = object.managedObjectContext
    for kvp in dict {
        if let subSet = kvp.value as? NSSet {
            let relatedObjects = object.mutableSetValue(forKey: kvp.key as! NSString as String)
            for subDict in subSet.allObjects as! [NSDictionary] {
                //create a new object
                let newEntry = PSCreateEntryFromDictionary(moc!, dict: subDict)
                relatedObjects.add(newEntry)
            }
        } else {
            object.setValue(kvp.value, forKey: kvp.key as! String)
        }
    }
}

public func PSCreateEntryFromDictionary(_ moc : NSManagedObjectContext, dict : NSDictionary) -> Entry {
    let newObject = NSEntityDescription.insertNewObject(forEntityName: "Entry", into: moc) as NSManagedObject
    NSDictionaryToPSAttributeEntry(newObject, dict: dict)
    return newObject as! Entry
}
