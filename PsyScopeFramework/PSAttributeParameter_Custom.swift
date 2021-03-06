//
//  PSAttributeParameter_Custom.swift
//  PsyScopeEditor
//
//  Created by James on 07/02/2015.
//

import Foundation

//displays a cell with a button that runs code in customButtonAction (e.g. launch a popup)
public class PSAttributeParameter_Custom : PSAttributeParameter_Button {

    public var customButtonAction : ((PSEntryElement,PSScriptData,NSWindow,((PSEntryElement) -> ())?) -> ())!
    
    override func clickButton(sender : NSButton) {
        //open the popup
        customButtonAction(currentValue,scriptData,sender.window!,{
            (cValue : PSEntryElement) -> () in
            self.currentValue = cValue
            self.setButtonTitle()
            self.cell.updateScript()
            })

    }
}