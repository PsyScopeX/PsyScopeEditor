//
//  PSParagraphStimulusAttribute.swift
//  PsyScopeEditor
//
//  Created by James on 17/12/2014.
//

import Foundation

class PSParagraphStimulusAttribute : PSAttributeGeneric {
    override init() {
        super.init()
        userFriendlyNameString = "Stimulus"
        helpfulDescriptionString = "Paragraph of text to display"
        codeNameString = "Stimulus"
        defaultValueString = PSDefaultConstants.DefaultAttributeValues.PSAttribute_TextEventSpecial
        attributeClass = PSAttributeParameter_Custom.self
        toolsArray = [PSParagraphEvent().type()]
        customAttributeParameterAction = { (before : String, scriptData: PSScriptData, window: NSWindow, setCurrentValueBlock : ((String) -> ())?) -> () in
            var popup = PSParagraphAttributePopup(currentValue: before, setCurrentValueBlock: setCurrentValueBlock)
            popup.showAttributeModalForWindow(window)
            
        }
    }

}

class PSParagraphAttributePopup : PSAttributePopup {
    @IBOutlet var textView : NSTextView!
    
    init(currentValue : String, setCurrentValueBlock : ((String)->())?) {
        var bundle = PSDefaultPluginBundle
        super.init(nibName: "ParagraphDialog", bundle: bundle, currentValue: currentValue, displayName: "Paragraph", setCurrentValueBlock: setCurrentValueBlock)
    }
    
    override func awakeFromNib() {
        textView.string = self.currentValue
    }
    
    override func closeMyCustomSheet(sender: AnyObject) {
        self.currentValue = textView.string!
        super.closeMyCustomSheet(sender)
    }
    
}