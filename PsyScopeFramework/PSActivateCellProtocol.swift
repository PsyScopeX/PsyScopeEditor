//
//  PSActivateProtocol.swift
//  PsyScopeEditor
//
//  Created by James on 10/04/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation


//used when a custom routine needs to be used to activate a cell's first responder correctly
public protocol PSActivateCellProtocol {
    func activate()
}