//
//  PSAction_QuitBlock.swift
//  PsyScopeEditor
//
//  Created by James on 05/03/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

class PSAction_QuitBlock : PSAction {
    override init() {
        super.init()
        typeString = "QuitBlock"
        userFriendlyNameString = "Quit Block"
        helpfulDescriptionString = "This action is used to skip any remaining trials in the current block. The current trial continues to execute normally.  If there are multiple levels of blocks in the experiment hierarchy, then QuitBlock[] quits within the lowest-level block by default, continuing within that block’s owner (if there are more blocks to execute). To quit a higher-level block, you can specify which block to quit in Block Name. Alternatively, you can specify which block to quit as a number; this number specifies how many hierarchical levels of blocks to quit (thus, the default behavior is equivalent to specifying “1” in Block Name).  By default, when trials in the block are skipped, any lists connected to the blocks are left unaccessed for the trials which are not executed. If Forward Lists is set to “True”, then for each factor set connected to the block and its owners, a cell is se- lected for each trial that is not executed; this insures that cells are assigned to trials consistently, whether or not they are run."
        actionParameters = [PSAttributeParameter_String.self, PSAttributeParameter_String.self]
        actionParameterNames = ["Block:", "Forward Lists:"]
        groupString = "Block / Trial"
    }
}