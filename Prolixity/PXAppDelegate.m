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

NS_INLINE void PXLoadExample(NSString *principalName, NSString *title, NSString *description)
{
    NSURL *resource = [[NSBundle mainBundle] URLForResource:principalName withExtension:@"px" subdirectory:@"Examples"];
    if (!resource) {
        return;
    }
    
    NSString *content = [NSString stringWithContentsOfURL:resource encoding:NSUTF8StringEncoding error:NULL];
    if (!content) {
        return;
    }
    
    NSString *identifier = nil;
    
    identifier = [[PXSnippetManager sharedManager] createSnippet];
    [[PXSnippetManager sharedManager] setSnippetTitle:title forSnippetID:identifier];
    
    if ([description length] > 0) {
        [[PXSnippetManager sharedManager] setSnippetDescription:description forSnippetID:identifier];
    }
    
    [[PXSnippetManager sharedManager] setSnippet:content forSnippetID:identifier];    
}

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
    [PXLexicon addClass:[NSMutableString class]];
    [PXLexicon addClass:[NSNumber class]];    
    [PXLexicon addClass:[NSArray class]];
    [PXLexicon addClass:[NSMutableArray class]];    
    [PXLexicon addClass:[NSMutableDictionary class]];    
    [PXLexicon addClass:[NSDictionary class]];

    [PXLexicon addClass:[UIColor class]];
    [PXLexicon addClass:[UIBezierPath class]];

    
    [PXLexicon addClass:[PXEvaluationCanvasView class]];
    

    if ([PXSnippetManager sharedManager].firstTimeUser) {
        PXLoadExample(@"hello", @"Hello, world!", @"Explains what Prolixity is");
        PXLoadExample(@"basics", @"Basics", @"Basic syntax");
        PXLoadExample(@"invocations", @"Invocations", @"Invoking Objective-C methods");
        PXLoadExample(@"objects", @"Objects", @"Objects supported in Prolixity");        
        PXLoadExample(@"loop", @"Loops and Branches", @"The control structures");

        PXLoadExample(@"canvas", @"Canvas", @"Simple canvas graphics");
        PXLoadExample(@"uikitgraphics", @"UIKit Graphics", @"Integration with UIKit");
        
        PXLoadExample(@"smalltalkish", @"Smalltalkish", @"Inside Prolixity");
        PXLoadExample(@"about", @"About Prolixity", @"Copyright, tidbits, etc.");

        PXLoadExample(@"yourcode", @"Try It!", nil);
    }
    
    if ([[PXSnippetManager sharedManager] snippetCount] == 0) {
        PXLoadExample(@"yourcode", @"Try It!", nil);
    }

    self.detailViewController.currentSnippetIdentifier = [[PXSnippetManager sharedManager] snippetIDAtIndex:0];
    [self.rootViewController selectSnippetIndex:0];
    
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
