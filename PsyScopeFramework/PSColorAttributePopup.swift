//
//  PSColorAttributePopup.swift
//  PsyScopeEditor
//
//  Created by James on 23/10/2014.
//

import Foundation

func NSColorToPSColorString(_ color_in : NSColor) -> String {
    //For the RGB system, three integers are specified, each in the range 0 to 32677, and representing the amount of red, green and blue to be used, respectively; these three number should be together in one string.
    let color = color_in.usingColorSpaceName(NSCalibratedRGBColorSpace)!
    let r : Int = Int(color.redComponent * CGFloat(32677))
    let g : Int = Int(color.greenComponent * CGFloat(32677))
    let b : Int = Int(color.blueComponent * CGFloat(32677))
    
    return "\"\(r) \(g) \(b)\""
}

func PSColorStringToNSColor(_ colorString : String) -> NSColor {
    var returnColor : NSColor
    let cv = colorString.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
    var components = cv.components(separatedBy: CharacterSet.whitespaces)
    
    if components.count == 3 {
        let ri = Int(components[0]) == nil ? 0 : Int(components[0])!
        let gi = Int(components[1]) == nil ? 0 : Int(components[1])!
        let bi = Int(components[2]) == nil ? 0 : Int(components[2])!
        
        let r : CGFloat = CGFloat(ri) / CGFloat(32677)
        let g : CGFloat = CGFloat(gi) / CGFloat(32677)
        let b : CGFloat = CGFloat(bi) / CGFloat(32677)
        returnColor = NSColor(red: r, green: g, blue: b, alpha: 1.0)
    } else {
        returnColor = NSColor.black
    }
    
    return returnColor
}

open class PSColorAttributePopup: PSAttributePopup {
    public init(currentValue: PSEntryElement, displayName : String, setCurrentValueBlock : ((PSEntryElement) -> ())?) {
        super.init(nibName: "ColorAttribute",bundle: Bundle(for:type(of: self)),currentValue: currentValue, displayName: displayName, setCurrentValueBlock: setCurrentValueBlock)
    }
    
    @IBOutlet var colorWell : NSColorWell!
    
    override open func awakeFromNib() {
        colorWell.color = PSColorStringToNSColor(self.currentValue.stringValue())
    }
    
    @IBAction func enteredDone(_: AnyObject) {
        currentValue = PSGetFirstEntryElementForStringOrNull(NSColorToPSColorString(colorWell.color))
        closeMyCustomSheet(self)
        NSColorPanel.shared().close()
    }
    
}
