//
//  PSImportFileAsDialog.swift
//  PsyScopeEditor
//
//  Created by James on 17/02/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

public class PSImportFileAsPopup : PSAttributePopup {
    var scriptData : PSScriptData
    var types : [PSToolInterface] = []
    @IBOutlet var browser : PSImportFileBrowserViewDelegate!
    public init(types : [PSToolInterface], scriptData: PSScriptData, setCurrentValueBlock : ((String)->())?){
        self.types = types
        self.scriptData = scriptData
        super.init(nibName: "ImportFilesAs",bundle: NSBundle(forClass:self.dynamicType), currentValue: "", displayName: "Action", setCurrentValueBlock: setCurrentValueBlock)
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        browser.setPossibleTypes(types)
    }
    
    override public func closeMyCustomSheet(sender: AnyObject) {
        //update current values
 
        super.closeMyCustomSheet(sender)
    }
}