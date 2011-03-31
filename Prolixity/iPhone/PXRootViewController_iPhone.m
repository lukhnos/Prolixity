//
// PXRootViewController_iPhone.m
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

#import "PXRootViewController_iPhone.h"
#import "PXAppDelegate_iPhone.h"
#import "PXSnippetEditorViewController_iPhone.h"
#import "PXSnippetManager.h"
#import "PXUtilities.h"

@interface PXRootViewController_iPhone ()
- (IBAction)addSnippetAction;
@end

@implementation PXRootViewController_iPhone

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = PXLSTR(@"Snippets");    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addSnippetAction)] autorelease];                                        
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableView:) name:PXSnippetManagerDidUpdateNotification object:nil];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
    		
}
		
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[PXSnippetManager sharedManager] snippetCount];
    		
}

		
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *const defaultCellID = @"DefaultCell";
    static NSString *const descriptiveCellID = @"DescriptiveCell";
    
    UITableViewCell *cell = nil;
    
    NSString *identifier = [[PXSnippetManager sharedManager] snippetIDAtIndex:indexPath.row];
    NSString *title = [[PXSnippetManager sharedManager] snippetTitleForID:identifier];
    NSString *description = [[PXSnippetManager sharedManager] snippetDescriptionForID:identifier];

    if ([description length] > 0) {        
        cell = [tableView dequeueReusableCellWithIdentifier:descriptiveCellID];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:descriptiveCellID] autorelease];            
        }
        
        cell.detailTextLabel.text = description;
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:defaultCellID];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:defaultCellID] autorelease];            
        }
    }
    
    cell.textLabel.text = title;    		
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self selectSnippetIndex:indexPath.row];
}

- (IBAction)addSnippetAction
{
    NSString *identifier = [[PXSnippetManager sharedManager] createSnippet];    
    NSUInteger index = [[PXSnippetManager sharedManager] indexForSnippetID:identifier];
    [self selectSnippetIndex:index];
}

- (void)selectSnippetIndex:(NSUInteger)index
{
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];

    NSString *identifier = [[PXSnippetManager sharedManager] snippetIDAtIndex:index];
    
    PXSnippetEditorViewController_iPhone *editor = [[PXSnippetEditorViewController_iPhone alloc] initWithNibName:@"PXSnippetEditorViewController_iPhone" bundle:nil];
    editor.currentSnippetIdentifier = identifier;
    [self.navigationController pushViewController:editor animated:YES];
    [editor release];
}

- (void)reloadTableView:(NSNotification *)notification
{
    [self.tableView reloadData];
}
@end
