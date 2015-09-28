//
//  PSTextEventSpecial.swift
//  PsyScopeEditor
//
//  Created by James on 24/10/2014.
//

import Foundation

class PSTextEventSpecial : PSAttributePopup {
    init(currentValue : String, setCurrentValueBlock : ((String)->())?) {
        var bundle = PSDefaultPluginBundle
        super.init(nibName: "TextEventSpecial", bundle: bundle, currentValue: currentValue, displayName: "Text Display Options", setCurrentValueBlock: setCurrentValueBlock)
    }
    

    @IBOutlet var positionOptions : NSPopUpButton!
    @IBOutlet var drawMaskedCheck : NSButton!
    @IBOutlet var clearMaskedCheck : NSButton!
    
    var optionsArray : [String :String] = ["Normal position" : "",
                                       "Follow previous text": "Follow",
                                       "Same place as previous text": "Stay_Put"]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //set up options
        var options : [String] = Array(optionsArray.keys)
        positionOptions.addItemsWithTitles(options)
        
        //parse current value
        var list : PSStringListCachedContainer = PSStringListCachedContainer()
        list.stringValue = currentValue
        if list.contains("Follow") {
            positionOptions.selectItemWithTitle("Follow previous text")
        } else if list.contains("Stay_Put") {
            positionOptions.selectItemWithTitle("Same place as previous text")
        } else {
            positionOptions.selectItemWithTitle("Normal position")
        }
        
        drawMaskedCheck.state = list.contains("Draw_Masked") ? 1 : 0
        clearMaskedCheck.state = list.contains("Clear_Masked") ? 1 : 0
    }
    
    @IBAction func doneButton(sender : AnyObject) {
        print("Done")
        var new_list = PSStringListCachedContainer()
        var pos_option : String = optionsArray[positionOptions.selectedItem!.title]!
        if pos_option != "" { new_list.appendAsString(pos_option) }
        if drawMaskedCheck.state == 1 {
            new_list.appendAsString("Draw_Masked")
        }
        if clearMaskedCheck.state == 1 {
            new_list.appendAsString("Clear_Masked")
        }
        self.currentValue = new_list.stringValue
        closeMyCustomSheet(sender)
    }
}

class PSAttribute_TextEventSpecial : PSAttributeGeneric {
    
    override init() {
        super.init()
        userFriendlyNameString = "Text Display Options"
        helpfulDescriptionString = "Various options for displaying the text dynamically / with masks"
        codeNameString = "Feature"
        defaultValueString = PSDefaultConstants.DefaultAttributeValues.PSAttribute_TextEventSpecial
        attributeClass = PSAttributeParameter_Custom.self
        toolsArray = [PSTextEvent().type()]
        customAttributeParameterAction = { (before : String, scriptData: PSScriptData, window: NSWindow, setCurrentValueBlock : ((String) -> ())?) -> () in
            var popup = PSTextEventSpecial(currentValue: before, setCurrentValueBlock: setCurrentValueBlock)
            popup.showAttributeModalForWindow(window)
            
        }
    }

}