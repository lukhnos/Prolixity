//
// PXAppDelegate_iPad.m
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

#import "PXAppDelegate_iPad.h"
#import "PXRootViewController_iPad.h"
#import "PXEvaluationCanvasView.h"
#import "PXDetailViewController.h"

@implementation PXAppDelegate_iPad
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
    if (![super application:application didFinishLaunchingWithOptions:launchOptions]) {
        return NO;
    }
    
    self.window.rootViewController = self.splitViewController;
    [self.window makeKeyAndVisible];

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
