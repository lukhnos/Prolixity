//
//  RootViewController.m
//  Prolixity
//
//  Created by Lukhnos D. Liu on 2/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PXRootViewController.h"
#import "PXDetailViewController.h"
#import "PXSnippetManager.h"
#import "PXRuntime.h"
#import "PXAppDelegate.h"

@interface PXRootViewController ()
- (IBAction)addSnippetAction;
@end

@implementation PXRootViewController
@synthesize detailViewController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    self.title = PXLSTR(@"Prolixity Snippets");
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addSnippetAction)] autorelease];                                        
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [[PXSnippetManager sharedManager] snippetIDAtIndex:indexPath.row];
    ((PXAppDelegate *)[[UIApplication sharedApplication] delegate]).detailViewController.currentSnippetIdentifier = identifier;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc
{
    [detailViewController release];
    [super dealloc];
}

- (IBAction)addSnippetAction
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}
@end
