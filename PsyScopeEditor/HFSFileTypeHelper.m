//
//  HFSFileTypeHelper.m
//  PsyScopeEditor
//
//  Created by James on 09/07/2015.
//  Copyright © 2015 James. All rights reserved.
//

#import "HFSFileTypeHelper.h"

@implementation HFSFileTypeHelper

+(void) setTextFileAttribs:(NSString*)path {
    
    
    // Get file type and creator:
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error;
    NSDictionary *attr = [fm attributesOfItemAtPath:path error:&error];
    unsigned long type = [attr[NSFileHFSTypeCode] unsignedLongValue];
    unsigned long creator = [attr[NSFileHFSCreatorCode] unsignedLongValue];
    
    // Set a new type and creator:
    type = 'TEXT';
    creator = 'pdos';
    attr = @{NSFileHFSTypeCode : @(type)};
    [fm setAttributes:attr ofItemAtPath:path error:&error];
    
}
@end
