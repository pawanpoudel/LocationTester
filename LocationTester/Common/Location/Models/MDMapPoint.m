//
//  MDMapPoint.m
//  MobileDefense
//
//  Created by Pawan Poudel on 4/18/12.
//  Copyright (c) 2012 Mobile Defense Inc. All rights reserved.
//

#import "MDMapPoint.h"

@implementation MDMapPoint

#pragma mark - Accessors

@synthesize coordinate;
@synthesize title;
@synthesize subtitle;

#pragma mark - Initializers

- (id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate 
                   title:(NSString *)aTitle
                subtitle:(NSString *)aSubtitle 
{
    self = [super init];
    if (self != nil) {
        coordinate = aCoordinate;
        self.title = aTitle;
        self.subtitle = aSubtitle;
    }
    return self;
}

@end
