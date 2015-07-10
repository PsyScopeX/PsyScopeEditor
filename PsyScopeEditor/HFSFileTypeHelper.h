//
//  HFSFileTypeHelper.h
//  PsyScopeEditor
//
//  Created by James on 09/07/2015.
//  Copyright © 2015 James. All rights reserved.
//

//This is used to set the dinosaur HFS file attributes, so old PsyScope can load the files without having a hissy fit
#import <Foundation/Foundation.h>

@interface HFSFileTypeHelper : NSObject
+(void) setTextFileAttribs:(NSString*)path;
@end
