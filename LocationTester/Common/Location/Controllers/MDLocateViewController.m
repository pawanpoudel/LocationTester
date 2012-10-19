//
//  MDLocateViewController.m
//  LocationTester
//
//  Created by PAWAN POUDEL on 10/18/12.
//  Copyright (c) 2012 Mobile Defense Inc. All rights reserved.
//

#import "MDLocateViewController.h"

@implementation MDLocateViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Locate";
    
    // Add menu button
    UIBarButtonItem *navButton = [[UIBarButtonItem alloc] initWithTitle:@"Menu"
                                                                  style:UIBarButtonItemStyleBordered
                                                                 target:self
                                                                 action:@selector(revealMenu:)];
    self.navigationItem.leftBarButtonItem = navButton;
}

#pragma mark - Actions

- (IBAction)revealMenu:(id)sender {
  [self.slidingViewController anchorTopViewTo:ECRight];
}

@end