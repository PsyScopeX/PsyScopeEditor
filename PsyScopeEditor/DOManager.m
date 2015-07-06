//
//  DOManager.m
//  DOTest
//
//  Created by luca on 03/11/2014.
//  Copyright (c) 2014 luca. All rights reserved.
//

#import "DOManager.h"

#define DEBUG 1
#import "FileLogger.h"

@implementation DOManager

@synthesize delegate;

- (id)init {
    if (self = [super init]) {
        gui = [LocalDistributedObj new];
        if ([gui setupService: SERVICE_GM withRootObject: self ]) {
            return self;
        }
    }
    return nil;
}


-(void) aeNotificationProc:(NSNotification *) notification {
    if ([[notification name] isEqualToString:NSConnectionDidDieNotification])
        NSLog (@"Remote App Engine object no more available");
}

-(RemoteDistributedObj*) setAppEngineProxy {
    ae = [RemoteDistributedObj  new];
    if ([ae bindToService:SERVICE_AE onHost: nil usingProtocol:@protocol(AppEngineProtocol)]) {
        [[ae connection] setRequestTimeout: 0.5];
        [[ae connection] setReplyTimeout: 0.5];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(aeNotificationProc:)
                                                     name:NSConnectionDidDieNotification
                                                   object:[ae connection]];
        return [ae proxy];
    }
    return nil;
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self ];
}

// GuiManagerProtocol implementation
- (void) notify: (in bycopy NSString *)msg withValue: (in bycopy NSString *)value {
    if ([delegate respondsToSelector: @selector(notify:withValue:)]) {
        return [ delegate notify:msg withValue: value];
    }
    DebugNSLog(@"Notification from App Engine: [%@], [%@]", msg, value);
}

- (void) acceptScriptChange: (in bycopy int)changeID {
    if ([delegate respondsToSelector: @selector(acceptScriptChange:)]) {
        return [ delegate acceptScriptChange:changeID];
    }
}

- (void) rejectScriptChange: (in bycopy int)changeID errors: (in bycopy NSDictionary*) errors {
    if ([delegate respondsToSelector: @selector(rejectScriptChange:errors:)]) {
        return [ delegate rejectScriptChange:changeID errors:errors];
    }
}

@end

