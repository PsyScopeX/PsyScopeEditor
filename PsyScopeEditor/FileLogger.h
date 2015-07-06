//
//  FileLogger.h
//  PsyScopeX
//
//  Created by James on 25/11/2014.
//  Copyright (c) 2014 SISSA/ISAS Trieste. All rights reserved.
//

#import <Foundation/Foundation.h>

#if DEBUG
#   define DebugNSLog(args...) _Log(@"DEBUG ", __FILE__,__LINE__,__PRETTY_FUNCTION__,args);
#else
#   define DebugNSLog(...)
#endif


//Logs simultaneously to console and to a file, so logging can be recorded of both processes
@interface Log : NSObject

void _Log(NSString *prefix, const char *file, int lineNumber, const char *funcName, NSString *format,...);
@end

