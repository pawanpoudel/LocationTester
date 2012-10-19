//
//  MDTripListViewController.m
//  LocationTester
//
//  Created by PAWAN POUDEL on 10/19/12.
//  Copyright (c) 2012 Mobile Defense Inc. All rights reserved.
//

#import "MDTripListViewController.h"
#import "MDTripInfoViewController.h"
#import "MDDataManager.h"
#import "MDTrip.h"

@interface MDTripListViewController()
<NSFetchedResultsControllerDelegate, UISearchDisplayDelegate,
UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>
{
	// The saved state of the search UI if a memory warning removed the view.
    NSString *savedSearchTerm;
    NSInteger savedScopeButtonIndex;
    BOOL searchWasActive;
}

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) MDDataManager *dataManager;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *searchResultListContent;
@property (retain, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation MDTripListViewController

#pragma mark - Accessors

- (MDDataManager *)dataManager {
    return [MDDataManager sharedDataManager];
}

#pragma mark - View lifecycle

- (void)setupEditButton {
    // Set up the edit button
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *editButton = self.editButtonItem;
	[editButton setTarget:self];
	[editButton setAction:@selector(toggleEdit)];
	self.navigationItem.rightBarButtonItem = editButton;
}

- (void)fetchTrips {
	NSError *error;
	if (![self.fetchedResultsController performFetch:&error]) {
		// Update to handle the error appropriately.
		DebugLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Trips";
    
    [self setupEditButton];
    [self fetchTrips];
    
	// create a filtered list that will contain trips for the search results table.
	self.searchResultListContent = [NSMutableArray arrayWithCapacity:[[self.fetchedResultsController fetchedObjects] count]];
    
	// restore search settings if they were saved in didReceiveMemoryWarning.
    if (savedSearchTerm) {
        [self.searchDisplayController setActive:searchWasActive];
        [self.searchDisplayController.searchBar setSelectedScopeButtonIndex:savedScopeButtonIndex];
        [self.searchDisplayController.searchBar setText:savedSearchTerm];
        
        savedSearchTerm = nil;
    }
 	self.tableView.scrollEnabled = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated {
    // Save the state of the search UI so that it can be restored if the view is re-created
    searchWasActive = [self.searchDisplayController isActive];
    savedSearchTerm = [self.searchDisplayController.searchBar text];
    savedScopeButtonIndex = [self.searchDisplayController.searchBar selectedScopeButtonIndex];
    
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload {
    [self.searchResultListContent removeAllObjects];
    self.searchResultListContent = nil;
    
    [super viewDidUnload];
}

#pragma mark - Actions

- (IBAction)toggleEdit {
	BOOL editing = !self.tableView.editing;
	self.navigationItem.rightBarButtonItem.title = (editing) ? @"Done" : @"Edit";
	[self.tableView setEditing:editing animated:YES];
}

#pragma mark - Content Filtering

- (void)filterContentForSearchText:(NSString *)searchText {
    // Update search results array based on the search text
    // First clear the search results from previous run
    [self.searchResultListContent removeAllObjects];
    
    for (MDTrip *trip in [self.fetchedResultsController fetchedObjects]) {
        NSComparisonResult result = [trip.name compare:searchText
                                               options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)
                                                 range:NSMakeRange(0, searchText.length)];
        if (result == NSOrderedSame) {
            [self.searchResultListContent addObject:trip];
        }
    }
}

#pragma mark - UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

#pragma mark - Table view methods

/*
 The data source methods are handled primarily by the fetch results controller
 */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    }
    else {
        NSInteger numberOfSections = [self.fetchedResultsController.sections count];
        if (numberOfSections > 0) {
            return numberOfSections;
        }
        
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
	if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.searchResultListContent count];
    }
	else {
        NSArray *sections = [self.fetchedResultsController sections];
        id <NSFetchedResultsSectionInfo> sectionInfo = sections[section];
        return [sectionInfo numberOfObjects];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{   
    static NSString *CellIdentifier = @"DefaultTripCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
        
    MDTrip *trip = nil;
    
	if (tableView == self.searchDisplayController.searchResultsTableView) {
        trip = self.searchResultListContent[indexPath.row];
    }
	else {
        trip = [self.fetchedResultsController objectAtIndexPath:indexPath];
    }
	
	cell.textLabel.text = trip.name;
	return cell;
}

//- (NSString *)tableView:(UITableView *)tableView
//titleForHeaderInSection:(NSInteger)section
//{
//    if (tableView == self.searchDisplayController.searchResultsTableView) {
//        return nil;
//    }
//    else {
//        return [[[self.fetchedResultsController sections] objectAtIndex:section] name];
//    }
//}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
		[context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
		
		NSError *error;
		if (![context save:&error]) {
			DebugLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
		}
    }
}

#pragma mark - Table view selection and moving methods

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If the requesting table view is the search display controller's table view
    // configure the next view controller using the filtered content,
    // otherwise use the main list.
    
    MDTrip *selectedTrip = nil;
    
	if (tableView == self.searchDisplayController.searchResultsTableView) {
        selectedTrip = [self.searchResultListContent objectAtIndex:indexPath.row];
    }
	else {
        selectedTrip = [self.fetchedResultsController objectAtIndexPath:indexPath];
    }
    
    // Create and push a trip info view controller.
    MDTripInfoViewController *tripInfoViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MDTripInfoViewController"];
    tripInfoViewController.trip = selectedTrip;
    [self.navigationController pushViewController:tripInfoViewController animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;
}

#pragma mark - Fetched results controller

/**
 Returns the fetched results controller. Creates and configures the controller if necessary.
 */
- (NSFetchedResultsController *)fetchedResultsController {    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
	// Create and configure a fetch request
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"MDTrip"
                                              inManagedObjectContext:self.dataManager.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Create the sort descriptors array.
	NSSortDescriptor *tripStartTimeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"tripStartTime"
                                                                            ascending:YES];
	[fetchRequest setSortDescriptors:@[tripStartTimeDescriptor]];
	
	// Create and initialize the fetch results controller.
	_fetchedResultsController = [[NSFetchedResultsController alloc]
                                                             initWithFetchRequest:fetchRequest
                                                             managedObjectContext:self.dataManager.managedObjectContext
                                                             sectionNameKeyPath:nil
                                                             cacheName:@"MDTrip"];

	_fetchedResultsController.delegate = self;		
	return _fetchedResultsController;
}

/**
 Delegate methods of NSFetchedResultsController to respond to additions, removals and so on.
 */

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	// The fetch controller is about to start sending change notifications, so prepare the table view for updates.
	[self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
	UITableView *tableView = self.tableView;
    
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeUpdate: {
            // Configure the cell to show the Concept's abbreviation
            MDTrip *trip = [self.fetchedResultsController objectAtIndexPath:indexPath];
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.textLabel.text = trip.name;
        } break;
			
		case NSFetchedResultsChangeMove:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{	
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	// Fetch controller has sent all current change notifications,
    // so tell the table view to process all updates.
	[self.tableView endUpdates];
}

@end
