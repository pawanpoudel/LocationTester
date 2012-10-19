//
//  MDLocationManager.h
//  LocationTester
//
//  Created by PAWAN POUDEL on 10/18/12.
//  Copyright (c) 2012 Mobile Defense Inc. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@class MDTrip;

@protocol MDLocationManagerDelegate;

@interface MDLocationManager : NSObject <CLLocationManagerDelegate>

@property (nonatomic, strong) MDTrip *trip;
@property (nonatomic, weak) id<MDLocationManagerDelegate> delegate;

- (void)startRecordingTrip;
- (void)stopRecordingTrip;

- (void)startUpdatingLocation;

@end

@protocol MDLocationManagerDelegate <NSObject>

@optional
- (void)locationManagerDidStopRecordingTrip:(MDLocationManager *)locationManager;
- (void)locationManager:(MDLocationManager *)locationManager didUpdateToLocation:(CLLocation *)newLocation;
- (void)locationManager:(MDLocationManager *)locationManager didFailWithError:(NSError *)error;

@end
