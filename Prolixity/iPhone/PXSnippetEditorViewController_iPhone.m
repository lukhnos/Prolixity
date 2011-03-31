//
//  PXSnippetEditorViewController_iPhone.m
//  Prolixity
//
//  Created by Lukhnos D. Liu on 3/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PXSnippetEditorViewController_iPhone.h"
#import "PXRuntime.h"
#import "PXSnippetManager.h"
#import "PXUtilities.h"

// TODO: Make this a shared constatnt
static const NSTimeInterval kAutosaveInterval = 10.0;


@interface PXSnippetEditorViewController_iPhone ()
- (IBAction)runAction;
- (void)killPreviousDeferredSaveInvocation;
- (void)deferredSaveCurrentSnippet;
- (void)saveCurrentSnippet;
- (void)highlightLine:(NSUInteger)lineNumber;
@end


@implementation PXSnippetEditorViewController_iPhone
@synthesize evaluationResultViewController;
@synthesize currentSnippetIdentifier;

- (void)dealloc
{    
    [evaluationResultViewController release];    
    [currentSnippetIdentifier release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:PXLSTR(@"Run") style:UIBarButtonItemStylePlain target:self action:@selector(runAction)] autorelease];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    if (self.currentSnippetIdentifier) {
        self.title = [[PXSnippetManager sharedManager] snippetTitleForID:self.currentSnippetIdentifier];
        self.textView.text = [[PXSnippetManager sharedManager] snippetForID:self.currentSnippetIdentifier];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil]; 
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [self saveCurrentSnippet];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
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


// from Apple sample code UICatalog
- (void)keyboardWillShow:(NSNotification *)aNotification 
{
	// the keyboard is showing so resize the table's height
	CGRect keyboardRect = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval animationDuration =
	[[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect frame = self.view.frame;
    frame.size.height -= keyboardRect.size.height;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.view.frame = frame;
    [UIView commitAnimations];
}

// from Apple sample code UICatalog
- (void)keyboardWillHide:(NSNotification *)aNotification
{
    // the keyboard is hiding reset the table's height
	CGRect keyboardRect = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval animationDuration =
	[[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect frame = self.view.frame;
    frame.size.height += keyboardRect.size.height;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.view.frame = frame;
    [UIView commitAnimations];
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (lastErrorLineNumber != NSNotFound) {
        [self highlightLine:lastErrorLineNumber];
    }
}

#pragma mark Private methods

- (UITextView *)textView
{
    return (UITextView *)self.view;
}

- (IBAction)runAction
{
    [self saveCurrentSnippet];
    
    [[PXBlock currentConsoleBuffer] setString:@""];
    
    NSError *error = nil;
    PXBlock *blk = [PXBlock blockWithSource:self.textView.text error:&error];
    
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
        self.evaluationResultViewController = [[[PXEvaluationResultViewController alloc] initWithNibName:@"PXEvaluationResultViewController_iPhone" bundle:nil] autorelease];
        
        // load the view
        [self.evaluationResultViewController view];
    }

    self.evaluationResultViewController.evaluationCanvasView.block = blk;
    [self.evaluationResultViewController.evaluationCanvasView setNeedsDisplay];
    [self.navigationController pushViewController:self.evaluationResultViewController animated:YES];
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
    [self killPreviousDeferredSaveInvocation];
    if ([self.currentSnippetIdentifier length] > 0) {
        [[PXSnippetManager sharedManager] setSnippet:self.textView.text forSnippetID:self.currentSnippetIdentifier];
    }    
}

// TODO: Share this part wth PXDetailViewController
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
@end
