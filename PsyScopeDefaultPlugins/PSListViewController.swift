//
//  PSListViewControlller.swift
//  PsyScopeEditor
//
//  Created by James on 17/09/2014.
//

import Foundation



class PSListViewController : PSToolPropertyController, NSWindowDelegate, PSEntryValueControllerDelegate {
    
    @IBOutlet var typePopup : NSPopUpButton!
    @IBOutlet var orderPopup : NSPopUpButton!
    @IBOutlet var offsetText : NSTextField!
    @IBOutlet var gripText : NSTextField!
    @IBOutlet var fileText : PSEntryValueTextField_Path!
    @IBOutlet var fileButton : NSButton!
    @IBOutlet var editListButton : NSButton!
    
    enum PSListType {
        case FileType
        case NormalType
    }
    
    var firstParse : Bool = false
    var listType : PSListType = PSListType.NormalType
    
    init(entry : Entry, scriptData : PSScriptData) {
        let bundle = NSBundle(forClass:self.dynamicType)
        super.init(nibName: "ListView", bundle: bundle, entry: entry, scriptData: scriptData)
        storedDoubleClickAction = { () in
            self.editObjectsButton(self)
            return
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if !firstParse {
            parseList()
        }
        
        
    }
    
    func control(controlShouldEndEditing: PSEntryValueController) -> Bool {
        updateEntry()
        return true
    }
    
    func getScriptData() -> PSScriptData {
        return self.scriptData
    }
    
    override func refresh() {
        super.refresh()
        parseList()
    }
    
    func parseList() {
        //determine type of list
        if let listFile = scriptData.getSubEntry("ListFile", entry: entry) {
            listType = .FileType
            typePopup.selectItemWithTitle("File list")
            fileText.enabled = true
            fileButton.enabled = true
            fileText.stringValue = listFile.currentValue
        } else {
            listType = .NormalType
            typePopup.selectItemWithTitle("Regular list")
            fileText.enabled = false
            fileButton.enabled = false
            fileText.stringValue = ""
        }
        
        //get any existing window controllers associated with entry
        let exisitingWindowControllers = scriptData.getWindowControllersAssociatedWithEntry(self.entry)
        
        //close any windows if list type has changed and is no longer valid
        for exisitingWindowController in exisitingWindowControllers {
            guard let nibName = exisitingWindowController.windowNibName else { continue }
            
            let validListBuilder = nibName == "ListBuilder" && listType == .NormalType
            let validFileListBuilder = nibName == "FileListBuilder" && listType == .FileType
            
            if !(validListBuilder || validFileListBuilder) {
                exisitingWindowController.close()
            }
        }
        
        //determine rough order
        let order = scriptData.propertyValue("AccessType", entry: entry, defaultValue: "Sequential")
        if order.lowercaseString == "rrandom" {
            orderPopup.selectItemWithTitle("Random with replacement")
        } else if order.lowercaseString == "random" {
            orderPopup.selectItemWithTitle("Random")
        } else {
            orderPopup.selectItemWithTitle("Sequential")
        }
        
        
        //determine grip
        if let val = Int(scriptData.propertyValue("Grip", entry: entry, defaultValue: "1")) {
            gripText.integerValue = val
        } else {
            gripText.integerValue = 1
        }
        
        
        //determine offset
        if let val = Int(scriptData.propertyValue("Offset", entry: entry, defaultValue: "0")) {
            offsetText.integerValue = val
        } else {
            offsetText.integerValue = 1
        }
        
    }
    
    @IBAction func fileButtonClicked(sender : NSButton) {
        let openPanel = NSOpenPanel()
        openPanel.title = "Choose any file"
        openPanel.showsResizeIndicator = true
        openPanel.showsHiddenFiles = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = true
        openPanel.allowsMultipleSelection = false
        //openPanel.allowedFileTypes = [fileType]
        openPanel.beginSheetModalForWindow(sender.window!, completionHandler: {
            (int_code : Int) -> () in
            if int_code == NSFileHandlingPanelOKButton {
                //relative to files location
                let path : NSString = openPanel.URL!.path!
                self.scriptData.beginUndoGrouping("Change List File")
                let fileList = PSFileList(entry: self.entry, scriptData: self.scriptData)
                fileList.filePath = path as String
                self.scriptData.endUndoGrouping(true)
                
            }
            return
        })

    }
    
    @IBAction func listControlChanged(sender : AnyObject) {
        updateEntry()
    }
    
    override func control(control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        updateEntry()
        return super.control(control, textShouldEndEditing: fieldEditor)
    }
    
    func updateEntry() {
        
        
        // update list type
        switch(typePopup.selectedItem!.tag) {
        case 0: //regular
            //is it changing
            if let _ = scriptData.getSubEntry("ListFile", entry: entry) {
                scriptData.deleteNamedSubEntryFromParentEntry(entry, name: "ListFile")
                scriptData.deleteNamedSubEntryFromParentEntry(entry, name: "NumberOfColumnsInFile")
                scriptData.getOrCreateSubEntry("Levels", entry: entry, isProperty: true).currentValue = ""
            }
            break
        case 1: //file
            //is it changing
            let fileList = PSFileList(entry: entry, scriptData: scriptData)
            fileList.setupDefaultSubEntries()
            fileList.filePath = fileText.stringValue
            break
        default:
            break
        }
        
        var access_value : String = ""
        switch(orderPopup.selectedItem!.tag) {
        case 0:
            access_value = "Sequential"
            break
        case 1:
            access_value = "Random"
            break
        case 2:
            access_value = "RRandom"
            break
        default:
            access_value = "Sequential"
            break
        }
        
        scriptData.propertyUpdate(PSListTool.Properties.AccessType, entry: entry, currentValue: access_value)
        scriptData.propertyUpdate(PSListTool.Properties.Grip, entry: entry, currentValue: gripText.stringValue)
        scriptData.propertyUpdate(PSListTool.Properties.Offset, entry: entry, currentValue: offsetText.stringValue)
        
    }
    
    @IBAction func editObjectsButton(sender : AnyObject) {
        
        //first get any existing window controllers associated with entry
        let exisitingWindowControllers = scriptData.getWindowControllersAssociatedWithEntry(self.entry)
        
        //make these front if they exist and are valid, otherwise close
        var foundExistingWindowController = false
        
        for exisitingWindowController in exisitingWindowControllers {
            guard let nibName = exisitingWindowController.windowNibName else { continue }
            
            let validListBuilder = nibName == "ListBuilder" && listType == .NormalType
            let validFileListBuilder = nibName == "FileListBuilder" && listType == .FileType
            
            if validListBuilder || validFileListBuilder {
                exisitingWindowController.window!.makeKeyAndOrderFront(sender)
                foundExistingWindowController = true
            } else {
                exisitingWindowController.close()
            }
        }
        
        //no need to open new ones if already have one open
        if foundExistingWindowController { return }
        
        //open as correct type
        if listType == .NormalType {
            let listBuilder = PSListBuilderWindowController(windowNibName: "ListBuilder")
            listBuilder.setupWithEntryAndAddToDocument(self.entry, scriptData: self.scriptData)
            listBuilder.showWindow(self)
        } else {
            let listFileBuilder = PSFileListWindowController(windowNibName: "FileListBuilder")
            listFileBuilder.setupWithEntryAndAddToDocument(self.entry, scriptData: self.scriptData)
            listFileBuilder.showWindow(self)
        }
    }
}