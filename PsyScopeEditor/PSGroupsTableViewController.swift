//
//  PSGroupsTableViewController.swift
//  PsyScopeEditor
//
//  Created by James on 09/11/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

class PSGroupsTableViewController : NSObject, NSTableViewDataSource, NSTableViewDelegate {
        
    @IBOutlet var tableView : NSTableView!
    @IBOutlet var tableViewButtons : NSSegmentedControl!

    var tableEntry : Entry!
    var stringList : PSStringList!
    var scriptData : PSScriptData!
    let dragReorderType = "PSToolTablePropertyControllerType"


    func setup(_ scriptData : PSScriptData) {
        self.scriptData = scriptData
    }

    override func awakeFromNib() {
        tableView.registerForDraggedTypes(convertToNSPasteboardPasteboardTypeArray([dragReorderType]))
    }



    func numberOfRows(in tableView: NSTableView) -> Int {
        if stringList != nil {
            return stringList.count
        } else {
            return 0
        }
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if stringList != nil && row < stringList.stringListRawUnstripped.count {
            return stringList.stringListRawUnstripped[row]
        } else {
            return ""
        }
    }

    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
        let pboard = info.draggingPasteboard
        if let data = pboard.data(forType: convertToNSPasteboardPasteboardType(dragReorderType)),
            let rowIndexes : IndexSet = NSKeyedUnarchiver.unarchiveObject(with: data) as? IndexSet {
                stringList.move(rowIndexes.first!, to: row)
                return true
        }
        return false
    }

    func tableView(_ tableView: NSTableView, writeRowsWith rowIndexes: IndexSet, to pboard: NSPasteboard) -> Bool {
        // Copy the row numbers to the pasteboard.
        let data = NSKeyedArchiver.archivedData(withRootObject: rowIndexes)
        pboard.declareTypes(convertToNSPasteboardPasteboardTypeArray([dragReorderType]), owner: self)
        pboard.setData(data, forType: convertToNSPasteboardPasteboardType(dragReorderType))
        return true
    }

    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        print("\(row) - \(dropOperation.rawValue)")
        if dropOperation == .above {
            return NSDragOperation.move
        } else {
            return NSDragOperation()
        }
    }

    func tableView(_ tableView: NSTableView, shouldEdit tableColumn: NSTableColumn?, row: Int) -> Bool {
        return true
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        if row < stringList.count {
            if let entry = scriptData.getBaseEntry(stringList.stringListRawUnstripped[row]) {
                scriptData.selectionInterface.selectEntry(entry)
            }
        }
        return true
    }
    

    func refreshView() {
        if let experimentEntry = scriptData.getMainExperimentEntryIfItExists(),
            let groupsSubEntry = scriptData.getSubEntry("Groups", entry: experimentEntry) {

            stringList = PSStringList(entry: groupsSubEntry, scriptData: scriptData)
        } else {
            stringList = nil
        }
        
        tableView.reloadData()
    }


    @IBAction func elementButtons(_ sender : AnyObject) {
        switch (tableViewButtons.selectedSegment) {
        case 0:
            addElement()
        case 1:
            removeElement()
        default:
            break
        }
    }

    func addElement() {
        scriptData.beginUndoGrouping("Add New Group")
        var success = false
        if let experimentEntry = scriptData.getMainExperimentEntryIfItExists(),
            let newGroup = scriptData.createNewObjectFromTool(PSType.Group)  {
            
            scriptData.createLinkFrom(experimentEntry, to: newGroup, withAttribute: "Groups")
            PSPositionNewObject(newGroup.layoutObject, scriptData: scriptData) //reposition now link has been made
            success = true
        }
        scriptData.endUndoGrouping(success)
    }

    var selectedElement : String {
        get {
            if stringList != nil {
                let selected_row = tableView.selectedRow
                if stringList.count > 0 && selected_row < 0 {
                    return stringList.stringListRawUnstripped[0]
                }
                if selected_row < stringList.count && selected_row > 0 {
                    return stringList.stringListRawUnstripped[selected_row]
                }
            }
            return ""
        }
    }

    func removeElement() {
        scriptData.beginUndoGrouping("Delete Group")
        if let deleteGroup = scriptData.getBaseEntry(selectedElement) {
            scriptData.deleteMainEntry(deleteGroup)
        }
        scriptData.endUndoGrouping()
    }
    
}

