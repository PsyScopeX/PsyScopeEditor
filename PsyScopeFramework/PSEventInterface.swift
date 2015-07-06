//
//  PSEventInterface.swift
//  PsyScopeEditor
//
//  Created by James on 13/04/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

@objc public protocol PSEventInterface {
    
    //in template editor, the value of this attribute is displayed on the bar representing the event
    var mainStimulusAttributeName : String { get }
}