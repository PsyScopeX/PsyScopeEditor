//
//  DOManager.h
//  DOTest
//
//  Created by luca on 03/11/2014.
//  Copyright (c) 2014 luca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GraphicCommProtocol.h"
#import "DistributedObj.h"

@interface DOManager : NSObject <GuiManagerProtocol> {
@private
    LocalDistributedObj *gui;
    RemoteDistributedObj *ae;
}

-(RemoteDistributedObj*) setAppEngineProxy;
@property (nonatomic, weak) id delegate;

@end
