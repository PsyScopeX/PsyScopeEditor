//
//  PSPluginInterface.h
//  PsyScopeEditor
//
//  Created by James on 15/07/2014.
//

#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSInteger, PSPluginType) {
    PSPluginTypeTool,
    PSPluginTypeEvent,
    PSPluginTypeAttribute,
    PSPluginTypeWindowView,
    PSPluginTypeAction,
    PSPluginTypeCondition
};

@protocol PSPluginInterface

//each plugin can have multiple extensions (so you dont need a new bundle each time you develop an extension

//	initializeClass: is called once when the plug-in is loaded. The plug-in's bundle is passed
//	as argument;

+ (BOOL)initializeClass:(NSBundle*)theBundle;

//	pluginsFor: returns strings of plugin names
+ (NSArray*)pluginsFor:(PSPluginType)pluginTypeName;

// instantiatePlugin: returns an object (this is not possible currently in swift)
+ (id)instantiatePlugin:(NSString*)pluginName;

//returns class of actual extension
+ (id)getPSExtensionClass:(NSString*)pluginName;


@end




