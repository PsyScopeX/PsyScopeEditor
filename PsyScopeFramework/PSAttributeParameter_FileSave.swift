//
//  PSAttributeParameter_FileSave.swift
//  PsyScopeEditor
//
//  Created by James on 14/02/2015.
//

import Foundation

//displays a cell with a file save dialog attached to button
public class PSAttributeParameter_FileSave : PSAttributeParameter_Button {
    
    override func clickButton(_ sender : NSButton) {
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
        savePanel.beginSheetModal(for: cell.window!, completionHandler: {
            (int_code : NSApplication.ModalResponse) -> () in
            if int_code == .OK {
                //relative to files location
                if let url = savePanel.url {
                    DispatchQueue.main.async(execute: {
                        self.setFileName(url.path)
                    })
                }
            }
        })
    
    }
    
    func setFileName(_ path : String) {
        let docPath = self.scriptData.documentDirectory()!
        guard let pspath = PSPath(path, basePath: docPath) else {
            print("Illegal file name")
            return
        }
        
        if pspath == "" {
            self.currentValue = .null
        } else {
            self.currentValue = PSGetFirstEntryElementForStringOrNull("\"\(pspath)\"")
        }
        setButtonTitle()
        self.cell.updateScript()
    }
}
