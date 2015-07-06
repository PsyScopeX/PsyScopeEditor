//
//  PSListCell.swift
//  PsyScopeEditor
//
//  Created by James on 10/04/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

//list cells can be activated by using keys
class PSListCell : PSAttributeStringCell {
    var activateBlock : (()->())?
}