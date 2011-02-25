//
// PXAppDelegate.m
//
// Copyright (c) 2011 Lukhnos D. Liu (http://lukhnos.org)
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//

#import "PXAppDelegate.h"
#import "PXRootViewController.h"
#import "PXLexicon.h"
#import "PXEvaluationCanvasView.h"
#import "PXRuntime.h"
#import "PXSnippetManager.h"

@implementation PXAppDelegate
@synthesize window;
@synthesize splitViewController;
@synthesize rootViewController;
@synthesize detailViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [PXLexicon addClass:[NSString class]];    
    [PXLexicon addClass:[NSNumber class]];    
    [PXLexicon addClass:[NSArray class]];
    [PXLexicon addClass:[NSMutableArray class]];    
    [PXLexicon addClass:[NSMutableDictionary class]];    
    [PXLexicon addClass:[NSDictionary class]];    
    [PXLexicon addClass:[PXEvaluationCanvasView class]];

    if ([PXSnippetManager sharedManager].firstTimeUser) {
        
        NSString *testBedCode = @"var dict\n"
        @"save to dict, map 100, to 200\n"
        @"on dict, invoke dump\n"
        @"\n"
        @"save to dict, map \"abcd\", to point 100, 200\n"
        @"on dict, invoke dump\n"
        @"\n"
        @"var a\n"
        @"save to a, 0\n"
        @"\n"
        @"var b\n"
        @"save to b, 10\n"
        @"\n"
        @"var c\n"
        @"save to c, \"hello, world!\\nand another line\"\n"
        @"on c, invoke dump\n"
        @"\n"
        @"begin... on a, invoke lt, taking b ...end\n"
        @"invoke whileTrue, taking begin... on a, invoke dump. on a, invoke plus, taking 1. save to a. ...end\n"
        @"\n"
        @"\n"
        @"var d\n"
        @"save to d, on canvas, invoke some point\n"
        @"on d, invoke dump\n"
        @"\n"
        @"var e\n"
        @"e = point 100, 100\n"
        @"on e, invoke dump\n"
        @"\n"
        @"var f\n"
        @"f = 10\n"
        @"var g\n"
        @"g = 10\n"
        @"e = point f, g\n"
        @"on e, invoke dump\n"
        @"\n"
        @"on \"start testing\", invoke dump\n"
        @"on canvas, invoke set some point, taking e\n"
        @"save to d, on canvas, invoke some point\n"
        @"on d, invoke dump\n"
        @"\n"
        @"begin... on f, invoke lt, taking 200 ...end\n"
        @"invoke whileTrue, taking begin...\n"
        @"	f = f + 20\n"
        @"	g = f\n"
        @"	e = point f, g\n"
        @"	on canvas, invoke set some point, taking e\n"
        @"...end\n";        
        
        NSString *identifier = nil;
        
        identifier = [[PXSnippetManager sharedManager] createSnippet];
        [[PXSnippetManager sharedManager] setSnippetTitle:PXLSTR(@"Hello, world!") forSnippetID:identifier];
        [[PXSnippetManager sharedManager] setSnippetDescription:PXLSTR(@"Explains what Prolixity is") forSnippetID:identifier];
        [[PXSnippetManager sharedManager] setSnippet:@"-- the first program\n"
                                         @"var x\n"
                                         @"save to x, \"hello, world!\"\n"
                                         @"on x, invoke dump\n"
                                        forSnippetID:identifier];


        identifier = [[PXSnippetManager sharedManager] createSnippet];
        [[PXSnippetManager sharedManager] setSnippetTitle:PXLSTR(@"A Simple Loop") forSnippetID:identifier];
        [[PXSnippetManager sharedManager] setSnippetDescription:PXLSTR(@"Basic syntax") forSnippetID:identifier];
        [[PXSnippetManager sharedManager] setSnippet:@"-- the second program\n"
                                         @"var x\n"
                                         @"save to x, \"hello, world!\"\n"
                                         @"on x, invoke dump\n"
                                        forSnippetID:identifier];

        identifier = [[PXSnippetManager sharedManager] createSnippet];
        [[PXSnippetManager sharedManager] setSnippetTitle:PXLSTR(@"Test Bed Code") forSnippetID:identifier];
        [[PXSnippetManager sharedManager] setSnippetDescription:PXLSTR(@"lorem ipsum") forSnippetID:identifier];
        [[PXSnippetManager sharedManager] setSnippet:testBedCode forSnippetID:identifier];
        
        
        identifier = [[PXSnippetManager sharedManager] createSnippet];
        [[PXSnippetManager sharedManager] setSnippetTitle:PXLSTR(@"Try It!") forSnippetID:identifier];
        [[PXSnippetManager sharedManager] setSnippet:@"-- try yours!\n" forSnippetID:identifier];

        [[PXSnippetManager sharedManager] markFirstTimeDataAsPopulated];
    }
    
    
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
    [window release];
    [splitViewController release];
    [rootViewController release];
    [detailViewController release];
    [super dealloc];
}

@end
