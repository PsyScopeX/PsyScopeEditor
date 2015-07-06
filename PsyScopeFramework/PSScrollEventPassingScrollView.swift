//
//  PSScrollEventPassingScrollView.swift
//  PsyScopeEditor
//
//  Created by James on 28/05/2015.
//  Copyright (c) 2015 James. All rights reserved.
//

import Foundation

public class PSScrollEventPassingScrollView : NSScrollView {
    /*- (void)scrollWheel:(NSEvent *)theEvent {
    NSLog(@"%@", theEvent);
    if(theEvent.deltaX !=0)
    [super scrollWheel:theEvent];
    else
    [[self nextResponder] scrollWheel:theEvent];
    
    }*/
    
    public override func scrollWheel(event : NSEvent) {
        self.nextResponder!.scrollWheel(event)
    }
}