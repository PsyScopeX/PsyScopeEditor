//
//  PSCheckBoxListAttributePopup.swift
//  PsyScopeEditor
//
//  Created by James on 25/10/2014.
//

import Foundation

//
//  PSExperimentDataFields.swift
//  PsyScopeEditor
//
//  Created by James on 19/08/2014.
//

import Foundation


open class PSCheckBoxListAttributePopup: PSAttributePopup {
    
    public init(currentValue : PSEntryElement, displayName : String, checkBoxStrings : [(String,String)], setCurrentValueBlock : ((PSEntryElement) -> ())?) {
        let bundle = Bundle(for:type(of: self))
        self.checkBoxStrings = checkBoxStrings
        super.init(nibName: "CheckBoxListAttributePopup", bundle: bundle, currentValue: currentValue, displayName: displayName, setCurrentValueBlock: setCurrentValueBlock)
    }
    
    @IBOutlet var view : NSView!
    
    
    var checkBoxStrings : [(String,String)]
    var checkBoxes : [(button : NSButton, token : String)] = []
    var okButton : NSButton! = nil
    override open func awakeFromNib() {
        let height = (checkBoxStrings.count * 20) + 60
        let size =  NSSize(width: 400, height: height)
        var frame = view.window!.frame
        frame.size = size
        view.window?.setFrame(frame, display: true, animate: false)
        view.setFrameSize(size)
        
        //add check boxes
        var y = view.frame.height - 50;
        for checkBoxString in checkBoxStrings {
            let rect = NSMakeRect(10, y, 400, 20)
            let new_check_box : NSButton = NSButton(frame: rect)
            new_check_box.setButtonType(NSButton.ButtonType.switch)
            new_check_box.title = checkBoxString.1
            
            view.addSubview(new_check_box)
            
            checkBoxes.append((button: new_check_box, token: checkBoxString.0))
            y -= 20
        }
        
        //add ok button
        okButton = NSButton(frame: NSMakeRect(190,10,50,20))
        okButton.title = "OK"
        okButton.target = self
        okButton.action = #selector(PSCheckBoxListAttributePopup.closeWindow(_:))
        view.addSubview(okButton)
        
        //now set checkBoxes
        let current_options : [String] = currentValue.stringValue().components(separatedBy: " ")
        for checkBox in checkBoxes {
            for active_option in current_options {
                if active_option == checkBox.token {
                    checkBox.button.integerValue = 1
                }
            }
        }
    }
    
    @objc func closeWindow(_: AnyObject) {
        // populate entry
        var value = ""
        for checkBox in checkBoxes {
            if checkBox.button.integerValue == 1 {
                value += checkBox.token + " "
            }
        }
        
        
        currentValue = PSGetListElementForString(value.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
        
        self.closeMyCustomSheet(self)
    }
}
