//
//  PSAttributeParameter_FileSave.swift
//  PsyScopeEditor
//
//  Created by James on 14/02/2015.
//

import Foundation

//displays a cell with a file save dialog attached to button
public class PSAttributeParameter_FileSave : PSAttributeParameter_Button {
    
    override func clickButton(sender : NSButton) {
        if !scriptData.alertIfNoValidDocumentDirectory() {
            return
        }
        
        //open the file dialog
        let savePanel = NSSavePanel()
        savePanel.title = "Choose any file"
        savePanel.showsResizeIndicator = true
        savePanel.showsHiddenFiles = false
        savePanel.canCreateDirectories = true
        //savePanel.allowedFileTypes = [fileType]
        savePanel.beginSheetModalForWindow(cell.window!, completionHandler: {
            (int_code : Int) -> () in
            if int_code == NSFileHandlingPanelOKButton {
                //relative to files location
                if let url = savePanel.URL, path = url.path {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.setFileName(path)
                    })
                }
            }
        })
    
    }
    
    func setFileName(path : String) {
        var docPath = self.scriptData.documentDirectory()!
        var pspath = PSPath(path, basePath: docPath)
        
        if pspath == "" {
            self.currentValue = "NULL"
        } else {
            self.currentValue = "\"\(pspath)\""
        }
        setButtonTitle()
        self.cell.updateScript()
    }
}