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
        let docPath = self.scriptData.documentDirectory()!

        if let pspath = PSPath(path, basePath: docPath) where pspath != "" {
            self.currentValue = PSGetFirstEntryElementForStringOrNull("\"\(pspath)\"")
        } else {
            self.currentValue = .Null
        }
        setButtonTitle()
        self.cell.updateScript()
    }

}