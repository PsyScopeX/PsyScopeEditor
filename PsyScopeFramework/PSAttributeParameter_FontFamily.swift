//
//  PSAttributeParameter_FontFamily.swift
//  PsyScopeEditor
//
//  Created by James on 14/02/2015.
//

import Foundation

public class PSAttributeParameter_FontFamily : PSAttributeParameter_Button {
    
    override func clickButton(_ sender : NSButton) {
        
        let fontpopup = PSFontAttributePopup(currentValue: currentValue, displayName: "Choose Font Family", type: PSFontAttributePopupType.familyOnly, setCurrentValueBlock: {
            (cValue : PSEntryElement) -> () in
            self.currentValue = cValue
            self.editButton.title = self.currentValue.stringValue()
            self.cell.updateScript()
        })
        fontpopup.showAttributeModalForWindow(cell.window!)
    }
}
