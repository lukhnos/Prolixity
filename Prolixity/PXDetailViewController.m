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

static const NSTimeInterval kAutosaveInterval = 10.0;

@interface PXDetailViewController ()
@property (nonatomic, retain) UIPopoverController *popoverController;
- (void)configureView;
- (void)killPreviousDeferredSaveInvocation;
- (void)deferredSaveCurrentSnippet;
@end

@implementation PXDetailViewController

@synthesize currentSnippetIdentifier;
@synthesize toolbar;
@synthesize detailItem;
@synthesize popoverController;
@synthesize textView;
@synthesize innerView;
@synthesize evaluationResultViewController;

- (void)dealloc
{
    [errorAlertView release];
    [currentSnippetIdentifier release];
    [evaluationResultViewController release];
    [popoverController release];
    [toolbar release];
    [detailItem release];
    [textView release];
    [super dealloc];
}

- (IBAction)runAction
{    
    [[PXBlock currentConsoleBuffer] setString:@""];
    
    NSError *error = nil;
    PXBlock *__unused blk = [PXBlock blockWithSource:self.textView.text error:&error];
    
    if (error) {
        lastErrorLineNumber = NSNotFound;
        
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^Line (\\d+):" options:0 error:NULL];
        NSString *errDesc = [error localizedDescription];
        [regex enumerateMatchesInString:errDesc options:0 range:NSMakeRange(0, [errDesc length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            if (result.range.location != NSNotFound) {
                NSRange lineNoRange = [result rangeAtIndex:1];
                lastErrorLineNumber = [[errDesc substringWithRange:lineNoRange] integerValue];
            }
        }];
        
        NSString *buttonTitle = (lastErrorLineNumber == NSNotFound) ? PXLSTR(@"Dismiss") : PXLSTR(@"Edit");
        [[[[UIAlertView alloc] initWithTitle:PXLSTR(@"Error in code") message:errDesc delegate:self cancelButtonTitle:buttonTitle otherButtonTitles:nil] autorelease] show];
        return;
    }
    
    if (!self.evaluationResultViewController) {
        self.evaluationResultViewController = [[[PXEvaluationResultViewController alloc] initWithNibName:@"PXEvaluationResultViewController" bundle:nil] autorelease];        
    }
 
    self.evaluationResultViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:self.evaluationResultViewController animated:YES];
    self.evaluationResultViewController.evaluationCanvasView.source = self.textView.text;
    [self.evaluationResultViewController.evaluationCanvasView setNeedsDisplay];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (lastErrorLineNumber != NSNotFound) {
        [self highlightLine:lastErrorLineNumber];
    }
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil]; 
}

- (void)viewDidUnload
{
	[super viewDidUnload];

	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.popoverController = nil;    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];    
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
    [self saveCurrentSnippet];
    
    NSString *snippet = [[PXSnippetManager sharedManager] snippetForID:identifier];
    self.textView.text = snippet;
    PXRetainAssign(currentSnippetIdentifier, identifier);
}

- (void)killPreviousDeferredSaveInvocation
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(saveCurrentSnippet) object:nil];
}

- (void)deferredSaveCurrentSnippet
{
    [self killPreviousDeferredSaveInvocation];
    [self performSelector:@selector(saveCurrentSnippet) withObject:nil afterDelay:kAutosaveInterval];
}

- (void)saveCurrentSnippet
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self killPreviousDeferredSaveInvocation];
    if ([currentSnippetIdentifier length] > 0) {
        [[PXSnippetManager sharedManager] setSnippet:self.textView.text forSnippetID:currentSnippetIdentifier];
    }    
}

- (void)highlightLine:(NSUInteger)lineNumber
{
    if (lineNumber == NSUIntegerMax) {
        return;
    }
    
    NSString *text = self.textView.text;
    NSUInteger pos = 0;
    NSUInteger len = [text length];
    NSUInteger lineIndex = 0;
    NSUInteger previousLinePos = 0;
    
    for (pos = 0 ;  pos < len ; pos++) {
        UniChar c = [text characterAtIndex:pos];
        if (c == '\n') {
            lineIndex++;
            
            if (lineIndex == lineNumber) {
                NSRange errorRange = NSMakeRange(previousLinePos, (pos + 1) - previousLinePos);
                self.textView.selectedRange = errorRange;
                [self.textView scrollRangeToVisible:errorRange];
                return;
            }
            else {
                previousLinePos = pos + 1;
            }
        }
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self deferredSaveCurrentSnippet];
}

- (BOOL)textViewShouldEndEditing:(UITextView *)aTextView
{
    [self.textView resignFirstResponder];
    return YES;
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    // from Apple sample code (KeyboardAccessory)

    /*
     Reduce the size of the text view so that it's not obscured by the keyboard.
     Animate the resize so that it's in sync with the appearance of the keyboard.
     */

    NSDictionary *userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.innerView convertRect:keyboardRect fromView:nil];
    
    CGFloat keyboardTop = keyboardRect.origin.y;
    CGRect newTextViewFrame = self.innerView.bounds;
    newTextViewFrame.size.height = keyboardTop - self.innerView.bounds.origin.y;
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    self.textView.frame = newTextViewFrame;
    
    [UIView commitAnimations];
}


- (void)keyboardWillHide:(NSNotification *)notification
{
    // from Apple sample code (KeyboardAccessory)
    
    NSDictionary* userInfo = [notification userInfo];
    
    /*
     Restore the size of the text view (fill self's view).
     Animate the resize so that it's in sync with the disappearance of the keyboard.
     */
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    self.textView.frame = self.innerView.bounds;
    
    [UIView commitAnimations];
}

@end
