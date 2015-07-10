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


public class PSCheckBoxListAttributePopup: PSAttributePopup {
    
    public init(currentValue : String, displayName : String, checkBoxStrings : [(String,String)], setCurrentValueBlock : ((String) -> ())?) {
        let bundle = NSBundle(forClass:self.dynamicType)
        self.checkBoxStrings = checkBoxStrings
        super.init(nibName: "CheckBoxListAttributePopup", bundle: bundle, currentValue: currentValue, displayName: displayName, setCurrentValueBlock: setCurrentValueBlock)
    }
    
    @IBOutlet var view : NSView!
    
    
    var checkBoxStrings : [(String,String)]
    var checkBoxes : [(button : NSButton, token : String)] = []
    var okButton : NSButton! = nil
    override public func awakeFromNib() {
        let height = (checkBoxStrings.count * 20) + 60
        let size =  NSSize(width: 400, height: height)
        var frame = view.window!.frame
        frame.size = size
        view.window?.setFrame(frame, display: true, animate: false)
        view.setFrameSize(size)
        
        //add check boxes
        var y = view.frame.height - 40;
        for checkBoxString in checkBoxStrings {
            let rect = NSMakeRect(10, y, 400, 20)
            let new_check_box : NSButton = NSButton(frame: rect)
            new_check_box.setButtonType(NSButtonType.SwitchButton)
            new_check_box.title = checkBoxString.1
            
            view.addSubview(new_check_box)
            
            checkBoxes.append(button: new_check_box, token: checkBoxString.0)
            y -= 20
        }
        
        //add ok button
        okButton = NSButton(frame: NSMakeRect(10,20,50,20))
        okButton.title = "OK"
        okButton.target = self
        okButton.action = "closeWindow:"
        view.addSubview(okButton)
        
        //now set checkBoxes
        let current_options : [String] = currentValue.componentsSeparatedByString(" ")
        for checkBox in checkBoxes {
            for active_option in current_options {
                if active_option == checkBox.token {
                    checkBox.button.integerValue = 1
                }
            }
        }
    }
    
    func closeWindow(_: AnyObject) {
        // populate entry
        var value = ""
        for checkBox in checkBoxes {
            if checkBox.button.integerValue == 1 {
                value += checkBox.token + " "
            }
        }
        currentValue = value.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        self.closeMyCustomSheet(self)
    }
}
