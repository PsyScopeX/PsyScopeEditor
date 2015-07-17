//
//  PSUnicodeUtilities.h
//  PsyScopeEditor
//
//  Created by James on 17/07/2015.
//  Copyright © 2015 James. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
@interface PSUnicodeUtilities : NSObject

+(NSString*)characterForEventWithoutModifiers:(NSEvent*)event;
@end
