//
//  PSImportFileAsDialog.swift
//  PsyScopeEditor
//
//  Created by James on 17/02/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

open class PSImportFileAsPopup : PSAttributePopup {
    var scriptData : PSScriptData
    var types : [PSToolInterface] = []
    @IBOutlet var browser : PSImportFileBrowserViewDelegate!
    public init(types : [PSToolInterface], scriptData: PSScriptData, setCurrentValueBlock : ((PSEntryElement)->())?){
        self.types = types
        self.scriptData = scriptData
        super.init(nibName: "ImportFilesAs",bundle: Bundle(for:type(of: self)), currentValue: .null, displayName: "Action", setCurrentValueBlock: setCurrentValueBlock)
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        browser.setPossibleTypes(types)
    }
    
    override open func closeMyCustomSheet(_ sender: AnyObject) {
        //update current values
 
        super.closeMyCustomSheet(sender)
    }
}
