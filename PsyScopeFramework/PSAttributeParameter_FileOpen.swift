//
//  PSAttributeParameter_File.swift
//  PsyScopeEditor
//
//  Created by James on 14/02/2015.
//

import Foundation


//displays a cell with a file open dialog attached to button
public class PSAttributeParameter_FileOpen : PSAttributeParameter_Button {
    
    override func clickButton(sender : NSButton) {
        
        if !scriptData.alertIfNoValidDocumentDirectory() {
            return
        }
        
        //open the file dialog
        let openPanel = NSOpenPanel()
        openPanel.title = "Choose any file"
        openPanel.showsResizeIndicator = true
        openPanel.showsHiddenFiles = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = true
        openPanel.allowsMultipleSelection = false
        //openPanel.allowedFileTypes = [fileType]
        openPanel.beginSheetModalForWindow(self.cell.window!, completionHandler: {
            (int_code : Int) -> () in
            if int_code == NSFileHandlingPanelOKButton {
                //relative to files location
                if let url = openPanel.URL, path = url.path {
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