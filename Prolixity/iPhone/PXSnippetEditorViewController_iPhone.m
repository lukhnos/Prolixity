//
//  PXSnippetEditorViewController_iPhone.m
//  Prolixity
//
//  Created by Lukhnos D. Liu on 3/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PXSnippetEditorViewController_iPhone.h"
#import "PXAppDelegate_iPhone.h"
#import "PXUtilities.h"

// TODO: Make this a shared constatnt
static const NSTimeInterval kAutosaveInterval = 10.0;


@interface PXSnippetEditorViewController_iPhone ()
- (IBAction)runAction;
- (void)killPreviousDeferredSaveInvocation;
- (void)deferredSaveCurrentSnippet;
- (void)saveCurrentSnippet;
@end


@implementation PXSnippetEditorViewController_iPhone
@synthesize currentSnippetIdentifier;

- (void)dealloc
{    
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
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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

- (UITextView *)textView
{
    return (UITextView *)self.view;
}

- (IBAction)runAction
{
    
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
@end
