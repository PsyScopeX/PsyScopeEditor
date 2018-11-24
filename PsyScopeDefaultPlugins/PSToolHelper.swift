//
//  PluginTools.swift
//  PsyScopeEditor
//
//  Created by James on 31/07/2014.
//

import Cocoa


// common methods for PSTools - this is currently inherited by PSTool for now... but probably will end being split into various factory methods that focus on different things....

class PSToolHelper: NSObject {
    
    class func createLinkFromToolToList(_ parent: Entry!, to list: Entry!, withScript scriptData: PSScriptData!) -> Bool {
        let allowableParentTypes = ["Experiment","Group","Block","Template"]
    
        if !allowableParentTypes.contains(parent.type) || list.type != "List" {
            return false
        }
    

        //create Link
        parent.layoutObject.addChildLinkObject(list.layoutObject)
        //attribute is a weird one, as it has two sub attributes
        let factors_entry = scriptData.getOrCreateSubEntry("Factors", entry: parent, isProperty: true)
        let sets_entry = scriptData.getOrCreateSubEntry("Sets", entry: factors_entry, isProperty: true)
        let types_entry = scriptData.getOrCreateSubEntry("Types", entry: factors_entry, isProperty: true)
        
        let factors = PSStringList(entry: factors_entry, scriptData: scriptData)
        let sets = PSStringList(entry: sets_entry, scriptData: scriptData)
        let types = PSStringList(entry: types_entry, scriptData: scriptData)
        
        if (!factors.contains(list.name) && factors.appendAsString(list.name)) {
            sets.appendAsString("1")
            types.appendAsString("List")
        }
        
        return true
    }
    
    //this will populate the 'type' of ghost entries if their name matches a given list
    class func identifyEntriesByName(_ ghostScript: PSGhostScript!, names: [String], type : PSType) -> [PSScriptError] {
        var errors : [PSScriptError] = []
        for ge in ghostScript.entries {
            if names.contains(ge.name) {
                if (ge.type.isEmpty || ge.type == type.name) {
                    ge.type = type.name
                } else {
                    errors.append(PSErrorAmbiguousType(ge.name,type1: ge.type,type2: type.name))
                }
            }
        }
        return errors
    }
    
    //this will populate the 'type' of ghost entries indentified by OWN keyAttribute as type
    class func identifyEntriesByKeyAttribute(_ ghostScript: PSGhostScript!, keyAttribute: String, type : PSType) -> [PSScriptError] {
        var errors : [PSScriptError] = []
        
        for ge in ghostScript.entries as [PSGhostEntry] {
            for a in ge.subEntries as [PSGhostEntry] {
                if (a.name == keyAttribute) {
                    //found entry, set types
                    if (ge.type.isEmpty || ge.type == type.name) {
                        ge.type = type.name
                    } else {
                        errors.append(PSErrorAmbiguousType(ge.name,type1: ge.type,type2: type.name))
                    }
                }
            }
        }
        return errors
    }
    //this will populate the 'type' of ghost entries identified in OTHER entries keyAttribute, to type - throwing errors if already defined...
    class func identifyEntriesByPropertyInOtherEntry(_ ghostScript: PSGhostScript!, property: PSProperty, type : PSType) -> [PSScriptError] {
        var errors : [PSScriptError] = []
        
            
            for ge in ghostScript.entries as [PSGhostEntry] {
                for a in ge.subEntries as [PSGhostEntry] {
                    if (a.name == property.name) {
                        a.type = "Property"
                        
                        //found a sub entry with name of key attribute
                        let entry_content = PSStringListCachedContainer()
                        entry_content.stringValue = a.currentValue
                        let entry_names : [PSEntryElement] = entry_content.values
                        
                        
                        for entry_name in entry_names {
                            
                            switch(entry_name) {
                            case .stringToken(let stringElement):
                                var found_entry_name = false
                                for ge2 in ghostScript.entries as [PSGhostEntry] {
                                    if ge2.name == stringElement.value {
                                        
                                        //found the referenced entry, label it
                                        found_entry_name = true
                                        if (ge2.type.isEmpty || ge2.type == type.name) {
                                            ge2.type = type.name
                                            
                                            //create link
                                            ge.links.append(ge2)
                                            
                                        } else {
                                            errors.append(PSErrorAmbiguousType(ge2.name,type1: ge2.type,type2: type.name))
                                        }
                                        
                                    }
                                }
                                
                                if (!found_entry_name) {
                                    errors.append(PSErrorEntryNotFound(stringElement.value, parentEntry: ge.name, subEntry: a.name))
                                }
                                
                                
                                break
                            default:
                                //either function or expression, leave for now
                                break
                            }
                            
                            
                        }
                    }
                }
            }
        return errors
    }
    
    
    
    class func ImageNamed(_ image_name : String) -> NSImage {
        return NSImage(contentsOfFile: Bundle(for:self).pathForImageResource(image_name)!)!
    }
    
    class func attributedStringForAttributeFunction(_ functionName : String, icon : NSImage, currentValue : String) -> [AnyObject] {
        let function = PSFunctionElement()
        function.stringValue = currentValue
        
        if !function.foundErrors && function.functionName == functionName {
            
            let nameOfEntry = function.getStrippedStringValues().first
            
            if nameOfEntry == nil { return [] }
            
            let size = PSDefaultConstants.Spacing.VaryByIconSize
            //resize image
            let img = NSImage(size: CGSize(width: size, height: size))
            img.lockFocus()
            let ctx = NSGraphicsContext.current()
            ctx?.imageInterpolation = .high
            icon.draw(in: NSMakeRect(0, 0, size, size), from: NSMakeRect(0, 0, icon.size.width, icon.size.height), operation: .copy, fraction: 1)
            img.unlockFocus()
            
            
            //create attachment
            let attachment = NSTextAttachment()
            attachment.attachmentCell = NSTextAttachmentCell(imageCell: img)
      
            //create attributed string from attachmend
            let iconString = NSAttributedString(attachment: attachment)
            
            //create string part
            let values = function.getStrippedStringValues()
            let valueString = values.joined(separator: " \u{21d2} ")
            
            let stringPart = NSAttributedString(string: "  " + valueString, attributes: [NSBaselineOffsetAttributeName : PSDefaultConstants.Spacing.VaryByTextYOffset])
            
            //put together attributed string
            let attributedString = NSMutableAttributedString()
            attributedString.append(iconString)
            attributedString.append(stringPart)
            
            //now put together array
            let returnArray : [AnyObject] = [attributedString, nameOfEntry!]
            
            return returnArray
        }
        return []
    }
    
}



