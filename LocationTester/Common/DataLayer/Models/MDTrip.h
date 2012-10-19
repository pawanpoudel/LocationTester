//
//  MDTrip.h
//  LocationTester
//
//  Created by PAWAN POUDEL on 10/18/12.
//  Copyright (c) 2012 Mobile Defense Inc. All rights reserved.
//

@class MDLocation;

@interface MDTrip : NSManagedObject

@property (nonatomic, retain) NSDate * tripStartTime;
@property (nonatomic, retain) NSDate * tripEndTime;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *locations;
@end

@interface MDTrip (CoreDataGeneratedAccessors)

- (void)addLocationsObject:(MDLocation *)value;
- (void)removeLocationsObject:(MDLocation *)value;
- (void)addLocations:(NSSet *)values;
- (void)removeLocations:(NSSet *)values;

@end
