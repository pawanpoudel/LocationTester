//
//  MDSlidingNavigationController.m
//  LocationTester
//
//  Created by PAWAN POUDEL on 10/18/12.
//  Copyright (c) 2012 Mobile Defense Inc. All rights reserved.
//

#import "ECSlidingViewController.h"
#import "MDSlidingNavigationController.h"
#import "MDMenuViewController.h"

@implementation MDSlidingNavigationController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
        
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[MDMenuViewController class]]) {
        self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"MDMenuViewController"];
    }
    
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
}

@end
