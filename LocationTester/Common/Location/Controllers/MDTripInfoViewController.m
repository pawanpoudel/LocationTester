//
//  MDTripInfoViewController.m
//  LocationTester
//
//  Created by PAWAN POUDEL on 10/19/12.
//  Copyright (c) 2012 Mobile Defense Inc. All rights reserved.
//

#import "MDTripInfoViewController.h"
#import "MDTrip.h"

@interface MDTripInfoViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *rowItems;
@property (strong, nonatomic) NSArray *sectionItems;
@property (strong, nonatomic) NSMutableArray *tripAttributeValues;

@end

@implementation MDTripInfoViewController

#pragma mark - Accessors

- (NSArray *)rowItems {
    if (_rowItems) {
        return _rowItems;
    }
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"tripInfoRowItems" ofType:@"plist"];
    _rowItems = [NSArray arrayWithContentsOfFile:filePath];
    return _rowItems;
}

- (NSArray *)sectionItems {
    if (_sectionItems) {
        return _sectionItems;
    }
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"tripInfoSectionItems" ofType:@"plist"];
    _sectionItems = [NSArray arrayWithContentsOfFile:filePath];
    return _sectionItems;
}

- (NSMutableArray *)tripAttributeValues {
    if (_tripAttributeValues) {
        return _tripAttributeValues;
    }
    
    _tripAttributeValues = [@[] mutableCopy];
    return _tripAttributeValues;
}

#pragma mark - View lifecycle

- (void)buildTripKeyValues {
    NSEntityDescription *entity = [self.trip entity];
    NSDictionary *attributes = [entity attributesByName];
    
    [[attributes allKeys] enumerateObjectsUsingBlock:^(NSString *attributeName, NSUInteger index, BOOL *stop) {
        SEL selector = NSSelectorFromString(attributeName);
        id attributeValue = [self.trip performSelector:selector];
        
        NSString *attributeDescription = [attributeValue description];
        self.tripAttributeValues[index] = attributeDescription;
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Trip Info";
    [self buildTripKeyValues];
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

- (void)useTripForReplay {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.trip.uniqueID forKey:@"uniqueIDOfChosenTrip"];
}

#pragma mark - Table View methods

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
    if (indexPath.section == 0) {
        cell.detailTextLabel.text = self.tripAttributeValues[indexPath.row];
    }
    else {
        cell.detailTextLabel.text = menuItem[@"detailText"];
        cell.detailTextLabel.textAlignment = UITextAlignmentCenter;
    }
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"TestingToolMenuItemCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:cellIdentifier];
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
