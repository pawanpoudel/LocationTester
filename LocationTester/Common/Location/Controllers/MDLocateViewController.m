//
//  MDLocateViewController.m
//  LocationTester
//
//  Created by PAWAN POUDEL on 10/18/12.
//  Copyright (c) 2012 Mobile Defense Inc. All rights reserved.
//

#import "MDLocateViewController.h"

@implementation MDLocateViewController

- (IBAction)revealMenu:(id)sender {
  [self.slidingViewController anchorTopViewTo:ECRight];
}

@end