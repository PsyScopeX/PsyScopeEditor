//
//  PSApplicationEngine.h
//  PsyScopeEditor
//
//  Created by James on 22/11/2014.
//

#import "DOManager.h"
#import <Cocoa/Cocoa.h>


enum {
    app_unknown,
    app_ready,
    app_script_loaded,
    app_script_running,
    app_script_finished
};

FOUNDATION_EXPORT NSString *const applicationEngineName;

@interface PSApplicationEngine : NSObject <GuiManagerProtocol> {
@private
    DOManager *doMngr;
    int appStatus;
    id apProxy;
    bool started;
    NSString *scriptStatus;
    NSTimer *launchTimer; 
    NSTask *applicationEngineTask;
    NSPipe *applicationEnginePipe;
    NSFileHandle *applicationEnginePipeFileHandle;
    int _changeID;
    bool changeResponse;
    int launch_failures;
    
}

+ (id)sharedManager;

//receives output from application engine pipe (e.g. log messages)
- (void)applicationEngineLogNotification:(NSNotification *)notification;

//sets the application engine state to on and tries starting it
- (void)start;

//sets the application engine state to off and tries to close it
- (void)close;

//call this before sending messages to make sure the process is still running
- (bool)assertRunning;

- (void) launchEngine;

- (void)loadTheScript:(NSString*)script;

- (void)runTheScript;

//when a notification is received, process the next communication
- (void)processNotification: (id) sender;
;
@property (readonly) bool done;

@end


