//
//  PSFileListBuilderController.swift
//  PsyScopeEditor
//
//  Created by James on 27/05/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSFileListBuilderController : NSObject {
    @IBOutlet var fileListBuilder : PSFileListBuilder!
    @IBOutlet var filePathTextField : NSTextField!
    @IBOutlet var numberOfColumnsTextField : NSTextField!
    @IBOutlet var tableViewController : PSFileListBuilderTableController!
    //@IBOutlet var weightsCheckButton : NSButton!
    
    var scriptData : PSScriptData!
    var listEntry : Entry!
    var fileList : PSFileList!

    
    override func awakeFromNib() {
        scriptData = fileListBuilder.scriptData
        listEntry = fileListBuilder.listEntry
        fileList = PSFileList(entry: listEntry, scriptData: scriptData)
        
        refreshControls()
    }

    func refreshControls() {
        filePathTextField.stringValue = fileList.filePath
        let numberOfColumns = fileList.numberOfColumns
        numberOfColumnsTextField.integerValue = numberOfColumns
        
        
        let previewData = fileList.previewOfContents
        let columnNames : [String] = fileList.getColumnNames()
        
        tableViewController.refresh(previewData, columnNames: columnNames)
        
    }
    
    
    //MARK: Adjust number of columns
    
    override func controlTextDidEndEditing(obj: NSNotification) {
        if obj.object === numberOfColumnsTextField {
            fileList.numberOfColumns = numberOfColumnsTextField.integerValue
        } else if obj.object === filePathTextField {
            fileList.filePath = filePathTextField.stringValue
        }
        
        refreshControls()
    }
    
}