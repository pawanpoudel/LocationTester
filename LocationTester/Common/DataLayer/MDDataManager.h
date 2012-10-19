//
//  MDDataManager.h
//  LocationTester
//
//  Created by PAWAN POUDEL on 10/18/12.
//  Copyright (c) 2012 Mobile Defense Inc. All rights reserved.
//

@class MDLocation;
@class MDTrip;

@interface MDDataManager : NSObject

+ (MDDataManager *)sharedDataManager;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (MDLocation *)createLocationEntity;
- (MDTrip *)createTripEntity;

- (NSArray *)fetchTrips;
- (void)deleteTrips;

@end
