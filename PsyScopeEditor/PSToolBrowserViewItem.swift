//
//  PSToolBrowserViewItem.swift
//  PsyScopeEditor
//
//  Created by James on 23/09/2014.
//

import Cocoa

class PSToolBrowserViewItem: NSTableCellView {

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    var psExtension : PSExtension!
    
    override var objectValue : Any? {
        set {
            if let pse = newValue as? PSExtension {
                self.imageView!.image = pse.icon
                self.textField!.stringValue = pse.type
                self.textField!.toolTip = pse.helpString
                self.imageView!.toolTip = pse.helpString
                self.psExtension = pse
            }
        }
        
        get {
            return psExtension
        }
    }
}
