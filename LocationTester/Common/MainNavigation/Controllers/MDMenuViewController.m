//
//  MDMenuViewController.m
//  LocationTester
//
//  Created by PAWAN POUDEL on 10/18/12.
//  Copyright (c) 2012 Mobile Defense Inc. All rights reserved.
//


#import "MDMenuViewController.h"
#import "MDSlidingNavigationController.h"

@interface MDMenuViewController ()
@property (nonatomic, strong) NSArray *menuItems;
@property (weak, nonatomic) IBOutlet UITableView *menuTableView;
@end

@implementation MDMenuViewController

#pragma mark - Accessors

- (NSArray *)menuItems {
    if (_menuItems) {
        return _menuItems;
    }
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"menuItems" ofType:@"plist"];
    NSMutableArray *navItems = [NSMutableArray arrayWithContentsOfFile:path];
        
    _menuItems = [NSArray arrayWithArray:navItems];
    return _menuItems;
}

#pragma mark - View lifecycle methods

- (void)viewDidLoad {
    [super viewDidLoad];    
    [self.slidingViewController setAnchorRightRevealAmount:280.0f];
    self.slidingViewController.underLeftWidthLayout = ECFullWidth;
}

- (void)viewDidUnload {
    [self setMenuItems:nil];
    [self setMenuTableView:nil];
    [super viewDidUnload];
}

#pragma mark - Actions

- (void)reload {
    [self.menuTableView reloadData];
}

#pragma mark - Table view methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex {
    return self.menuItems.count;
}

- (UITableViewCell *)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *menuItem = [self.menuItems objectAtIndex:indexPath.row];
    
    UIImage *image = [UIImage imageNamed:[menuItem objectForKey:@"imageName"]];
    if (image) {
        cell.imageView.image = image;
    }
    
    cell.textLabel.text = [menuItem objectForKey:@"text"];
    cell.textLabel.textColor = [UIColor whiteColor];
    
    cell.detailTextLabel.text = [menuItem objectForKey:@"detailText"];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bgMenuCell.png"]];
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bgMenuCellHighlighted.png"]];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"MenuItemCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    return [self configureCell:cell atIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *menuItem = self.menuItems[indexPath.row];
    Class NewTopViewControllerClass = NSClassFromString(menuItem[@"viewController"]);
    
    if (NewTopViewControllerClass) {
        UIViewController *newTopViewController = [[NewTopViewControllerClass alloc] init];
        
        MDSlidingNavigationController *newTopNavController = [[MDSlidingNavigationController alloc]
                                                              initWithRootViewController:newTopViewController];
        
        [self.slidingViewController anchorTopViewOffScreenTo:ECRight
                                                  animations:nil
                                                  onComplete:^{
                                                      CGRect frame = self.slidingViewController.topViewController.view.frame;
                                                      self.slidingViewController.topViewController = newTopNavController;
                                                      self.slidingViewController.topViewController.view.frame = frame;
                                                      [self.slidingViewController resetTopView];
                                                  }];
    }    
}

@end
