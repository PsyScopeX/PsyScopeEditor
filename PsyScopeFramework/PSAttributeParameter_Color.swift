//
//  PSAttributeParameter_Color.swift
//  PsyScopeEditor
//
//  Created by James on 14/02/2015.
//

import Foundation

public class PSAttributeParameter_Color : PSAttributeParameter_Button {
    
    override func clickButton(sender : NSButton) {
        let colorpopup = PSColorAttributePopup(currentValue: currentValue, displayName: "Choose Color", setCurrentValueBlock: {
            (cValue : String) -> () in
            self.currentValue = cValue
            
            if self.currentValue == "" {
                self.currentValue = "NULL"
            }
            self.editButton.title = self.currentValue
            self.cell.updateScript()
        })
        colorpopup.showAttributeModalForWindow(cell.window!)
        
    }
}