//
//  PSTextField.swift
//  PsyScopeEditor
//
//  Created by James on 28/07/2015.
//  Copyright © 2015 James. All rights reserved.
//

import Foundation

//a subclass which allows psyscope functions etc
class PSTextField : NSTextField {
    
    enum Type {
        case Int, Float, String, List, Path
    }
    
    override func textDidEndEditing(notification: NSNotification) {
        //parse the string
        
        //if not a function, check it is one of the valid types
    }
    
}