//
//  MDTestingToolsViewController.m
//  MobileDefense
//
//  Created by PAWAN POUDEL on 10/18/12.
//  Copyright (c) 2012 Mobile Defense Inc. All rights reserved.
//

#import "MDTestingToolsViewController.h"
#import "ECSlidingViewController.h"

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

- (void)recordTrip {
    
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
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"TestingToolMenuItemCell";
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

