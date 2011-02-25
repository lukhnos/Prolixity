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
#import "PXDetailViewController.h"

@implementation PXAppDelegate

@synthesize window;
@synthesize splitViewController;
@synthesize rootViewController;
@synthesize detailViewController;

- (void)dealloc
{
    [window release];
    [splitViewController release];
    [rootViewController release];
    [detailViewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window.rootViewController = self.splitViewController;
    [self.window makeKeyAndVisible];
    
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
    
    if ([[PXSnippetManager sharedManager] snippetCount] == 0) {
        NSString *identifier = nil;        
        identifier = [[PXSnippetManager sharedManager] createSnippet];
        [[PXSnippetManager sharedManager] setSnippetTitle:PXLSTR(@"Try It!") forSnippetID:identifier];
        [[PXSnippetManager sharedManager] setSnippet:@"-- try yours!\n" forSnippetID:identifier];                
    }

    self.detailViewController.currentSnippetIdentifier = [[PXSnippetManager sharedManager] snippetIDAtIndex:0];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [self.detailViewController saveCurrentSnippet];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self.detailViewController saveCurrentSnippet];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self.detailViewController saveCurrentSnippet];
}
@end
