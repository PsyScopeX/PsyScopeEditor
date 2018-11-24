//
//  PSAttributeParameter_FontFace.swift
//  PsyScopeEditor
//
//  Created by James on 14/02/2015.
//

import Foundation

open class PSAttributeParameter_FontFace : PSAttributeParameter_Button {
    
    override func clickButton(_ sender : NSButton) {
        
        let fontpopup = PSFontAttributePopup(currentValue: currentValue, displayName: "Choose Font Face", type: PSFontAttributePopupType.faceOnly, setCurrentValueBlock: {
        
            (cValue : PSEntryElement) -> () in
            self.currentValue = cValue
            
            self.editButton.title = self.currentValue.stringValue()
            self.cell.updateScript()
        
        })
        fontpopup.showAttributeModalForWindow(cell.window!)
        
    }
}
