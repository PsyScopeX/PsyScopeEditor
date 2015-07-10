//
//  PSPluginLoader.m
//  PsyScope Editor
//
//  Created by James on 09/07/2014.
//


#import "PSPluginLoader.h"

@implementation PSPluginLoader


- (id)init {
    self = [super init];
    pluginClasses = [[NSMutableDictionary alloc] init];
   
    bundlePaths = [[NSMutableDictionary alloc] init];

    
    tools = [[NSMutableArray alloc] init];
    attributes = [[NSMutableArray alloc] init];
    events = [[NSMutableArray alloc] init];

    windowViews = [[NSMutableArray alloc] init];
    actions = [[NSMutableArray alloc] init];
    conditions = [[NSMutableArray alloc] init];
    
    //get plugin names and remember which PluginInterface they were associated with
    
    NSString* folderPath = [[NSBundle mainBundle] builtInPlugInsPath];
    if (folderPath) {
        //get all plugins in folder path
        NSEnumerator* enumerator = [[NSBundle pathsForResourcesOfType:@"psyplugin" inDirectory:folderPath] objectEnumerator];
        NSString* pluginPath;
        while ((pluginPath = [enumerator nextObject])) {
            //for each plugin get the principle class and use the class methods to get the actual plugins
            NSBundle* pluginBundle = [NSBundle bundleWithPath:pluginPath];
            if (pluginBundle) {
                NSDictionary* pluginDict = [pluginBundle infoDictionary];
                NSString* pluginName = [pluginDict objectForKey:@"NSPrincipalClass"];
                if (pluginName) {
                    Class pluginClass = NSClassFromString(pluginName);
                    if (!pluginClass) {
                        pluginClass = [pluginBundle principalClass];
                        if ([pluginClass conformsToProtocol:@protocol(PSPluginInterface)] && [pluginClass isKindOfClass:[NSObject class]]) {
                            //now get all class names from the interface, and instantiate objects with the class names as keys
                            
                            //TODO refactor
                            
                            NSArray* names = [pluginClass pluginsFor:PSPluginTypeTool];
                            [tools addObjectsFromArray:names];
                            for (id object in names) {
                                //this should just be strings in here
                                if ([object isKindOfClass:[NSString class]]) {
                                    NSString* name = (NSString *)object;
                                    [pluginClasses setObject:[pluginClass getPSExtensionClass:name] forKey:name];
                              
                                    [bundlePaths setObject:pluginPath forKey:name];
                                }
                                
                            }
                            
                            //now for attributes
                            
                            names = [pluginClass pluginsFor:PSPluginTypeAttribute];
                            [attributes addObjectsFromArray:names];
                            for (id object in names) {
                                //this should just be strings in here
                                if ([object isKindOfClass:[NSString class]]) {
                                    NSString* name = (NSString *)object;
                                    [pluginClasses setObject:[pluginClass getPSExtensionClass:name] forKey:name];
                                 
                                    [bundlePaths setObject:pluginPath forKey:name];
                                }
                                
                            }
                            
                            //now for events
                            
                            names = [pluginClass pluginsFor:PSPluginTypeEvent];
                            [events addObjectsFromArray:names];
                            for (id object in names) {
                                //this should just be strings in here
                                if ([object isKindOfClass:[NSString class]]) {
                                    NSString* name = (NSString *)object;
                                    [pluginClasses setObject:[pluginClass getPSExtensionClass:name] forKey:name];
                                 
                                    [bundlePaths setObject:pluginPath forKey:name];
                                }
                                
                            }
                            
                            //now for window views
                            names = [pluginClass pluginsFor:PSPluginTypeWindowView];
                            [windowViews addObjectsFromArray:names];
                            for (id object in names) {
                                //this should just be strings in here
                                if ([object isKindOfClass:[NSString class]]) {
                                    NSString* name = (NSString *)object;
                                    [pluginClasses setObject:[pluginClass getPSExtensionClass:name] forKey:name];
                            
                                    [bundlePaths setObject:pluginPath forKey:name];
                                }
                                
                            }
                            
                            //now for actions
                            names = [pluginClass pluginsFor:PSPluginTypeAction];
                            [actions addObjectsFromArray:names];
                            for (id object in names) {
                                //this should just be strings in here
                                if ([object isKindOfClass:[NSString class]]) {
                                    NSString* name = (NSString *)object;
                                    [pluginClasses setObject:[pluginClass getPSExtensionClass:name] forKey:name];
                               
                                    [bundlePaths setObject:pluginPath forKey:name];
                                }
                                
                            }
                            
                            //now for conditions
                            names = [pluginClass pluginsFor:PSPluginTypeCondition];
                            [conditions addObjectsFromArray:names];
                            for (id object in names) {
                                //this should just be strings in here
                                if ([object isKindOfClass:[NSString class]]) {
                                    NSString* name = (NSString *)object;
                                    [pluginClasses setObject:[pluginClass getPSExtensionClass:name] forKey:name];
                               
                                    [bundlePaths setObject:pluginPath forKey:name];
                                }
                                
                            }
                            
                            
                        }
                    }
                }
            }
        }
    }
    
    
    return self;
}

//	Scan the application's plug-in folder for plug-ins and try to activate them.

-(NSArray*)getPluginClassNames {

    return [pluginClasses allKeys];
}



-(NSArray*) instantiatePluginsOfType:(PSPluginType)pluginType {


    NSArray* selectedArray;
    
    switch (pluginType) {
        case PSPluginTypeTool:

            selectedArray = tools;
            break;
        case PSPluginTypeAttribute:
     
            selectedArray = attributes;
            break;
        case PSPluginTypeEvent:
        
            selectedArray = events;
            break;
        case PSPluginTypeWindowView:
         
            selectedArray = windowViews;
            break;
        case PSPluginTypeAction:
       
            selectedArray = actions;
            break;
        case PSPluginTypeCondition:
      
            selectedArray = conditions;
            break;
    }
    
    NSMutableArray* return_array = [[NSMutableArray alloc] init];
    
    for(id key in selectedArray) {
        Class extensionClass = [pluginClasses objectForKey: key];
        [return_array addObject:[[extensionClass alloc] init]];
    }
    
    return return_array;
}





                             
-(NSString*) getBundlePathForPSExtension:(NSString*)name {
    NSString* path = (NSString*) [bundlePaths objectForKey:name];
    return path;
}




@end
