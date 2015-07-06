//
//  PSApplicationEngine.m
//  PsyScopeEditor
//
//  Created by James on 22/11/2014.
//

#import "PSApplicationEngine.h"
#import <PsyScopeFramework/PsyScopeFramework.h>
#import "PsyScopeEditor-Swift.h"

#define DEBUG 1
#import "FileLogger.h"

NSString *const applicationEngineName = @"PsyScope X B77";

@implementation PSApplicationEngine

@synthesize done = done;



-(id)init {

    id retObj = [super init];
    
    if (retObj != nil) {
        
        
        doMngr = [ DOManager new ];
        if (doMngr != nil) {
            doMngr.delegate = self;
            appStatus = app_unknown;
            apProxy = nil;
            started = false;
            launchTimer = nil;
            scriptStatus = @"ToLoad";
            _changeID = 0; //start at 0
            changeResponse = false;
            launch_failures = 0;
            applicationEngineTask = nil;
        } else {
            retObj = nil;
        }
    }
    return retObj;
}


+ (id)sharedManager {
    static PSApplicationEngine *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}


- (void)start {
    [self close]; //when first initing, need to kill any process with the same name, as may be in wrong state.
    started = true; //flag to show that should be started
    launch_failures = 0;
    //begin trying to launch application if not already
    [self launchEngine];
    if (launchTimer == nil) {
        launchTimer = [NSTimer scheduledTimerWithTimeInterval:4.0
                                                       target:self
                                                     selector:@selector(onTickLaunchTimer:)
                                                     userInfo:nil
                                                      repeats:YES];
    }
}

- (void)close {
    started = false;
    
    //get list of running apps
    NSWorkspace *nws = [NSWorkspace sharedWorkspace];
    NSArray *runningApps = [NSArray arrayWithArray:[nws runningApplications]];
    
    for (NSRunningApplication *app in runningApps) {
        if ([[app localizedName] isEqualToString: applicationEngineName]) {
            //[app forceTerminate];  //FIXME: Reinstate this when not developing with PsyScope open
        }
    }
}

- (bool)assertRunning {
    //add here checks to make sure AE is ready to have messages sent to it
    if (!started || ![self isAppLaunched] || apProxy == nil) {
        NSAlert* alert= [NSAlert alertWithMessageText:@"The experiment engine has crashed or is not running" defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@"Please wait and try again or restart PsyScopeEditor"];
        [alert runModal];
        [self start]; //something happened, so restart
        return false;
    } else {
        return true;
    }
}

- (void) notify: (in bycopy NSString *)msg withValue: (in bycopy NSString *)value {
    NSLog(@"Notification from App Engine caught: [%@], [%@]", msg, value);
    if ([msg isEqualToString: NOTIFY_READY]) {
        appStatus = app_ready;
    }
    else if ([msg isEqualToString: NOTIFY_SCRIPT_LOADED]) {
        appStatus = app_script_loaded;
    }
    else if ([msg isEqualToString: NOTIFY_SCRIPT_RUNNING]) {
        appStatus = app_script_running;
    }
    else if ([msg isEqualToString: NOTIFY_SCRIPT_FINISHED]) {
        appStatus = app_script_finished;
    }
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"PSNotifyNewNotification" object:self];
}



-(void) processNotification: (id) sender {

}

- (void) acceptScriptChange: (in bycopy int)changeID {
    changeResponse = true;
    if (changeID == self->_changeID) {
        
    } else {
        //some error
    }
}

- (void) rejectScriptChange: (in bycopy int)changeID errors: (in bycopy NSDictionary*) errors {
    changeResponse = true;
    if (changeID == self->_changeID) {
        
    } else {
        //some error
    }
}



-(bool) isAppLaunched {
    //NSTask should have been started
    if (applicationEngineTask == nil) {
        return false;
    }
    
    //There should be a process running with the correct name
    NSWorkspace *nws = [NSWorkspace sharedWorkspace];
    NSArray *runningApps = [NSArray arrayWithArray:[nws runningApplications]];
    
    for (NSRunningApplication *app in runningApps) {
        
        if ([[app localizedName] isEqualToString: applicationEngineName])
            return [app isFinishedLaunching];
    }
    return false;
}

-(void)onTickLaunchTimer:(NSTimer *)aTimer {
    launch_failures++;
    
    if (launch_failures > 4) {
        NSLog(@"Cannot launch app engine - launch timer invalidated");
        [launchTimer invalidate];
        launchTimer = nil;
        [self close];
        return;
    }
    [self launchEngine];
}

