//
//  PSFileListBuilderController.swift
//  PsyScopeEditor
//
//  Created by James on 27/05/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSFileListBuilderController : NSObject {
    @IBOutlet var fileListBuilder : PSFileListWindowController!
    @IBOutlet var filePathTextField : NSTextField!
    @IBOutlet var numberOfColumnsTextField : NSTextField!
    @IBOutlet var tableViewController : PSFileListBuilderTableController!
    @IBOutlet var weightsCheckButton : NSButton!
    
    var scriptData : PSScriptData!
    var listEntry : Entry!
    var fileList : PSFileList!

    
    override func awakeFromNib() {
        scriptData = fileListBuilder.scriptData
        listEntry = fileListBuilder.entry
        fileList = PSFileList(entry: listEntry, scriptData: scriptData)
        
        refreshControls()
    }

    func refreshControls() {
        filePathTextField.stringValue = fileList.filePath
        let numberOfColumns = fileList.numberOfColumns
        numberOfColumnsTextField.integerValue = numberOfColumns
        
        
        var previewData : [[String]] = fileList.previewOfContents
        var columnNames : [String] = fileList.getColumnNames()
        
        if let weightsColumn = fileList.weightsColumn {
            weightsCheckButton.state = 1
            columnNames.insert("Weights", at: 0)
            
            if previewData.count > 0 {
                for index in 0...(previewData.count - 1) {
                    var row : [String] = previewData[index]
                    if index < weightsColumn.count {
                        row.insert(String(weightsColumn[index]), at: 0)
                    } else {
                        row.insert("1", at: 0)
                    }
                    previewData[index] = row
                }
            }
            tableViewController.refresh(previewData, columnNames: columnNames, weightsColumn: true)
        } else {
            weightsCheckButton.state = 0
            tableViewController.refresh(previewData, columnNames: columnNames, weightsColumn: false)
        }
    }
    
    func setWeightsValue(_ value : String, row: Int) {
        
        guard let intValue = Int(value) else { return }
        
        let nRows : Int = fileList.previewOfContents.count
        var newWeights : [Int] = []
        var oldWeights : [Int] = []
        if let weightsColumn = fileList.weightsColumn {
            oldWeights = weightsColumn
        }
        
        
        
        if nRows > 0 {
            for index in 0...(nRows - 1) {
                if index == row {
                    newWeights.append(intValue)
                }else if index < oldWeights.count {
                    newWeights.append(oldWeights[index])
                } else {
                    newWeights.append(1)
                }
            }
        }
        
        fileList.weightsColumn = newWeights
    }
    
    
    //MARK: Adjust number of columns
    
    override func controlTextDidEndEditing(_ obj: Notification) {
        if obj.object === numberOfColumnsTextField {
            fileList.numberOfColumns = numberOfColumnsTextField.integerValue
        } else if obj.object === filePathTextField {
            fileList.filePath = filePathTextField.stringValue
        }
        
        refreshControls()
    }
    
    //MARK: Change weights attribute
    
    @IBAction func weightsCheckButtonClicked(_:AnyObject) {
        if weightsCheckButton.state == 1 {
            let numberOfRows = fileList.previewOfContents.count
            fileList.weightsColumn = [Int](repeating: 1, count: numberOfRows)
        } else {
            fileList.weightsColumn = nil
        }
    }
    
}
