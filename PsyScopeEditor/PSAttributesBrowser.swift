//
//  PSAttributesComboBox.swift
//  PsyScopeEditor
//
//  Created by James on 02/08/2014.
//

import Cocoa

let PSPasteboardTypeAttribute : NSString = "psyscope.attribute"

//Handles the attributes browser, and attached combo box
class PSAttributesBrowser: NSObject, NSTableViewDelegate, NSTableViewDataSource, PSEditMenuDelegate, NSPasteboardItemDataProvider {

    //MARK: Outlets
    @IBOutlet var tableView : NSTableView!
    @IBOutlet var mainWindowController : PSMainWindowController!
    @IBOutlet var elementViewerController : PSElementViewerController!
    
    
    //MARK: Variables
    var content : [Entry] = [] //holds currently displayed attributes
    let addAttributeCellIdentifier = "PSAddAttributeCell"
    let genericInterface = PSAttributeGeneric()
    var attributePicker : PSAttributePicker? //holds a reference to last popup to prevent Zombie object
    var copiedAttribute : Entry? //Holds copied attribute
    var canAddAttributes : Bool = false
    var selectionController : PSSelectionController!

    //MARK: AwakeFromNib
    
    override func awakeFromNib()  {
        let anib = NSNib(nibNamed: "AddAttributeCell", bundle: Bundle(for:self.dynamicType))
        tableView.register(anib!, forIdentifier: addAttributeCellIdentifier)
        self.selectionController = mainWindowController.selectionController
    }
    

    
    //MARK: Attributes refresh
    
    func refresh() {
        if let selectedEntry = selectionController.selectedEntry,
         interface = mainWindowController.scriptData.pluginProvider.getInterfaceForType(PSType.FromName(selectedEntry.type))
            where interface.canAddAttributes() == true {
                
            self.canAddAttributes = true
            let entries = selectedEntry.subEntries.array as! [Entry]
            
            
            
            //get only entries who are not properties
            content = entries.filter({
                (entry : Entry) -> Bool in
                return !entry.isProperty.boolValue
                })
            
            content = content.sorted(by: { (s1: Entry, s2: Entry) -> Bool in
                return s1.name < s2.name })
        } else {
            self.canAddAttributes = false
            content = []
        }
        
        tableView.reloadData()
    }
    
    //MARK: Attributes TableView
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if selectionController != nil && selectionController.selectedEntry != nil && self.canAddAttributes == true {
            return content.count + 1 //add attribute button
        } else {
            return 0 //empty for no selected entry
        }
    }
    
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if row < content.count {
            //1. identify attribute type
            var attributeInterface : PSAttributeInterface = genericInterface
            if let interface : PSAttributeInterface = mainWindowController.scriptData.getAttributeInterfaceForAttributeEntry(content[row]) {
                attributeInterface = interface
            }
            
            let attributeParameter = attributeInterface.attributeParameter() as! PSAttributeParameter
            let cell = PSAttributeEntryCellView(entry: content[row], attributeParameter: attributeParameter, interface: genericInterface, scriptData: mainWindowController.scriptData)
            let builder = PSAttributeParameterBuilder(parameter: attributeParameter)
            builder.setupEntryCell(cell)
           
            return cell
        } else {
            //add attribute button
            let new_view  = tableView.make(withIdentifier: addAttributeCellIdentifier, owner: self) as! PSButtonCell
            new_view.action = { (sender : NSButton) -> () in
                self.addAttribute(sender) }
            return new_view
        }
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return PSConstants.Spacing.attributesTableViewRowHeight
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        //show popover
        if row < content.count {
            let view : NSView = tableView.view(atColumn: 0, row: row, makeIfNecessary: true)!
        
            elementViewerController.showForView(view, attributeEntry: content[row])
        
            return true
        } else {
            return false
        }
    }
    
    //MARK: Adding/deleting attributes
    
    @IBAction func addAttribute(_ sender : NSView) { //from add attribute cell button
        
        if let selectedEntry = selectionController.selectedEntry {
            attributePicker = PSAttributePickerEntry(entry: selectedEntry, scriptData: mainWindowController.scriptData)
            attributePicker!.showAttributeWindow(tableView)
        }
    }
    
    func deleteObject(_ sender : AnyObject) {
        let index = tableView.selectedRowIndexes.first
        if index > 0 && index < content.count {
            mainWindowController.scriptData.beginUndoGrouping("Delete Attribute")
            mainWindowController.scriptData.deleteSubEntryFromBaseEntry(content[index].parent, subEntry: content[index])
            mainWindowController.scriptData.endUndoGrouping(true)
        }
        
    }
    
    
    //MARK : Copy/Paste of attributes
    
    func copyObject(_ sender : AnyObject) {
        let index = tableView.selectedRowIndexes.first
        if index > 0 && index < content.count {
            let pasteboardItem = NSPasteboardItem()
            let types = [NSPasteboardTypeString, PSPasteboardTypeAttribute]
            var ok = pasteboardItem.setDataProvider(self, forTypes: types)
            if ok {
                let pasteboard = NSPasteboard.general()
                pasteboard.clearContents()
                ok = pasteboard.writeObjects([pasteboardItem])
            }
            
            if (ok) {
                //here remember what was copied in order to paste it
                copiedAttribute = content[index]
            }
        }
    }
    func pasteObject(_ sender : AnyObject) {
        if let se = selectionController.selectedEntry {
            let pasteboard = NSPasteboard.general()
            let items = pasteboard.readObjects(forClasses: [NSPasteboardItem.self], options: [:]) as! [NSPasteboardItem]
            for item in items {
                if let data = item.data(forType: PSPasteboardTypeAttribute  as String) {
                    let dict = NSKeyedUnarchiver.unarchiveObject(with: data) as! NSDictionary
                    let new_entry = PSCreateEntryFromDictionary(mainWindowController.mainDocument.managedObjectContext!, dict: dict)
                    se.addSubEntriesObject(new_entry)
                }
            }
        }
    }
    
    
    
    func pasteboard(_ pasteboard: NSPasteboard?, item: NSPasteboardItem, provideDataForType type: String) {
        
        guard let pasteboard = pasteboard else { return }
        
        if let ce = copiedAttribute {
            switch (type) {
            case NSPasteboardTypeString:
                let writer = PSScriptWriter(scriptData: mainWindowController.scriptData)
                
                let string = writer.entryToText(ce, level: 1)
                pasteboard.setString(string, forType: NSPasteboardTypeString)
            case PSPasteboardTypeAttribute:
                let dataDictionary = PSAttributeEntryToNSDictionary(ce)
                let archive = NSKeyedArchiver.archivedData(withRootObject: dataDictionary)
                pasteboard.setData(archive, forType: PSPasteboardTypeAttribute as String)
            
            default:
                print("Cannot provide data for type : \(type)")
            }
        }
    }
}


