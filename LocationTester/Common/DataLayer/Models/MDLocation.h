//
//  MDLocation.h
//  LocationTester
//
//  Created by PAWAN POUDEL on 10/18/12.
//  Copyright (c) 2012 Mobile Defense Inc. All rights reserved.
//

@class MDTrip;

@interface MDLocation : NSManagedObject

@property (nonatomic, retain) NSNumber * horizontalAccuracy;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) MDTrip *trip;

@end
