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
    
    override func nib() -> NSNib {
        return NSNib(nibNamed: "Condition_MovieCell", bundle: Bundle(for:Swift.type(of: self)))!
    }

    
    override func icon() -> NSImage {
        let image : NSImage = NSImage(contentsOfFile: Bundle(for:Swift.type(of: self)).pathForImageResource("MouseClick")!)!
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
        timePointRadio.selectCell(withTag: 1) //done
        hourText.stringValue = "0"
        minText.stringValue = "0"
        secText.stringValue = "0"
        msText.stringValue = "0"
        
        for v in inputValue {
            let lcv = v.lowercased()
            if lcv == "done" {
                timePointRadio.selectCell(withTag: 1) //done
                hourText.isEnabled = false
                minText.isEnabled = false
                secText.isEnabled = false
                msText.isEnabled = false
            } else if lcv == "at" {
                timePointRadio.selectCell(withTag: 2) //at
                hourText.isEnabled = true
                minText.isEnabled = true
                secText.isEnabled = true
                msText.isEnabled = true
            } else if lcv.range(of: ",") != nil {
                //"h:0,m:0,s:0,ms:0"
                
                for time in v.lowercased().components(separatedBy: ",") {
                    var points = time.components(separatedBy: ":")
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
    
    @IBAction func generate(_ sender : AnyObject) {
        var outputString = ""
        let tag = timePointRadio.selectedTag()
        if tag == 2 {
            //at //"h:0,m:0,s:0,ms:0"
            outputString += "At "
            outputString += movieTagText.stringValue
            outputString += " \"h:\(hourText.stringValue),m:\(minText.stringValue),s:\(secText.stringValue),ms:\(msText.stringValue)\""
            hourText.isEnabled = true
            minText.isEnabled = true
            secText.isEnabled = true
            msText.isEnabled = true
        } else {
            //done
            outputString += "Done "
            outputString += movieTagText.stringValue
            hourText.isEnabled = false
            minText.isEnabled = false
            secText.isEnabled = false
            msText.isEnabled = false
        }
        
        entryFunction.setStringValues([outputString])
        self.updateScript()
    }
    
    func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        generate(control)
        return true
    }
    
    override func setup(_ conditionInterface: PSConditionInterface, function entryFunction: PSFunctionElement, scriptData: PSScriptData, expandedHeight: CGFloat) {
        super.setup(conditionInterface,function: entryFunction,scriptData: scriptData, expandedHeight: expandedHeight)
        parse()
    }
}
