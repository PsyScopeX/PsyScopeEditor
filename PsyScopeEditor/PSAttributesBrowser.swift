//
//  PSAttributesComboBox.swift
//  PsyScopeEditor
//
//  Created by James on 02/08/2014.
//

import Cocoa

let PSPasteboardTypeAttribute : NSString = "psyscope.attribute"

//Handles the attributes browser, and attached combo box
class PSAttributesBrowser: NSObject, NSComboBoxDataSource, NSComboBoxDelegate, NSTableViewDelegate, NSTableViewDataSource, PSEditMenuDelegate, NSPasteboardItemDataProvider {

    //MARK: Outlets
    
    @IBOutlet var comboBox : NSComboBox!
    @IBOutlet var selectionController : PSSelectionController!
    @IBOutlet var tableView : NSTableView!
    @IBOutlet var document : Document!
    @IBOutlet var elementViewerController : PSElementViewerController!
    
    
    //MARK: Variables
    
    var items : [String] = [] //holds entries to switch between
    var content : [Entry] = [] //holds currently displayed attributes
    var selectedEntry : Entry?
    let addAttributeCellIdentifier = "PSAddAttributeCell"
    let genericInterface = PSAttributeGeneric()
    var attributePicker : PSAttributePicker? //holds a reference to last popup to prevent Zombie object
    var copiedAttribute : Entry? //Holds copied attribute

    //MARK: AwakeFromNib
    
    override func awakeFromNib()  {
        let anib = NSNib(nibNamed: "AddAttributeCell", bundle: NSBundle(forClass:self.dynamicType))
        tableView.registerNib(anib!, forIdentifier: addAttributeCellIdentifier)
    }
    
    //MARK: Combobox methods
    
    func numberOfItemsInComboBox(aComboBox: NSComboBox) -> Int {
        return items.count
    }
    
    func comboBox(aComboBox: NSComboBox, objectValueForItemAtIndex index: Int) -> AnyObject {
        if (index >= items.count || index < 0) {
            return ""
        } else {
            return items[index]
        }
    }

    func comboBox(aComboBox: NSComboBox, indexOfItemWithStringValue string: String) -> Int {
        if let r = items.indexOf(string) {
            return r
        }
        return -1
    }
    func comboBoxSelectionDidChange(notification: NSNotification) {
        selectionController.selectObjectForEntryNamed(getSelectedComboBoxItem())
    }
    
    func getSelectedComboBoxItem() -> String {
        if (comboBox.indexOfSelectedItem >= items.count || comboBox.indexOfSelectedItem < 0) {
            return ""
        } else {
            return items[comboBox.indexOfSelectedItem]
        }
    }
    
    //update items but don't change selected
    func updateItems() {
        let entries = document.scriptData.getBaseEntriesWithLayoutObjects()
        let new_items = document.scriptData.getNamesOfEntries(entries)
        items = new_items.sort({ (s1: String, s2: String) -> Bool in
            return s1 < s2 })
        
        
        comboBox.reloadData()
        
        if let selectedEntry = selectionController.getSelectedEntry() {
            let currentSelectedItem : String = selectedEntry.name
            selectItem(currentSelectedItem)
        }
    }
    
    //MARK: Attributes refresh
    
    func refresh() {
        if let selectedEntry = selectedEntry {
            let entries = selectedEntry.subEntries.array as! [Entry]
            
            //get only entries who are not properties
            content = entries.filter({
                (entry : Entry) -> Bool in
                return !entry.isProperty.boolValue
                })
            
            content = content.sort({ (s1: Entry, s2: Entry) -> Bool in
                return s1.name < s2.name })
        } else {
            content = []
        }
        
        tableView.reloadData()
    }
    
    //MARK: Selection
    
    func entrySelected(entry : Entry?) {
        self.selectedEntry = entry
        refresh()
    }
    
    //selects item in combobox, no delegate fired
    func selectItem(item : String) {
        if let index = items.indexOf(item) {
            comboBox.setDelegate(nil) //prevent firing selection did change
            comboBox.selectItemAtIndex(index)
            comboBox.setDelegate(self)
        } else {
            comboBox.setDelegate(nil) //prevent firing selection did change
            comboBox.stringValue = ""
            comboBox.setDelegate(self)
        }
    }
    
