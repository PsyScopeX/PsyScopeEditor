//
//  PSCondition.swift
//  PsyScopeEditor
//
//  Created by James on 02/02/2015.
//

import Foundation

//
//  PSAction.swift
//  PsyScopeEditor
//
//  Created by James on 16/11/2014.
//

import Foundation

class PSCondition : NSObject, PSConditionInterface {
    var typeString : String = ""
    var userFriendlyNameString : String = ""
    var helpfulDescriptionString : String = ""
    var expandedHeight : CGFloat = 30
    
    func type() -> String! {
        return typeString
    }
    
    func userFriendlyName() -> String! {
        return userFriendlyNameString
    }
    
    func helpfulDescription() -> String! {
        return helpfulDescriptionString
    }
    
    func icon() -> NSImage! {
        return nil
    }
    
    
    func conditionCellInterface() -> AnyObject! {
        return nil
    }
    
    func nib() -> NSNib! {
        fatalError("Use of PSCondition virtual function nib")
    }
    
    func expandedCellHeight() -> CGFloat {
        return expandedHeight
    }
}
