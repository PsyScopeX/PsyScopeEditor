//
//  PSCondition_Movie.swift
//  PsyScopeEditor
//
//  Created by James on 31/01/2015.
//
import Foundation

class PSCondition_Movie : PSCondition {
    override init() {
        super.init()
        expandedHeight = 140
        typeString = "Movie"
        userFriendlyNameString = "Movie"
        helpfulDescriptionString = "This action allows events to trigger at certain times during the display of a movie"
        
    }
    
    override func nib() -> NSNib! {
        return NSNib(nibNamed: "Condition_MovieCell", bundle: NSBundle(forClass:self.dynamicType))
    }

    
    override func icon() -> NSImage! {
        let image : NSImage = NSImage(contentsOfFile: NSBundle(forClass:self.dynamicType).pathForImageResource("MouseClick")!)!
        return image
    }
}




class PSCondition_MovieCell : PSConditionCell, NSTextFieldDelegate {
    @IBOutlet var movieTagText : NSTextField!
    @IBOutlet var timePointRadio  : NSMatrix!
    
    @IBOutlet var hourText : NSTextField!
    @IBOutlet var minText : NSTextField!
    @IBOutlet var secText : NSTextField!
    @IBOutlet var msText : NSTextField!
    
    func parse() {

        let inputValue = entryFunction.getStringValues()
        timePointRadio.selectCellWithTag(1) //done
        hourText.stringValue = "0"
        minText.stringValue = "0"
        secText.stringValue = "0"
        msText.stringValue = "0"
        
        for v in inputValue {
            let lcv = v.lowercaseString
            if lcv == "done" {
                timePointRadio.selectCellWithTag(1) //done
                hourText.enabled = false
                minText.enabled = false
                secText.enabled = false
                msText.enabled = false
            } else if lcv == "at" {
                timePointRadio.selectCellWithTag(2) //at
                hourText.enabled = true
                minText.enabled = true
                secText.enabled = true
                msText.enabled = true
            } else if lcv.rangeOfString(",") != nil {
                //"h:0,m:0,s:0,ms:0"
                
                for time in v.lowercaseString.componentsSeparatedByString(",") {
                    var points = time.componentsSeparatedByString(":")
                    if points.count != 2 { break }
                    switch (points[0]) {
                    case "h":
                        hourText.stringValue = points[1]
                    case "m":
                        minText.stringValue = points[1]
                    case "s":
                        secText.stringValue = points[1]
                    case "ms":
                        msText.stringValue = points[1]
                    default:
                        break
                    }
                }
                
            } else {
                //must be tag
                movieTagText.stringValue = v
            }
            
            
        }

    }
    
    @IBAction func generate(sender : AnyObject) {
        var outputString = ""
        let tag = timePointRadio.selectedTag()
        if tag == 2 {
            //at //"h:0,m:0,s:0,ms:0"
            outputString += "At "
            outputString += movieTagText.stringValue
            outputString += " \"h:\(hourText.stringValue),m:\(minText.stringValue),s:\(secText.stringValue),ms:\(msText.stringValue)\""
            hourText.enabled = true
            minText.enabled = true
            secText.enabled = true
            msText.enabled = true
        } else {
            //done
            outputString += "Done "
            outputString += movieTagText.stringValue
            hourText.enabled = false
            minText.enabled = false
            secText.enabled = false
            msText.enabled = false
        }
        
        entryFunction.setStringValues([outputString])
        self.updateScript()
    }
    
    func control(control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        generate(control)
        return true
    }
    
    override func setup(conditionInterface: PSConditionInterface, function entryFunction: PSFunctionElement, scriptData: PSScriptData, expandedHeight: CGFloat) {
        super.setup(conditionInterface,function: entryFunction,scriptData: scriptData, expandedHeight: expandedHeight)
        parse()
    }
}