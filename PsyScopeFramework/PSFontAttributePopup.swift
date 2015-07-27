//
//  PSFontAttributePanel.swift
//  PsyScopeEditor
//
//  Created by James on 23/10/2014.
//

import Cocoa


//Note that NSFontPanel doesn't work well with modal windows.  I have tried and failed to get it to work - perhaps there is a way but instead I decided to roll my own in a more similar way to interface builder - James



public class PSFontAttributePopup: PSAttributePopup, NSControlTextEditingDelegate {
    public init(currentValue: String, displayName : String, type : PSFontAttributePopupType, setCurrentValueBlock : ((String) -> ())?) {
        self.type = type
        super.init(nibName: "FontAttribute",bundle: NSBundle(forClass:self.dynamicType),currentValue: currentValue, displayName: displayName, setCurrentValueBlock: setCurrentValueBlock )
    }
    
    @IBOutlet var fontManager : NSFontManager!
    var font : NSFont = NSFont.systemFontOfSize(12)
    
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

    @IBAction func changeFontStylePressed(sender : AnyObject) {
        fontStylePopover.showRelativeToRect(sender.bounds, ofView: sender as! NSView, preferredEdge: NSRectEdge.MaxX)
        
    }
    
    public func control(control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        updateCurrentValue()
        return true
    }
    
    @IBAction func fontButtonPressed(sender : AnyObject) {
        updateCurrentValue()
    }
    
    
    func parseCurrentValue() {

        let valueStringList = PSStringListContainer()
        valueStringList.stringValue = self.currentValue
        
        switch (type) {
        case .All:
            if valueStringList.count == 5 {
                fontFamilyPopUpButton.selectItemWithTitle(valueStringList[0])
                fontSizeText.stringValue = valueStringList[1] //use number formatter
                fontSize = fontSizeText.integerValue
                fontSizeStepper.integerValue = fontSize
                colorWell.color = PSColorStringToNSColor(valueStringList[4])
                
                if valueStringList[2].rangeOfString("Bold") != nil { boldCheck.state = 1 }
                if valueStringList[2].rangeOfString("Italic") != nil { italicCheck.state = 1 }
                if valueStringList[2].rangeOfString("Underline") != nil { underlinedCheck.state = 1 }
                if valueStringList[2].rangeOfString("Outline") != nil { outlineCheck.state = 1 }
                if valueStringList[2].rangeOfString("Shadow") != nil { shadowCheck.state = 1 }
            }
        
            break
        case .FamilyOnly:
            if valueStringList.count == 1 {
                fontFamilyPopUpButton.selectItemWithTitle(valueStringList[0])
            }
            break
        case .SizeOnly:
            if valueStringList.count == 1 {
                fontSizeText.stringValue = valueStringList[0] //use number formatter
                fontSize = fontSizeText.integerValue
                fontSizeStepper.integerValue = fontSize
            }
            break
        case .FaceOnly:
            if valueStringList.count == 1 {
                if valueStringList[0].rangeOfString("Bold") != nil { boldCheck.state = 1 }
                if valueStringList[0].rangeOfString("Italic") != nil { italicCheck.state = 1 }
                if valueStringList[0].rangeOfString("Underline") != nil { underlinedCheck.state = 1 }
                if valueStringList[0].rangeOfString("Outline") != nil { outlineCheck.state = 1 }
                if valueStringList[0].rangeOfString("Shadow") != nil { shadowCheck.state = 1 }
            }
            break
        }
    }
    
    func updateCurrentValue() {
        var cv = ""
        
        switch (type) {
        case .All:
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
        case .FamilyOnly:
            cv += "\""
            cv += fontFamilyPopUpButton.selectedItem!.title
            cv += "\""
            break
        case .SizeOnly:
            cv += "\(fontSize)"
            break
        case .FaceOnly:
            cv += "\""
            if (boldCheck.state == 1) { cv += "Bold " }
            if (italicCheck.state == 1) { cv += "Italic " }
            if (underlinedCheck.state == 1) { cv += "Underline " }
            if (outlineCheck.state == 1) { cv += "Outline " }
            if (shadowCheck.state == 1) { cv += "Shadow " }
            cv += "\""
            break
        }
        self.currentValue = cv
        currentValueLabel.stringValue = self.currentValue
    }
    
    var type : PSFontAttributePopupType
    override public func awakeFromNib() {

        super.awakeFromNib()
        
        //setup controls
        fontSizeText.enabled = false
        fontSizeStepper.enabled = false
        fontFamilyPopUpButton.enabled = false
        boldCheck.enabled = false
        italicCheck.enabled = false
        underlinedCheck.enabled = false
        outlineCheck.enabled = false
        shadowCheck.enabled = false
        colorWell.enabled = false
        
        switch (type) {
        case .All:
            fontSizeText.enabled = true
            fontSizeStepper.enabled = true
            fontFamilyPopUpButton.enabled = true
            boldCheck.enabled = true
            italicCheck.enabled = true
            underlinedCheck.enabled = true
            outlineCheck.enabled = true
            shadowCheck.enabled = true
            colorWell.enabled = true
            break
        case .FamilyOnly:
            fontFamilyPopUpButton.enabled = true
            break
        case .SizeOnly:
            fontSizeText.enabled = true
            fontSizeStepper.enabled = true
            break
        case .FaceOnly:
            boldCheck.enabled = true
            italicCheck.enabled = true
            underlinedCheck.enabled = true
            outlineCheck.enabled = true
            shadowCheck.enabled = true
            break
        }
        
        parseCurrentValue()
        currentValueLabel.stringValue = self.currentValue
    }
    
    @IBAction func enteredDone(_: AnyObject) {
        NSColorPanel.sharedColorPanel().close()
        updateCurrentValue()
        closeMyCustomSheet(self)
        NSFontPanel.sharedFontPanel().close()
    }
    
    
    
    
    override public func changeFont(sender: AnyObject?) {
        //var newFont = sender?.convertFont(font!)
        //font = newFont!
        //super.changeFont(sender)
        
    }
}
