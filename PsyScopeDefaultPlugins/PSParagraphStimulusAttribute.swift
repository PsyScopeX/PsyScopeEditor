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
        customAttributeParameterAction = { (before : PSEntryElement, scriptData: PSScriptData, window: NSWindow, setCurrentValueBlock : ((PSEntryElement) -> ())?) -> () in
            let popup = PSParagraphAttributePopup(currentValue: before, setCurrentValueBlock: setCurrentValueBlock)
            popup.showAttributeModalForWindow(window)
            
        }
    }

}

class PSParagraphAttributePopup : PSAttributePopup {
    @IBOutlet var textView : NSTextView!
    
    init(currentValue : PSEntryElement, setCurrentValueBlock : ((PSEntryElement)->())?) {
        super.init(nibName: "ParagraphDialog", bundle: PSDefaultPluginBundle, currentValue: currentValue, displayName: "Paragraph", setCurrentValueBlock: setCurrentValueBlock)
    }
    
    override func awakeFromNib() {
        textView.string = self.currentValue.stringValue()
    }
    
    @IBAction override func closeMyCustomSheet(sender: AnyObject) {
        self.currentValue = PSGetListElementForString(textView.string!)
        super.closeMyCustomSheet(self)
    }
    
}