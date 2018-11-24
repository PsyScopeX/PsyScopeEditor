//
//  PSAttributeParameter_File.swift
//  PsyScopeEditor
//
//  Created by James on 14/02/2015.
//

import Foundation


//displays a cell with a file open dialog attached to button
open class PSAttributeParameter_FileOpen : PSAttributeParameter_Button {
    
    override func clickButton(_ sender : NSButton) {
        
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
        openPanel.beginSheetModal(for: self.cell.window!, completionHandler: {
            (int_code : Int) -> () in
            if int_code == NSFileHandlingPanelOKButton {
                //relative to files location
                if let url = openPanel.url, path = url.path {
                    DispatchQueue.main.async(execute: {
                        self.setFileName(path)
                    })
                }
                
            }
        })
    }
    
    func setFileName(_ path : String) {
        let docPath = self.scriptData.documentDirectory()!

        if let pspath = PSPath(path, basePath: docPath) where pspath != "" {
            self.currentValue = PSGetFirstEntryElementForStringOrNull("\"\(pspath)\"")
        } else {
            self.currentValue = .null
        }
        setButtonTitle()
        self.cell.updateScript()
    }

}
