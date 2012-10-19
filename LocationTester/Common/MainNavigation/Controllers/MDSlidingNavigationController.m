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
        
    // shadowPath, shadowOffset, and rotation is handled by ECSlidingViewController.
    // Just set the opacity, radius, and color here.
    self.view.layer.shadowOpacity = 0.75f;
    self.view.layer.shadowRadius = 10.0f;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[MDMenuViewController class]]) {
        self.slidingViewController.underLeftViewController = [[MDMenuViewController alloc] init];
    }
    
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
}


@end
