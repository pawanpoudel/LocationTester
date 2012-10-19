//
//  MDAppDelegate.m
//  LocationTester
//
//  Created by PAWAN POUDEL on 10/18/12.
//  Copyright (c) 2012 Mobile Defense Inc. All rights reserved.
//

#import "MDAppDelegate.h"
#import "MDInitialSlidingViewController.h"
#import "MDSlidingNavigationController.h"
#import "MDLocateViewController.h"

@implementation MDAppDelegate

#pragma mark - Convenience methods

+ (MDAppDelegate *)sharedAppDelegate {
    return (MDAppDelegate *)[[UIApplication sharedApplication] delegate];
}

#pragma mark - App lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    ECSlidingViewController *slidingViewController = (ECSlidingViewController *)self.window.rootViewController;
    UIStoryboard *storyboard;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        storyboard = [UIStoryboard storyboardWithName:@"MainiPhone" bundle:nil];
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        storyboard = [UIStoryboard storyboardWithName:@"MainiPad" bundle:nil];
    }
    
    slidingViewController.topViewController = [storyboard instantiateViewControllerWithIdentifier:@"MDLocateNavController"];    
    return YES;
}

@end
