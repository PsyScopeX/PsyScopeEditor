//
//  PSFontAttributePanel.swift
//  PsyScopeEditor
//
//  Created by James on 23/10/2014.
//

import Cocoa


//Note that NSFontPanel doesn't work well with modal windows.  I have tried and failed to get it to work - perhaps there is a way but instead I decided to roll my own in a more similar way to interface builder - James



open class PSFontAttributePopup: PSAttributePopup, NSControlTextEditingDelegate {
    public init(currentValue: PSEntryElement, displayName : String, type : PSFontAttributePopupType, setCurrentValueBlock : ((PSEntryElement) -> ())?) {
        self.type = type
        super.init(nibName: "FontAttribute",bundle: Bundle(for:type(of: self)),currentValue: currentValue, displayName: displayName, setCurrentValueBlock: setCurrentValueBlock )
    }
    
    @IBOutlet var fontManager : NSFontManager!
    var font : NSFont = NSFont.systemFont(ofSize: 12)
    
    @IBOutlet var currentValueLabel : NSTextField!
    @IBOutlet var fontStylePopover : NSPopover!
    
    @IBOutlet var fontFamilyPopUpButton : NSPopUpButton!
    @IBOutlet var boldCheck : NSButton!
    @IBOutlet var italicCheck : NSButton!
    @IBOutlet var underlinedCheck : NSButton!
    @IBOutlet var outlineCheck : NSButton!
    @IBOutlet var shadowCheck : NSButton!
    @IBOutlet var colorWell : NSColorWell!
    @IBOutlet var fontSizeText : NSTextField!
    @IBOutlet var fontSizeStepper : NSStepper!
    
    var fontSize : Int = 12

    @IBAction func changeFontStylePressed(_ sender : AnyObject) {
        fontStylePopover.show(relativeTo: sender.bounds, of: sender as! NSView, preferredEdge: NSRectEdge.maxX)
        
    }
    
    open func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        updateCurrentValue()
        return true
    }
    
    @IBAction func fontButtonPressed(_ sender : AnyObject) {
        updateCurrentValue()
    }
    
    
    func parseCurrentValue() {

        let valueStringList = PSStringListContainer()
        valueStringList.stringValue = self.currentValue.stringValue()
        
        switch (type) {
        case .all:
            if valueStringList.count == 5 {
                fontFamilyPopUpButton.selectItem(withTitle: valueStringList[0])
                fontSizeText.stringValue = valueStringList[1] //use number formatter
                fontSize = fontSizeText.integerValue
                fontSizeStepper.integerValue = fontSize
                colorWell.color = PSColorStringToNSColor(valueStringList[4])
                
                if valueStringList[2].range(of: "Bold") != nil { boldCheck.state = 1 }
                if valueStringList[2].range(of: "Italic") != nil { italicCheck.state = 1 }
                if valueStringList[2].range(of: "Underline") != nil { underlinedCheck.state = 1 }
                if valueStringList[2].range(of: "Outline") != nil { outlineCheck.state = 1 }
                if valueStringList[2].range(of: "Shadow") != nil { shadowCheck.state = 1 }
            }
        
            break
        case .familyOnly:
            if valueStringList.count == 1 {
                fontFamilyPopUpButton.selectItem(withTitle: valueStringList[0])
            }
            break
        case .sizeOnly:
            if valueStringList.count == 1 {
                fontSizeText.stringValue = valueStringList[0] //use number formatter
                fontSize = fontSizeText.integerValue
                fontSizeStepper.integerValue = fontSize
            }
            break
        case .faceOnly:
            if valueStringList.count == 1 {
                if valueStringList[0].range(of: "Bold") != nil { boldCheck.state = 1 }
                if valueStringList[0].range(of: "Italic") != nil { italicCheck.state = 1 }
                if valueStringList[0].range(of: "Underline") != nil { underlinedCheck.state = 1 }
                if valueStringList[0].range(of: "Outline") != nil { outlineCheck.state = 1 }
                if valueStringList[0].range(of: "Shadow") != nil { shadowCheck.state = 1 }
            }
            break
        }
    }
    
    func updateCurrentValue() {
        var cv = ""
        
        switch (type) {
        case .all:
            cv += "\""
            cv += fontFamilyPopUpButton.selectedItem!.title
            cv += "\" "
            cv += "\(fontSize) "
            cv += "\""
            if (boldCheck.state == 1) { cv += "Bold " }
            if (italicCheck.state == 1) { cv += "Italic " }
            if (underlinedCheck.state == 1) { cv += "Underline " }
            if (outlineCheck.state == 1) { cv += "Outline " }
            if (shadowCheck.state == 1) { cv += "Shadow " }
            cv += "\" Copy "
            cv += NSColorToPSColorString(colorWell.color)
            break
        case .familyOnly:
            cv += "\""
            cv += fontFamilyPopUpButton.selectedItem!.title
            cv += "\""
            break
        case .sizeOnly:
            cv += "\(fontSize)"
            break
        case .faceOnly:
            cv += "\""
            if (boldCheck.state == 1) { cv += "Bold " }
            if (italicCheck.state == 1) { cv += "Italic " }
            if (underlinedCheck.state == 1) { cv += "Underline " }
            if (outlineCheck.state == 1) { cv += "Outline " }
            if (shadowCheck.state == 1) { cv += "Shadow " }
            cv += "\""
            break
        }
        let parser = PSEntryValueParser(stringValue: cv)
        
        if parser.foundErrors {
            self.currentValue = .null
        } else {
            self.currentValue = parser.listElement
        }
        currentValueLabel.stringValue = self.currentValue.stringValue()
    }
    
    var type : PSFontAttributePopupType
    override open func awakeFromNib() {

        super.awakeFromNib()
        
        //setup controls
        fontSizeText.isEnabled = false
        fontSizeStepper.isEnabled = false
        fontFamilyPopUpButton.isEnabled = false
        boldCheck.isEnabled = false
        italicCheck.isEnabled = false
        underlinedCheck.isEnabled = false
        outlineCheck.isEnabled = false
        shadowCheck.isEnabled = false
        colorWell.isEnabled = false
        
        switch (type) {
        case .all:
            fontSizeText.isEnabled = true
            fontSizeStepper.isEnabled = true
            fontFamilyPopUpButton.isEnabled = true
            boldCheck.isEnabled = true
            italicCheck.isEnabled = true
            underlinedCheck.isEnabled = true
            outlineCheck.isEnabled = true
            shadowCheck.isEnabled = true
            colorWell.isEnabled = true
            break
        case .familyOnly:
            fontFamilyPopUpButton.isEnabled = true
            break
        case .sizeOnly:
            fontSizeText.isEnabled = true
            fontSizeStepper.isEnabled = true
            break
        case .faceOnly:
            boldCheck.isEnabled = true
            italicCheck.isEnabled = true
            underlinedCheck.isEnabled = true
            outlineCheck.isEnabled = true
            shadowCheck.isEnabled = true
            break
        }
        
        parseCurrentValue()
        currentValueLabel.stringValue = self.currentValue.stringValue()
    }
    
    @IBAction func enteredDone(_: AnyObject) {
        NSColorPanel.shared().close()
        updateCurrentValue()
        closeMyCustomSheet(self)
        NSFontPanel.shared().close()
    }
    
    
    
    
    override open func changeFont(_ sender: Any?) {
        //var newFont = sender?.convertFont(font!)
        //font = newFont!
        //super.changeFont(sender)
        
    }
}
