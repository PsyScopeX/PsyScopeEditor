//
//  PSAttributeParameter_FontFace.swift
//  PsyScopeEditor
//
//  Created by James on 14/02/2015.
//

import Foundation

public class PSAttributeParameter_FontFace : PSAttributeParameter_Button {
    
    override func clickButton(sender : NSButton) {
        
        let fontpopup = PSFontAttributePopup(currentValue: currentValue, displayName: "Choose Font Face", type: PSFontAttributePopupType.FaceOnly, setCurrentValueBlock: {
        
            (cValue : String) -> () in
            self.currentValue = cValue
            
            if self.currentValue == "" {
                self.currentValue = "NULL"
            }
            self.editButton.title = self.currentValue
            self.cell.updateScript()
        
        })
        fontpopup.showAttributeModalForWindow(cell.window!)
        
    }
}