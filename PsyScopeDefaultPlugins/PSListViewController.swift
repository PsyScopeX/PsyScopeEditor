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
        case fileType
        case normalType
    }
    
    var firstParse : Bool = false
    var listType : PSListType = PSListType.normalType
    
    init(entry : Entry, scriptData : PSScriptData) {
        let bundle = Bundle(for:type(of: self))
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
    
    func control(_ controlShouldEndEditing: PSEntryValueController) -> Bool {
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
            listType = .fileType
            typePopup.selectItem(withTitle: "File list")
            fileText.isEnabled = true
            fileButton.isEnabled = true
            fileText.stringValue = listFile.currentValue
        } else {
            listType = .normalType
            typePopup.selectItem(withTitle: "Regular list")
            fileText.isEnabled = false
            fileButton.isEnabled = false
            fileText.stringValue = ""
        }
        
        //get any existing window controllers associated with entry
        let exisitingWindowControllers = scriptData.getWindowControllersAssociatedWithEntry(self.entry)
        
        //close any windows if list type has changed and is no longer valid
        for exisitingWindowController in exisitingWindowControllers {
            guard let nibName = exisitingWindowController.windowNibName else { continue }
            
            let validListBuilder = nibName == "ListBuilder" && listType == .normalType
            let validFileListBuilder = nibName == "FileListBuilder" && listType == .fileType
            
            if !(validListBuilder || validFileListBuilder) {
                exisitingWindowController.close()
            }
        }
        
        //determine rough order
        let order = scriptData.propertyValue("AccessType", entry: entry, defaultValue: "Sequential")
        if order.lowercased() == "rrandom" {
            orderPopup.selectItem(withTitle: "Random with replacement")
        } else if order.lowercased() == "random" {
            orderPopup.selectItem(withTitle: "Random")
        } else {
            orderPopup.selectItem(withTitle: "Sequential")
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
    
    @IBAction func fileButtonClicked(_ sender : NSButton) {
        let openPanel = NSOpenPanel()
        openPanel.title = "Choose any file"
        openPanel.showsResizeIndicator = true
        openPanel.showsHiddenFiles = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = true
        openPanel.allowsMultipleSelection = false
        //openPanel.allowedFileTypes = [fileType]
        openPanel.beginSheetModal(for: sender.window!, completionHandler: {
            (int_code : NSApplication.ModalResponse) -> () in
            if int_code == .OK {
                //relative to files location
                let path : NSString = openPanel.url!.path as NSString
                self.scriptData.beginUndoGrouping("Change List File")
                let fileList = PSFileList(entry: self.entry, scriptData: self.scriptData)
                fileList.filePath = path as String
                self.scriptData.endUndoGrouping(true)
                
            }
            return
        })

    }
    
    @IBAction func listControlChanged(_ sender : AnyObject) {
        updateEntry()
    }
    
    override func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
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
    
    @IBAction func editObjectsButton(_ sender : AnyObject) {
        
        //first get any existing window controllers associated with entry
        let exisitingWindowControllers = scriptData.getWindowControllersAssociatedWithEntry(self.entry)
        
        //make these front if they exist and are valid, otherwise close
        var foundExistingWindowController = false
        
        for exisitingWindowController in exisitingWindowControllers {
            guard let nibName = exisitingWindowController.windowNibName else { continue }
            
            let validListBuilder = nibName == "ListBuilder" && listType == .normalType
            let validFileListBuilder = nibName == "FileListBuilder" && listType == .fileType
            
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
        if listType == .normalType {
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
