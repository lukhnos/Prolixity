//
//  ProlixityAppDelegate.m
//  Prolixity
//
//  Created by Lukhnos D. Liu on 2/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ProlixityAppDelegate.h"

#import "RootViewController.h"
#import "PXLexicon.h"

@implementation ProlixityAppDelegate


@synthesize window=_window;

@synthesize splitViewController=_splitViewController;

@synthesize rootViewController=_rootViewController;

@synthesize detailViewController=_detailViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    /*
    PXLexicon *cl = [[PXLexicon alloc] init];

    [cl build:[NSArray arrayWithObjects:@"init", @"With", @"String:", @"encoding:", nil]];

    [cl build:[NSArray arrayWithObjects:@"initWithString:", @"encoding:", nil]];
    
    NSLog(@"1 %@", [cl candidatesForLexemes:[NSArray arrayWithObjects:@"initWithString:", @"encoding:", nil]]);
    NSLog(@"2 %@", [cl candidatesForLexemes:[NSArray arrayWithObjects:@"initWithString:encoding:", nil]]);
    NSLog(@"3 %@", [cl candidatesForLexemes:[NSArray arrayWithObjects:@"initWithData:encoding:", nil]]);
    NSLog(@"4 %@", [cl candidatesForLexemes:[NSArray arrayWithObjects:@"initWithString:", nil]]);
    
    
    [cl release];
    */
    
    [PXLexicon addClass:[NSString class]];
    
    [PXLexicon addClass:[NSArray class]];
    
    /*
    NSLog(@"6 %@", [[PXLexicon methodLexicon] candidatesForLexemes:[NSArray arrayWithObjects:@"init", @"with", @"format:", @"arguments:", nil]]);
    NSLog(@"7 %@", [[PXLexicon classLexicon] candidatesForLexemes:[NSArray arrayWithObjects:@"ns", @"string", nil]]);
    */
    
    
    // Override point for customization after application launch.
    // Add the split view controller's view to the window and display.
    self.window.rootViewController = self.splitViewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    [_window release];
    [_splitViewController release];
    [_rootViewController release];
    [_detailViewController release];
    [super dealloc];
}

@end
