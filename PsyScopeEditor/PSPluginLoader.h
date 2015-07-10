//
//  PSPluginLoader.h
//  PsyScope Editor
//
//  Created by James on 09/07/2014.
//


#import <Cocoa/Cocoa.h>
#import "PSPluginInterface.h"

@interface PSPluginLoader : NSObject {
    NSMutableDictionary* pluginClasses;			
    

//keeps order 
    NSMutableArray* tools;			//	an array of tool plug-in classes
    NSMutableArray* events;			//	an array of event plug-in classes
    NSMutableArray* attributes;		//	an array of attribute plug-in classes
    NSMutableArray* windowViews;     //  an array of main window and left panel classes
    NSMutableArray* actions;
    NSMutableArray* conditions;
    
    NSMutableDictionary* bundlePaths;
}


-(NSArray*) getPluginClassNames;
-(NSArray*) instantiatePluginsOfType:(PSPluginType)pluginType;
-(NSString*) getBundlePathForPSExtension:(NSString*)name;


@end