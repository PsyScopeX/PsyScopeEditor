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

    /* deprecated - no longer display help string in tool, now appears in tool tip
    func formatLabel(title : String, body : String) -> NSAttributedString{
        var titleString = NSMutableAttributedString(string: title, attributes: [NSFontAttributeName : PSConstants.Fonts.toolMenuHeader, NSForegroundColorAttributeName : NSColor.blackColor()  ])
        var bodyString = NSAttributedString(string: " - \(body)", attributes: [NSFontAttributeName :PSConstants.Fonts.toolMenuBody,  NSForegroundColorAttributeName : NSColor.blackColor() ])
        
        titleString.appendAttributedString(bodyString)
        return titleString
    }
    */
    
    var psExtension : PSExtension!
    
    override var objectValue : AnyObject? {
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
