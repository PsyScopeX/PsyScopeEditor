//
//  PSAttributeParameter_Color.swift
//  PsyScopeEditor
//
//  Created by James on 14/02/2015.
//

import Foundation

public class PSAttributeParameter_Color : PSAttributeParameter_Button {
    
    override func clickButton(_ sender : NSButton) {
        let colorpopup = PSColorAttributePopup(currentValue: currentValue, displayName: "Choose Color", setCurrentValueBlock: {
            (cValue : PSEntryElement) -> () in
            self.currentValue = cValue
            self.editButton.title = self.currentValue.stringValue()
            self.cell.updateScript()
        })
        colorpopup.showAttributeModalForWindow(cell.window!)
        
    }
}
