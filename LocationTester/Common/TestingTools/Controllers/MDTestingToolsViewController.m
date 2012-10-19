//
//  MDTestingToolsViewController.m
//  LocationTester
//
//  Created by PAWAN POUDEL on 10/18/12.
//  Copyright (c) 2012 Mobile Defense Inc. All rights reserved.
//


#import "MDTestingToolsViewController.h"
#import "MDRecordTripViewController.h"
#import "MDTripListViewController.h"

@interface MDTestingToolsViewController() <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *rowItems;
@property (strong, nonatomic) NSArray *sectionItems;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MDTestingToolsViewController

#pragma mark - Accessors

- (NSArray *)rowItems {
    if (_rowItems) {
        return _rowItems;
    }
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"testingToolsRowItems" ofType:@"plist"];
    _rowItems = [NSArray arrayWithContentsOfFile:filePath];
    return _rowItems;
}

- (NSArray *)sectionItems {
    if (_sectionItems) {
        return _sectionItems;
    }
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"testingToolsSectionItems" ofType:@"plist"];
    _sectionItems = [NSArray arrayWithContentsOfFile:filePath];
    return _sectionItems;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Testing Tools";
    
    // Add menu button
    UIBarButtonItem *navButton = [[UIBarButtonItem alloc] initWithTitle:@"Menu"
                                                                  style:UIBarButtonItemStyleBordered
                                                                 target:self
                                                                 action:@selector(revealMenu:)];
    self.navigationItem.leftBarButtonItem = navButton;    
}

- (void)viewDidUnload {
    [self setRowItems:nil];
    [self setSectionItems:nil];
    [self setTableView:nil];
    
    [super viewDidUnload];
}

#pragma mark - Actions

- (IBAction)revealMenu:(id)sender {
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (void)showViewForRecordingTrip {
    MDRecordTripViewController *recordTripViewController = [[MDRecordTripViewController alloc] init];
    [self.navigationController pushViewController:recordTripViewController animated:YES];
}

- (void)showTripList {
    MDTripListViewController *tripListViewController = [[MDTripListViewController alloc] init];
    [self.navigationController pushViewController:tripListViewController animated:YES];
}

- (void)locationSimulationSwitchValueChanged:(UISwitch *)locationSwitch {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:locationSwitch.on forKey:kMDLocationSimulationTurnedOn];
}

#pragma mark - Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.rowItems.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex {
    return [self.rowItems[sectionIndex] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSDictionary *sectionItem = [self.sectionItems objectAtIndex:section];
    return sectionItem[@"title"];
}

- (UITableViewCell *)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *menuItem = self.rowItems[indexPath.section][indexPath.row];
    
    cell.imageView.image = [UIImage imageNamed:menuItem[@"imageName"]];
    
    cell.textLabel.text = menuItem[@"text"];    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (indexPath.section == 1) {
        UISwitch *locationSimulationSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [locationSimulationSwitch addTarget:self
                                     action:@selector(locationSimulationSwitchValueChanged:)
                           forControlEvents:UIControlEventValueChanged];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        locationSimulationSwitch.on = [defaults boolForKey:kMDLocationSimulationTurnedOn];
        
        cell.accessoryView = locationSimulationSwitch;
    }
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"TestingToolsMenuItemCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    return [self configureCell:cell atIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *menuItem = self.rowItems[indexPath.section][indexPath.row];
    
    SEL selector = NSSelectorFromString(menuItem[@"selector"]);
    if (selector) {
        [self performSelector:selector];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
 }

@end