    //MARK: Attributes TableView
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        if selectedEntry != nil {
            return content.count + 1 //add attribute button
        } else {
            return 0 //empty for no selected entry
        }
    }
    
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if row < content.count {
            //1. identify attribute type
            var attributeInterface : PSAttributeInterface = genericInterface
            if let interface : PSAttributeInterface = document.scriptData.getAttributeInterfaceForAttributeEntry(content[row]) {
                attributeInterface = interface
            }
            
            let attributeParameter = attributeInterface.attributeParameter() as! PSAttributeParameter
            let cell = PSAttributeEntryCellView(entry: content[row], attributeParameter: attributeParameter, interface: genericInterface, scriptData: document.scriptData)
            let builder = PSAttributeParameterBuilder(parameter: attributeParameter)
            builder.setupEntryCell(cell)
           
            return cell
        } else {
            //add condition button
            let new_view  = tableView.makeViewWithIdentifier(addAttributeCellIdentifier, owner: self) as! PSButtonCell
            new_view.action = { (sender : NSButton) -> () in
                self.addAttribute(sender) }
            return new_view
        }
    }
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return PSConstants.Spacing.attributesTableViewRowHeight
    }
    
    func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        //show popover
        if row < content.count {
            let view : NSView = tableView.viewAtColumn(0, row: row, makeIfNecessary: true)!
        
            elementViewerController.showForView(view, attributeEntry: content[row])
        
            return true
        } else {
            return false
        }
    }
    
    //MARK: Adding/deleting attributes
    
    @IBAction func addAttribute(sender : NSView) { //from add attribute cell button
        
        if let selectedEntry = selectedEntry {
            attributePicker = PSAttributePickerEntry(entry: selectedEntry, scriptData: document.scriptData)
            attributePicker!.showAttributeWindow(tableView)
        }
    }
    
    func deleteObject(sender : AnyObject) {
        let index = tableView.selectedRowIndexes.firstIndex
        if index > 0 && index < content.count {
            document.scriptData.beginUndoGrouping("Delete Attribute")
            document.scriptData.deleteSubEntryFromBaseEntry(content[index].parentEntry, subEntry: content[index])
            document.scriptData.endUndoGrouping(true)
        }
        
    }
    
    
    //MARK : Copy/Paste of attributes
    
    func copyObject(sender : AnyObject) {
        let index = tableView.selectedRowIndexes.firstIndex
        if index > 0 && index < content.count {
            let pasteboardItem = NSPasteboardItem()
            let types = [NSPasteboardTypeString, PSPasteboardTypeAttribute]
            var ok = pasteboardItem.setDataProvider(self, forTypes: types)
            if ok {
                let pasteboard = NSPasteboard.generalPasteboard()
                pasteboard.clearContents()
                ok = pasteboard.writeObjects([pasteboardItem])
            }
            
            if (ok) {
                //here remember what was copied in order to paste it
                copiedAttribute = content[index]
            }
        }
    }
    func pasteObject(sender : AnyObject) {
        if let se = selectedEntry {
            let pasteboard = NSPasteboard.generalPasteboard()
            let items = pasteboard.readObjectsForClasses([NSPasteboardItem.self], options: [:]) as! [NSPasteboardItem]
            for item in items {
                if let data = item.dataForType(PSPasteboardTypeAttribute  as String) {
                    let dict = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! NSDictionary
                    let new_entry = PSCreateEntryFromDictionary(document.managedObjectContext, dict: dict)
                    se.addSubEntriesObject(new_entry)
                }
            }
        }
    }
    
    
    
    func pasteboard(pasteboard: NSPasteboard!, item: NSPasteboardItem!, provideDataForType type: String!) {
        if let ce = copiedAttribute {
            switch (type) {
            case NSPasteboardTypeString:
                let writer = PSScriptWriter(scriptData: document.scriptData)
                
                let string = writer.entryToText(ce, level: 1)
                pasteboard.setString(string, forType: NSPasteboardTypeString)
            case PSPasteboardTypeAttribute as String:
                let dataDictionary = PSAttributeEntryToNSDictionary(ce)
                let archive = NSKeyedArchiver.archivedDataWithRootObject(dataDictionary)
                pasteboard.setData(archive, forType: PSPasteboardTypeAttribute as String)
            
            default:
                print("Cannot provide data for type : \(type)")
            }
        }
    }
}


