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
    
    enum FType {
        case int, float, string, list, path
    }
    
    override func textDidEndEditing(_ notification: Notification) {
        //parse the string
        
        //if not a function, check it is one of the valid types
    }
    
}
