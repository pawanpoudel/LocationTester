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
#import "MDTestingToolsViewController.h"

NSString *kMDLocationSimulationTurnedOn = @"kMDLocationSimulationTurnedOn";
NSString *kMDUniqueIDOfTripToSimulate =  @"kMDUniqueIDOfTripToSimulate";

@interface MDAppDelegate()
@property (strong, nonatomic) MDSlidingNavigationController *testingToolsNavController;
@end

@implementation MDAppDelegate

#pragma mark - Accessors

- (MDSlidingNavigationController *)testingToolsNavController {
    if (_testingToolsNavController) {
        return _testingToolsNavController;
    }
    
    MDTestingToolsViewController *testingToolsViewController = [[MDTestingToolsViewController alloc] init];
    _testingToolsNavController = [[MDSlidingNavigationController alloc] initWithRootViewController:testingToolsViewController];
    return _testingToolsNavController;
}

#pragma mark - Convenience methods

+ (MDAppDelegate *)sharedAppDelegate {
    return (MDAppDelegate *)[[UIApplication sharedApplication] delegate];
}

#pragma mark - App lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    MDInitialSlidingViewController *slidingViewController = [[MDInitialSlidingViewController alloc] init];
    slidingViewController.topViewController = self.testingToolsNavController;
    self.window.rootViewController = slidingViewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
