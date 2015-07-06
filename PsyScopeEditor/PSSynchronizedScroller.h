//
//  PSSynchronizedScroller.h
//  PsyScopeEditor
//
//  Created by James on 12/12/2014.
//

#import <Cocoa/Cocoa.h>

@interface PSSynchronizedScroller : NSScrollView {
    IBOutlet NSScrollView* synchronizedScrollView; // not retained
}

- (void)setSynchronizedScrollView:(NSScrollView*)scrollview;
- (void)stopSynchronizing;
- (void)synchronizedViewContentBoundsDidChange:(NSNotification *)notification;

@end