-(void)launchEngine {
    //first keep trying to launch the application
    if (![self isAppLaunched]) {
        NSString* executablePath = [NSString stringWithFormat:@"/%@.app/Contents/MacOS/%@", applicationEngineName, applicationEngineName];
        
        NSString* fullPath = [[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent] stringByAppendingString:executablePath];
        if (![[NSFileManager defaultManager]fileExistsAtPath:fullPath]) {
            [NSException raise:@"PsyScope App Engine file not found" format:@"File not found at path %@", fullPath];
        }
        
        applicationEngineTask = [NSTask new];
        //applicationEnginePipe = [NSPipe new];
        
        //[applicationEngineTask setStandardOutput:applicationEnginePipe];
        
        [applicationEngineTask setLaunchPath:fullPath];
        
        //applicationEnginePipeFileHandle = [applicationEnginePipe fileHandleForReading];
        //[applicationEnginePipeFileHandle waitForDataInBackgroundAndNotify];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationEngineLogNotification:)
                                                     name:NSFileHandleDataAvailableNotification
                                                   object:nil];
        
#if DEBUG
        NSMutableDictionary *env = [NSMutableDictionary dictionaryWithDictionary:[[NSProcessInfo processInfo] environment]];
        [env setObject:@"1" forKey:@"AEDebug"];
        [env setObject:@"1" forKey:@"AEDebugSends"];
        [env setObject:@"1" forKey:@"AEDebugReceives"];
        [applicationEngineTask setEnvironment:env];
#endif
        [applicationEngineTask launch];
        
        return; //wait for next second to set up the proxy
    }
    
    
    
    //second try to set up the proxy
    if (apProxy == nil) {
        apProxy = [doMngr setAppEngineProxy];
    }
    
    //last turn off timer if proxy is up and running
    if (apProxy != nil && appStatus != app_unknown) {
        NSLog(@"Proxy set - launch timer invalidated");
        [launchTimer invalidate];
        launchTimer = nil;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(processNotification:)
                                                     name:@"PSNotifyNewNotification"
                                                   object:nil];
    }
}

- (void)applicationEngineLogNotification:(NSNotification *)notification
{
    NSData *data = nil;
    while ((data = [self->applicationEnginePipeFileHandle availableData]) && [data length]){
        NSString *receivedDataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@",receivedDataString);
    }
}

-(BOOL)setOSType: (unsigned long)type andCreator: (unsigned long) creator forFile: (NSString *)path {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSDictionary *attr =  @{NSFileHFSTypeCode : @(type), NSFileHFSCreatorCode : @(creator)};
    return [fm setAttributes:attr ofItemAtPath:path error:nil];
}

//this function blocks waiting for return
-(void) validateEntry: (NSString*)newEntry oldEntryName:(NSString*) oldEntryName oldScript:(NSString*) oldScript {
    /*NSArray* keys = [[NSArray alloc] initWithObjects:SCRIPT_CHANGE_NEW_ENTRY, SCRIPT_CHANGE_OLD_NAME, SCRIPT_CHANGE_OLD_SCRIPT, nil ];
    NSArray *objects = [[NSArray alloc] initWithObjects:newEntry, oldEntryName, oldScript, nil];
    NSDictionary* dictionary = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
    [self assertRunning];
    
    NSLog(@"Sending change...");
    @try {
        
        @synchronized(self) {
            [apProxy proposeScriptChange: _changeID++ changes:dictionary];
            //wait here for reply, with timeout
        }
    }
    @catch (NSException *e) {
        DebugNSLog(@"Error while invoking App Engine method: %@", e);
        apProxy = nil;
        return;
    }*/
}

-(void)loadTheScript:(NSString *)script {
    //save as temporary file
    //NSURL* url = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
    NSURL* url = [NSURL fileURLWithPath:@"/tmp" isDirectory:YES];
    url = [url URLByAppendingPathComponent:@"scriptToRun"];
    
    NSString *oldPsyScript = [NSString stringWithFormat: @"#PsyScope 1.0\r# Script template, Version 1.0\r\r%@", script ];
    [ oldPsyScript writeToURL:url atomically:true ];
    [self setOSType: 'PsyX' andCreator: 'tach' forFile: [url path]];
    
    /* That should be the way to go if it would work (after adding to info.plist the doc type "PsyScopeX Document" and implemented the relative class)... but DocClass is nil, dunno why (to be investigated)
    Class DocClass = [[ NSDocumentController sharedDocumentController ] documentClassForType:@"PsyScopeX Document"];
    NSDocument *opd = [ DocClass new ];
    [opd readFromData: [oldPsyScript dataUsingEncoding:NSUTF8StringEncoding] ofType:nil error:nil];
    [opd writeToURL: url ofType:@"PsyScopeX Document" error:nil ];
    */
     
    if (![self assertRunning]) {
        return;
    }
    
    NSLog(@"Sending filepath: %@", [url path]);
    @try {
        [apProxy loadScript: [url path]];
    }
    @catch (NSException *e) {
        DebugNSLog(@"Error while invoking App Engine method: %@", e);
        apProxy = nil;
        return;
    }
}

-(void) runTheScript {
    if (![self assertRunning]) {
        return;
    }
    
    if (appStatus == app_script_loaded) {
        NSLog(@"Running script");
        @try {
            [apProxy runScript];
        }
        @catch (NSException *e) {
            NSLog(@"Error while invoking App Engine method: %@", e);
            apProxy = nil;
            return;
        }
    }
}

@end
