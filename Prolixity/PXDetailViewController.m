//
// PXDetailViewController.m
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

#import "PXDetailViewController.h"
#import "PXRootViewController.h"
#import "PXRuntime.h"
#import "PXSnippetManager.h"

@interface PXDetailViewController ()
@property (nonatomic, retain) UIPopoverController *popoverController;
- (void)configureView;
@end

@implementation PXDetailViewController

@synthesize currentSnippetIdentifier;
@synthesize toolbar;
@synthesize detailItem;
@synthesize popoverController;
@synthesize textView;
@synthesize evaluationResultViewController;

- (IBAction)runAction
{    
    [[PXBlock currentConsoleBuffer] setString:@""];
    
    NSLog(@"source: %@", self.textView.text);
    
    /*
    PXBlock *blk = [PXBlock blockWithSource:self.textView.text];
    if (blk) {
        [blk runWithParent:nil];
    }
    */
    if (!self.evaluationResultViewController) {
        self.evaluationResultViewController = [[[PXEvaluationResultViewController alloc] initWithNibName:@"PXEvaluationResultViewController" bundle:nil] autorelease];        
    }
 
    self.evaluationResultViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:self.evaluationResultViewController animated:YES];
    
    self.evaluationResultViewController.evaluationCanvasView.source = self.textView.text;

    [self.evaluationResultViewController.evaluationCanvasView setNeedsDisplay];
    
//    self.evaluationResultViewController.evaluationCanvasView.textView.text = [PXBlock currentConsoleBuffer];
}

#pragma mark - Managing the detail item

/*
 When setting the detail item, update the view and dismiss the popover controller if it's showing.
 */
- (void)setDetailItem:(id)newDetailItem
{
    if (detailItem != newDetailItem) {
        [detailItem release];
        detailItem = [newDetailItem retain];
        
        // Update the view.
        [self configureView];
    }

    if (self.popoverController != nil) {
        [self.popoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    // Update the user interface for the detail item.
    // self.detailDescriptionLabel.text = [self.detailItem description];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Split view support

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController: (UIPopoverController *)pc
{
    barButtonItem.title = @"Snippets";
    NSMutableArray *items = [[self.toolbar items] mutableCopy];
    [items insertObject:barButtonItem atIndex:0];
    [self.toolbar setItems:items animated:YES];
    [items release];
    self.popoverController = pc;
}

// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    NSMutableArray *items = [[self.toolbar items] mutableCopy];
    [items removeObjectAtIndex:0];
    [self.toolbar setItems:items animated:YES];
    [items release];
    self.popoverController = nil;
}

/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
 */

- (void)viewDidUnload
{
	[super viewDidUnload];

	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.popoverController = nil;
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)setCurrentSnippetIdentifier:(NSString *)identifier
{
    NSString *snippet = [[PXSnippetManager sharedManager] snippetForID:identifier];
    self.textView.text = snippet;
    PXRetainAssign(currentSnippetIdentifier, identifier);
}

- (void)dealloc
{
    [currentSnippetIdentifier release];
    [evaluationResultViewController release];
    [popoverController release];
    [toolbar release];
    [detailItem release];
    [textView release];
    [super dealloc];
}

@end
