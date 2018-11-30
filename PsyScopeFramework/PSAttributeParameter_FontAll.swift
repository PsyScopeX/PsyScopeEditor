//
//  PSAttributeParameter_FontAll.swift
//  PsyScopeEditor
//
//  Created by James on 14/02/2015.
//

import Foundation

public class PSAttributeParameter_FontAll : PSAttributeParameter_Button {
    
    override func clickButton(_ sender : NSButton) {
        let fontpopup = PSFontAttributePopup(currentValue: currentValue, displayName: "Choose Font", type: PSFontAttributePopupType.all, setCurrentValueBlock: {
            (cValue : PSEntryElement) -> () in
            
            self.currentValue = cValue
            self.editButton.title = self.currentValue.stringValue()
            self.cell.updateScript()
        })
        fontpopup.showAttributeModalForWindow(cell.window!)
    }
}
